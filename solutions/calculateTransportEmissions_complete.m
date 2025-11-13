function annualEmissionsCO2e_kg = calculateTransportEmissions(region, commuteMode, ...
    dailyCommuteKm, commuteDaysPerYear, domesticFlightsPerYear, avgDomesticFlightKm, ...
    internationalFlightsPerYear, avgInternationalFlightKm, otherTravelKmPerWeek)
%CALCULATETRANSPORTEMISSIONS Calculate annual CO₂-equivalent emissions from personal transportation
%
%   annualEmissionsCO2e_kg = CALCULATETRANSPORTEMISSIONS(region, commuteMode, 
%       dailyCommuteKm, commuteDaysPerYear, domesticFlightsPerYear, 
%       avgDomesticFlightKm, internationalFlightsPerYear, 
%       avgInternationalFlightKm, otherTravelKmPerWeek)
%
%   Calculates total annual carbon dioxide equivalent emissions in kilograms 
%   from various personal transportation activities including daily commute, 
%   flights, and other regular travel.
%
%   INPUTS:
%       region                      - Geographic region (string): 'Global', 'USA', 
%                                     'Europe', 'Asia', 'China', 'India', 'Norway', etc.
%       commuteMode                 - Daily commute mode (string): 
%                                     'Car_Gasoline', 'Car_Diesel', 'Car_Electric_BEV',
%                                     'Bus', 'Train_Rail', 'Motorcycle', 'Cycling', 'Walking'
%       dailyCommuteKm              - One-way daily commute distance (km)
%       commuteDaysPerYear          - Number of commuting days per year (typical: 200-250)
%       domesticFlightsPerYear      - Number of domestic round-trip flights per year
%       avgDomesticFlightKm         - Average one-way domestic flight distance (km)
%       internationalFlightsPerYear - Number of international round-trip flights per year
%       avgInternationalFlightKm    - Average one-way international flight distance (km)
%       otherTravelKmPerWeek        - Other travel per week: errands, weekends (km)
%
%   OUTPUT:
%       annualEmissionsCO2e_kg - Total annual CO₂-equivalent emissions in kilograms
%
%   EMISSION FACTORS:
%       Based on authoritative global sources:
%       - UK DEFRA 2024 Greenhouse Gas Conversion Factors
%       - US EPA Emission Factors 2024
%       - IEA Transport and CO₂ Report 2024
%       - IPCC AR6 Working Group III Chapter 10
%       - EMEP/EEA Emission Inventory Guidebook 2020
%
%   GLOBAL CONTEXT:
%       - Global average transport emissions: 1.2 tons CO₂/year per person
%       - US average: 4.8 tons CO₂/year per person
%       - EU average: 2.1 tons CO₂/year per person
%       - Asia-Pacific: 83% of global transport emission growth since Paris Agreement
%
%   EXAMPLE:
%       % US suburban car commuter with occasional flights
%       emissions = calculateTransportEmissions('USA', 'Car_Gasoline', ...
%           25, 250, 2, 1500, 1, 8000, 50);
%       fprintf('Annual emissions: %.1f kg CO₂e (%.2f tons)\n', ...
%           emissions, emissions/1000);
%
%   See also: calculateHomeEmissions, calculateFoodEmissions, calculateTotalFootprint

% Input validation using arguments block
arguments
    region (1,1) string
    commuteMode (1,1) string
    dailyCommuteKm (1,1) double {mustBeNonnegative}
    commuteDaysPerYear (1,1) double {mustBeNonnegative, mustBeInteger}
    domesticFlightsPerYear (1,1) double {mustBeNonnegative, mustBeInteger}
    avgDomesticFlightKm (1,1) double {mustBeNonnegative}
    internationalFlightsPerYear (1,1) double {mustBeNonnegative, mustBeInteger}
    avgInternationalFlightKm (1,1) double {mustBeNonnegative}
    otherTravelKmPerWeek (1,1) double {mustBeNonnegative}
end

% Load emission factors database
dataPath = fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'transportEmissionFactors.csv');
emissionData = readtable(dataPath);

