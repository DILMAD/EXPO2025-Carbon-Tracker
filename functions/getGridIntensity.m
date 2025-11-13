function gridIntensity_gCO2_per_kWh = getGridIntensity(region)
%GETGRIDINTENSITY Get electricity grid carbon intensity for a region
%
%   gridIntensity_gCO2_per_kWh = GETGRIDINTENSITY(region)
%
%   Returns the carbon intensity of the electricity grid for a specified
%   region in grams of CO₂ per kilowatt-hour. This is used to calculate
%   emissions from electricity consumption.
%
%   INPUT:
%       region - Geographic region (string): 'USA', 'Europe', 'China', 
%                'India', 'Norway', 'Brazil', 'Global', etc.
%
%   OUTPUT:
%       gridIntensity_gCO2_per_kWh - Grid carbon intensity (g CO₂/kWh)
%
%   DATA SOURCE:
%       Reads from ../data/regionalAverages.csv
%       Primary source: Ember Global Electricity Review 2025
%
%   EXAMPLE:
%       intensity = getGridIntensity('Norway');
%       fprintf('Norway grid: %d g CO₂/kWh\n', intensity);
%
%   See also: calculateHomeEmissions

% Input validation
arguments
    region (1,1) string
end

% Load regional data
dataPath = fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'regionalAverages.csv');

if ~isfile(dataPath)
    error('GridIntensity:FileNotFound', ...
        'Regional data file not found: %s', dataPath);
end

regionalData = readtable(dataPath);

% Find region (case-insensitive)
idx = find(strcmpi(regionalData.Region, region), 1);

if isempty(idx)
    % Fallback to Global if region not found
    warning('GridIntensity:RegionNotFound', ...
        'Region "%s" not found, using Global average', region);
    idx = find(strcmpi(regionalData.Region, 'Global'), 1);
    
    if isempty(idx)
        error('GridIntensity:NoData', ...
            'Could not find Global fallback data');
    end
end

% Extract grid intensity
gridIntensity_gCO2_per_kWh = regionalData.GridIntensity_gCO2_per_kWh(idx);

end