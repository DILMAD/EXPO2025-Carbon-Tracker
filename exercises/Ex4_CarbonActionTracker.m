function Ex4_CarbonActionTracker()
%EX4_CARBONACTIONTRACKER Interactive carbon footprint action planning app
%
%   This app allows users to:
%   1. Input their current carbon footprint data
%   2. View their emissions breakdown and comparisons
%   3. Select personalized reduction actions
%   4. View projected impact and action plan summary
%
%   Uses HTML/JavaScript frontend with MATLAB computational backend
%
%   See also: calculateCurrentFootprint, getAvailableActions, calculateActionImpact

    %% Create main figure
    %fig = uifigure('Name', 'Carbon Action Tracker - Exercise 4', ...
    %               'Position', [100, 100, 1200, 800], ...
    %               'Color', [1 1 1]);
    
    %% Create HTML component
    %h = uihtml(fig, 'Position', [0, 0, 1200, 800]);

    % Create main figure with better size
    fig = uifigure('Name', 'Carbon Action Tracker - Exercise 4', ...
               'Position', [50, 50, 1400, 600], ...  % Larger: 1400x900
               'Color', [1 1 1]);

    % Create HTML component (full size)
    h = uihtml(fig, 'Position', [0, 0, 1400, 600]);
    h.HTMLSource = fullfile(pwd, 'Ex4_CarbonActionTracker.html');
    h.HTMLEventReceivedFcn = @(src, event) handleEvent(src, event, h);
    
    fprintf('Carbon Action Tracker started successfully.\n');
    fprintf('Loading interface...\n\n');
end

