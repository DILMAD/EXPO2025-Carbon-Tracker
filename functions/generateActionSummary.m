function summaryText = generateActionSummary(currentFootprint, impact, selectedActions, region)
%GENERATEACTIONSUMMARY Generate simplified text summary of action plan
%
%   summaryText = GENERATEACTIONSUMMARY(currentFootprint, impact, selectedActions, region)
%
%   Creates simple, readable summary of carbon reduction plan

% Header
summaryText = sprintf('========================================\n');
summaryText = sprintf('%s  YOUR CARBON ACTION PLAN\n', summaryText);
summaryText = sprintf('%s========================================\n\n', summaryText);

% Region
summaryText = sprintf('%sRegion: %s\n\n', summaryText, region);

% Current vs Projected
summaryText = sprintf('%s--- EMISSIONS SUMMARY ---\n', summaryText);
summaryText = sprintf('%sCurrent Footprint:  %.2f tons CO2e/year\n', ...
    summaryText, currentFootprint.totalTons);
summaryText = sprintf('%sProjected Footprint: %.2f tons CO2e/year\n', ...
    summaryText, impact.newTotal);
summaryText = sprintf('%sTotal Reduction:     %.2f tons (%.0f%%)\n\n', ...
    summaryText, impact.totalReduction/1000, impact.reductionPercent);

% Paris Agreement Status
summaryText = sprintf('%s--- PARIS AGREEMENT STATUS ---\n', summaryText);
parisTarget = 2.0;
if impact.newTotal <= parisTarget
    summaryText = sprintf('%s✓ ON TRACK!\n', summaryText);
    summaryText = sprintf('%sYou are below the 2.0 tons/year target\n\n', summaryText);
elseif impact.newTotal <= parisTarget + 1.0
    summaryText = sprintf('%s⚠ CLOSE TO TARGET\n', summaryText);
    summaryText = sprintf('%sYou are %.2f tons above the 2.0 target\n\n', ...
        summaryText, impact.newTotal - parisTarget);
else
    summaryText = sprintf('%s✗ ABOVE TARGET\n', summaryText);
    summaryText = sprintf('%sYou need to reduce by %.2f more tons\n\n', ...
        summaryText, impact.newTotal - parisTarget);
end

% Reduction by Category
summaryText = sprintf('%s--- REDUCTION BY CATEGORY ---\n', summaryText);
categories = {'Transport', 'Home', 'Food', 'Digital', 'Consumption'};
for i = 1:length(categories)
    catName = categories{i};
    if isfield(impact.categoryBreakdown, catName)
        reduction = impact.categoryBreakdown.(catName);
        if reduction > 0
            summaryText = sprintf('%s%-15s -%.1f kg/year\n', ...
                summaryText, [catName ':'], reduction);
        end
    end
end
summaryText = sprintf('%s\n', summaryText);

% Selected Actions
numActions = length(impact.actionDetails);
summaryText = sprintf('%s--- SELECTED ACTIONS (%d total) ---\n\n', ...
    summaryText, numActions);

if numActions > 0
    % Sort actions by impact (highest first)
    impacts = zeros(numActions, 1);
    for i = 1:numActions
        impacts(i) = impact.actionDetails(i).impact;
    end
    [~, sortIdx] = sort(impacts, 'descend');
    
    % Display top actions
    for i = 1:numActions
        idx = sortIdx(i);
        action = impact.actionDetails(idx);
        
        summaryText = sprintf('%s%d. %s\n', summaryText, i, action.name);
        summaryText = sprintf('%s   Impact: -%.0f kg CO2/year\n', ...
            summaryText, action.impact);
        summaryText = sprintf('%s   Cost:   %s\n', ...
            summaryText, action.costCategory);
        
        if i < numActions
            summaryText = sprintf('%s\n', summaryText);
        end
    end
else
    summaryText = sprintf('%sNo actions selected\n', summaryText);
end

summaryText = sprintf('%s\n', summaryText);

% Investment Summary
summaryText = sprintf('%s--- ESTIMATED INVESTMENT ---\n', summaryText);
if impact.totalCostLow == 0 && impact.totalCostHigh == 0
    summaryText = sprintf('%sTotal Cost: FREE\n', summaryText);
    summaryText = sprintf('%s(Behavioral changes only)\n', summaryText);
elseif impact.totalCostLow == impact.totalCostHigh
    summaryText = sprintf('%sTotal Cost: ~$%s\n', ...
        summaryText, formatCurrency(impact.totalCostLow));
else
    summaryText = sprintf('%sTotal Cost Range: $%s - $%s\n', ...
        summaryText, formatCurrency(impact.totalCostLow), ...
        formatCurrency(impact.totalCostHigh));
end

summaryText = sprintf('%s\n', summaryText);

% Footer
summaryText = sprintf('%s========================================\n', summaryText);
summaryText = sprintf('%s  Next Steps:\n', summaryText);
summaryText = sprintf('%s  1. Review your action plan\n', summaryText);
summaryText = sprintf('%s  2. Start with easiest actions first\n', summaryText);
summaryText = sprintf('%s  3. Track your progress monthly\n', summaryText);
summaryText = sprintf('%s  4. Adjust as needed\n', summaryText);
summaryText = sprintf('%s========================================\n', summaryText);

end

function str = formatCurrency(num)
%FORMATCURRENCY Format number as currency with commas
    if num >= 1000
        str = sprintf('%,.0f', num);
    else
        str = sprintf('%.0f', num);
    end
end