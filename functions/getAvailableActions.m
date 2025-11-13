function actions = getAvailableActions(region, currentFootprint)
%GETAVAILABLEACTIONS Get filtered list of applicable actions for user
%
%   actions = GETAVAILABLEACTIONS(region, currentFootprint)
%
%   Filters action library based on regional constraints and user context
%
%   INPUT:
%       region - User's geographic region
%       currentFootprint - Struct with current emissions data
%
%   OUTPUT:
%       actions - Array of structs with applicable actions

% Load action library
libraryPath = fullfile(pwd, '..', 'data', 'actionLibrary.csv');
if ~isfile(libraryPath)
    error('Action library not found: %s', libraryPath);
end

allActions = readtable(libraryPath);

% Load regional data
regionalPath = fullfile(pwd, '..', 'data', 'regionalAverages.csv');
regionalData = readtable(regionalPath);
regionIdx = find(strcmpi(regionalData.Region, region), 1);

if isempty(regionIdx)
    regionIdx = find(strcmpi(regionalData.Region, 'Global'), 1);
end

gridIntensity = regionalData.GridIntensity_gCO2_per_kWh(regionIdx);
climateZone = char(regionalData.ClimateZone(regionIdx));

% Filter actions based on regional applicability
applicable = true(height(allActions), 1);

for i = 1:height(allActions)
    action = allActions(i, :);
    
    % Check grid intensity requirements
    if ~isnan(action.MinGridIntensity) && gridIntensity < action.MinGridIntensity
        applicable(i) = false;
        continue;
    end
    
    if ~isnan(action.MaxGridIntensity) && gridIntensity > action.MaxGridIntensity
        applicable(i) = false;
        continue;
    end
    
    % Check climate zone applicability
    applicableClimates = char(action.ApplicableClimates);
    if ~strcmp(applicableClimates, 'All') && ~contains(applicableClimates, climateZone)
        applicable(i) = false;
        continue;
    end
    
    % Check if action is relevant to current footprint
    category = char(action.Category);
    switch category
        case 'Transport'
            if currentFootprint.transport < 100  % Very low transport emissions
                applicable(i) = false;
            end
        case 'Home'
            if currentFootprint.home < 100  % Very low home emissions
                applicable(i) = false;
            end
        case 'Food'
            if currentFootprint.food < 500  % Already low food emissions
                applicable(i) = false;
            end
    end
end

% Filter to applicable actions
filteredActions = allActions(applicable, :);

% Convert to struct array for JavaScript
actions = table2struct(filteredActions);

% Add display-friendly cost labels
for i = 1:length(actions)
    switch actions(i).CostCategory
        case 'Free'
            actions(i).costLabel = 'Free';
            actions(i).costLow = 0;
            actions(i).costHigh = 0;
        case 'Low'
            actions(i).costLabel = 'Low ($0-500)';
            actions(i).costLow = 0;
            actions(i).costHigh = 500;
        case 'Medium'
            actions(i).costLabel = 'Medium ($500-5K)';
            actions(i).costLow = 500;
            actions(i).costHigh = 5000;
        case 'High'
            actions(i).costLabel = 'High ($5K+)';
            actions(i).costLow = 5000;
            actions(i).costHigh = 50000;
    end
end

fprintf('Filtered to %d applicable actions from %d total\n', ...
    length(actions), height(allActions));

end