function handleEvent(src, event, h)
    %HANDLEEVENT Process events from JavaScript interface
    
    eventName = event.HTMLEventName;
    eventData = event.HTMLEventData;
    
    fprintf('Event received: %s\n', eventName);
    
    try
        switch eventName
            case 'CalculateFootprint'
                handleCalculateFootprint(src, eventData);
                
            case 'GetAvailableActions'
                handleGetAvailableActions(src, eventData);
                
            case 'CalculateActionImpact'
                handleCalculateActionImpact(src, eventData);
                
            case 'GenerateSummary'
                handleGenerateSummary(src, eventData);
                
            case 'ResetApp'
                handleResetApp(src);
                
            otherwise
                warning('Unknown event: %s', eventName);
        end
        
    catch ME
        fprintf('Error in handleEvent: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        errorData = struct('message', ME.message);
        sendEventToHTMLSource(src, 'Error', errorData);
    end
end

function handleCalculateFootprint(src, data)
    %HANDLECALCULATEFOOTPRINT Calculate user's current carbon footprint
    
    fprintf('Calculating footprint for region: %s\n', data.region);
    
    % Validate inputs
    if ~isValidInput(data)
        error('Invalid input data received');
    end
    
    % Calculate current footprint using Exercise 2 functions
    footprint = calculateCurrentFootprint(data);
    
    % Load regional data for comparison
    regionalData = loadRegionalData(data.region);
    
    % Calculate comparisons
    footprint.region = data.region;
    footprint.regionalAvg = regionalData.PerCapita_Total_Tons;
    footprint.globalAvg = 4.7;  % Global average tons/year
    footprint.parisTarget = 2.0;  % 2030 target
    
    % Calculate percentage above/below targets
    footprint.vsRegional = ((footprint.total / footprint.regionalAvg) - 1) * 100;
    footprint.vsGlobal = ((footprint.total / footprint.globalAvg) - 1) * 100;
    footprint.vsParis = ((footprint.total / footprint.parisTarget) - 1) * 100;
    
    % Determine Paris alignment status
    if footprint.total / 1000 <= footprint.parisTarget
        footprint.parisStatus = 'aligned';
    elseif footprint.total / 1000 <= footprint.parisTarget * 1.5
        footprint.parisStatus = 'close';
    else
        footprint.parisStatus = 'above';
    end
    
    fprintf('Total footprint: %.2f tons CO2e/year\n', footprint.totalTons);
    fprintf('Transport: %.2f, Home: %.2f, Food: %.2f, Digital: %.2f, Consumption: %.2f\n', ...
        footprint.transportTons, footprint.homeTons, footprint.foodTons, ...
        footprint.digitalTons, footprint.consumptionTons);
    
    % Send results back to JavaScript
    sendEventToHTMLSource(src, 'FootprintCalculated', footprint);
end

function handleGetAvailableActions(src, data)
    %HANDLEGETAVAILABLEACTIONS Get filtered actions for user's region
    
    fprintf('Getting available actions for: %s\n', data.region);
    
    % Get filtered actions based on region and current footprint
    actions = getAvailableActions(data.region, data.currentFootprint);
    
    fprintf('Found %d applicable actions\n', length(actions));
    
    % Send actions to JavaScript
    sendEventToHTMLSource(src, 'ActionsLoaded', actions);
end

function handleCalculateActionImpact(src, data)
    %HANDLECALCULATEACTIONIMPACT Calculate impact of selected actions
    
    fprintf('Calculating impact of %d selected actions\n', length(data.selectedActionIDs));
    
    % Calculate the impact
    impact = calculateActionImpact(data.region, data.currentFootprint, ...
                                   data.selectedActionIDs, data.allActions);
    
    % Calculate new footprint
    impact.newTotal = (data.currentFootprint.total - impact.totalReduction) / 1000;  % Convert to tons
    impact.reductionPercent = (impact.totalReduction / data.currentFootprint.total) * 100;
    
    % Update Paris alignment
    if impact.newTotal <= 2.0
        impact.parisStatus = 'aligned';
    elseif impact.newTotal <= 3.0
        impact.parisStatus = 'close';
    else
        impact.parisStatus = 'above';
    end
    
    % Calculate cost summary
    if ~isempty(impact.actionDetails)
        impact.totalCostLow = sum([impact.actionDetails.costLow]);
        impact.totalCostHigh = sum([impact.actionDetails.costHigh]);
    else
        impact.totalCostLow = 0;
        impact.totalCostHigh = 0;
    end
    
    fprintf('Total reduction: %.2f tons (%.1f%%)\n', ...
        impact.totalReduction/1000, impact.reductionPercent);
    fprintf('New footprint: %.2f tons\n', impact.newTotal);
    
    % Send results back
    sendEventToHTMLSource(src, 'ImpactCalculated', impact);
end

function handleGenerateSummary(src, data)
    %HANDLEGENERATESUMMARY Generate text summary of action plan
    
    fprintf('Generating action plan summary\n');
    
    % Generate formatted summary
    summary = generateActionSummary(data.currentFootprint, data.impact, ...
                                   data.selectedActions, data.region);
    
    % Send summary to JavaScript as a simple string
    sendEventToHTMLSource(src, 'SummaryGenerated', summary);
end

function handleResetApp(src)
    %HANDLERESETAPP Reset the app to initial state
    
    fprintf('Resetting application\n');
    
    resetData = struct('success', true);
    sendEventToHTMLSource(src, 'AppReset', resetData);
end

function valid = isValidInput(data)
    %ISVALIDINPUT Validate user input data
    
    valid = true;
    
    % Check required fields exist
    requiredFields = {'region', 'commuteMode', 'dailyCommuteKm', ...
                     'commuteDays', 'monthlyElectricityKWh', 'dietType'};
    
    for i = 1:length(requiredFields)
        if ~isfield(data, requiredFields{i})
            fprintf('Missing required field: %s\n', requiredFields{i});
            valid = false;
            return;
        end
    end
    
    % Check numeric values are positive
    numericFields = {'dailyCommuteKm', 'commuteDays', 'monthlyElectricityKWh', ...
                    'monthlyNaturalGasKWh', 'domesticFlights', 'internationalFlights'};
    
    for i = 1:length(numericFields)
        if isfield(data, numericFields{i})
            value = data.(numericFields{i});
            if ~isnumeric(value) || value < 0
                fprintf('Invalid value for %s: must be positive number\n', numericFields{i});
                valid = false;
                return;
            end
        end
    end
end

function regionalData = loadRegionalData(region)
    %LOADREGIONALDATA Load regional averages for comparison
    
    dataPath = fullfile(pwd, '..', 'data', 'regionalAverages.csv');
    
    if ~isfile(dataPath)
        error('Regional data file not found: %s', dataPath);
    end
    
    allData = readtable(dataPath);
    
    % Find region (case-insensitive)
    idx = find(strcmpi(allData.Region, region), 1);
    
    if isempty(idx)
        warning('Region "%s" not found, using Global average', region);
        idx = find(strcmpi(allData.Region, 'Global'), 1);
    end
    
    regionalData = allData(idx, :);
end