%% Calculate Daily Commute Emissions

% Special handling for zero-emission modes
if strcmp(commuteMode, 'Walking') || strcmp(commuteMode, 'Cycling')
    commuteEmissions_g = 0;
else
    % Find emission factor for commute mode and region
    % Try specific region first, fall back to Global if not found
    idx = find(strcmp(emissionData.Transport_Mode, commuteMode) & ...
               strcmp(emissionData.Region, region), 1);
    
    if isempty(idx)
        % Fallback to Global
        idx = find(strcmp(emissionData.Transport_Mode, commuteMode) & ...
                   strcmp(emissionData.Region, 'Global'), 1);
    end
    
    if isempty(idx)
        error('TransportEmissions:InvalidMode', ...
            'Commute mode "%s" not found in emission factors database for region "%s"', ...
            commuteMode, region);
    end
    
    commuteEmissionFactor = emissionData.CO2e_Factor_g_per_unit(idx);
    
    % Calculate annual commute emissions (round trip)
    commuteEmissions_g = dailyCommuteKm * 2 * commuteEmissionFactor * commuteDaysPerYear;
end

%% Calculate Flight Emissions

% Domestic flights (use Domestic_Medium category ~156 g/pkm)
idxDomestic = find(strcmp(emissionData.Transport_Mode, 'Aviation') & ...
                   strcmp(emissionData.Vehicle_Type, 'Domestic_Medium') & ...
                   strcmp(emissionData.Region, 'Global'), 1);

if ~isempty(idxDomestic)
    domesticFlightFactor = emissionData.CO2e_Factor_g_per_unit(idxDomestic);
    % Round trip = 2 legs, multiply by number of flights
    domesticFlightEmissions_g = domesticFlightsPerYear * 2 * avgDomesticFlightKm * domesticFlightFactor;
else
    domesticFlightEmissions_g = 0;
    warning('Domestic flight emission factor not found, using 0');
end

% International flights (use International_Long category ~147 g/pkm)
idxInternational = find(strcmp(emissionData.Transport_Mode, 'Aviation') & ...
                        strcmp(emissionData.Vehicle_Type, 'International_Long') & ...
                        strcmp(emissionData.Region, 'Global'), 1);

if ~isempty(idxInternational)
    internationalFlightFactor = emissionData.CO2e_Factor_g_per_unit(idxInternational);
    % Round trip = 2 legs, multiply by number of flights
    internationalFlightEmissions_g = internationalFlightsPerYear * 2 * avgInternationalFlightKm * internationalFlightFactor;
else
    internationalFlightEmissions_g = 0;
    warning('International flight emission factor not found, using 0');
end

%% Calculate Other Regular Travel Emissions

% For other travel, use same mode as commute
% Exception: if commute is Walking/Cycling, assume Car for other travel
if strcmp(commuteMode, 'Walking') || strcmp(commuteMode, 'Cycling')
    otherTravelMode = 'Car_Gasoline';
    otherRegion = region;
else
    otherTravelMode = commuteMode;
    otherRegion = region;
end

% Find emission factor
idx = find(strcmp(emissionData.Transport_Mode, otherTravelMode) & ...
           strcmp(emissionData.Region, otherRegion), 1);

if isempty(idx)
    % Fallback to Global
    idx = find(strcmp(emissionData.Transport_Mode, otherTravelMode) & ...
               strcmp(emissionData.Region, 'Global'), 1);
end

if ~isempty(idx)
    otherTravelFactor = emissionData.CO2e_Factor_g_per_unit(idx);
    % Annualize: weekly travel × 52 weeks
    otherTravelEmissions_g = otherTravelKmPerWeek * 52 * otherTravelFactor;
else
    otherTravelEmissions_g = 0;
    warning('Other travel emission factor not found, using 0');
end

%% Sum All Components and Convert to kg

totalEmissions_g = commuteEmissions_g + domesticFlightEmissions_g + ...
                   internationalFlightEmissions_g + otherTravelEmissions_g;

annualEmissionsCO2e_kg = totalEmissions_g / 1000;  % Convert g to kg

end