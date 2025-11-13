function impact = calculateActionImpact(region, currentFootprint, selectedActionIDs, allActions)
%CALCULATEACTIONIMPACT Calculate emission reduction from selected actions
%
%   impact = CALCULATEACTIONIMPACT(region, currentFootprint, selectedActionIDs, allActions)
%
%   Calculates context-dependent impact for each selected action
%
%   INPUT:
%       region - User's region
%       currentFootprint - Current emissions struct
%       selectedActionIDs - Array of selected action IDs
%       allActions - Full action library struct array
%
%   OUTPUT:
%       impact - Struct with:
%           totalReduction (kg), actionDetails (array), categoryBreakdown

% Load regional modifiers
modifierPath = fullfile(pwd, '..', 'data', 'regionalActionModifiers.csv');
if isfile(modifierPath)
    modifiers = readtable(modifierPath);
else
    % Create default modifiers if file doesn't exist
    modifiers = [];
end

% Initialize impact struct
impact = struct();
impact.totalReduction = 0;
impact.actionDetails = struct('id', {}, 'name', {}, 'category', {}, ...
                              'impact', {}, 'costCategory', {}, ...
                              'costLow', {}, 'costHigh', {});
impact.categoryBreakdown = struct('Transport', 0, 'Home', 0, 'Food', 0, ...
                                  'Digital', 0, 'Consumption', 0);

% Calculate impact for each selected action
actionCount = 0;
for i = 1:length(selectedActionIDs)
    actionID = selectedActionIDs(i);
    
    % Find action in library
    actionIdx = find([allActions.ActionID] == actionID, 1);
    if isempty(actionIdx)
        warning('Action ID %d not found', actionID);
        continue;
    end
    
    action = allActions(actionIdx);
    
    % Get base impact
    baseImpact = action.BaseImpact_kg;
    
    % Apply regional multiplier if applicable
    multiplier = getRegionalMultiplier(region, action.ActionID, action.Category, modifiers);
    
    % Calculate actual impact (context-dependent)
    actualImpact = baseImpact * multiplier;
    
    % Cap impact at current category emissions
    category = char(action.Category);
    switch category
        case 'Transport'
            actualImpact = min(actualImpact, currentFootprint.transport);
        case 'Home'
            actualImpact = min(actualImpact, currentFootprint.home);
        case 'Food'
            actualImpact = min(actualImpact, currentFootprint.food);
        case 'Digital'
            actualImpact = min(actualImpact, currentFootprint.digital);
        case 'Consumption'
            actualImpact = min(actualImpact, currentFootprint.consumption);
    end
    
    % Add to totals
    impact.totalReduction = impact.totalReduction + actualImpact;
    impact.categoryBreakdown.(category) = impact.categoryBreakdown.(category) + actualImpact;
    
    % Store action detail with all required fields
    actionCount = actionCount + 1;
    impact.actionDetails(actionCount).id = action.ActionID;
    impact.actionDetails(actionCount).name = char(action.ActionName);
    impact.actionDetails(actionCount).category = category;
    impact.actionDetails(actionCount).impact = actualImpact;
    impact.actionDetails(actionCount).costCategory = char(action.CostCategory);
    impact.actionDetails(actionCount).costLow = action.costLow;
    impact.actionDetails(actionCount).costHigh = action.costHigh;
end

% Sort actions by impact (highest first)
if actionCount > 0
    impacts = [impact.actionDetails.impact];
    [~, sortIdx] = sort(impacts, 'descend');
    impact.actionDetails = impact.actionDetails(sortIdx);
end

end

function multiplier = getRegionalMultiplier(region, actionID, category, modifiers)
%GETREGIONALMULTIPLIER Get impact multiplier for region-specific context

% Default multiplier
multiplier = 1.0;

if isempty(modifiers)
    return;
end

% Find region-specific modifier
regionIdx = find(strcmpi(modifiers.Region, region), 1);
if isempty(regionIdx)
    return;
end

% Check for action-specific modifier
actionCol = sprintf('Action_%d_Multiplier', actionID);
if ismember(actionCol, modifiers.Properties.VariableNames)
    multiplier = modifiers.(actionCol)(regionIdx);
    return;
end

% Check for category-wide modifiers
categoryCol = sprintf('%s_Multiplier', category);
if ismember(categoryCol, modifiers.Properties.VariableNames)
    multiplier = modifiers.(categoryCol)(regionIdx);
end

end