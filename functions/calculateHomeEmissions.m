function annualEmissionsCO2e_kg = calculateHomeEmissions(region, annualElectricityKWh, annualNaturalGasKWh)
%CALCULATEHOMEEMISSIONS Calculate annual CO₂-equivalent emissions from home energy use
%
%   annualEmissionsCO2e_kg = CALCULATEHOMEEMISSIONS(region, annualElectricityKWh, 
%                                                     annualNaturalGasKWh)
%
%   Calculates carbon dioxide equivalent emissions in kilograms from residential
%   energy consumption, accounting for regional grid carbon intensity differences.
%
%   INPUTS:
%       region               - Geographic region (string): 'USA', 'Europe', 
%                             'China', 'India', 'Norway', 'Brazil', 'Global', etc.
%       annualElectricityKWh - Annual electricity consumption (kWh)
%       annualNaturalGasKWh  - Annual natural gas consumption in heating value (kWh)
%                             Set to 0 if using electric heating or no gas
%
%   OUTPUT:
%       annualEmissionsCO2e_kg - Total annual CO₂-equivalent emissions (kg)
%
%   GRID INTENSITY EXAMPLES (g CO₂/kWh):
%       Norway:      30  (hydro-dominated)
%       Brazil:     103  (hydro-dominated)
%       Europe:     230  (mixed renewables/gas)
%       USA:        384  (gas/coal mix)
%       Global:     473  (world average)
%       China:      550  (coal-heavy)
%       India:      708  (coal-heavy)
%       Poland:     662  (coal-heavy)
%       South Africa: 950 (coal-heavy)
%
%   NATURAL GAS FACTOR:
%       200 g CO₂/kWh (IPCC 2019 Guidelines for direct combustion)
%
%   SOURCES:
%       - Ember Global Electricity Review 2025
%       - IEA Electricity 2025 Report
%       - IPCC 2019 Refinement Guidelines (Natural Gas)
%       - Our World in Data Carbon Intensity Database
%
%   EXAMPLE:
%       % USA household: 900 kWh/month electricity, 300 kWh/month gas
%       emissions = calculateHomeEmissions('USA', 900*12, 300*12);
%       fprintf('Annual home emissions: %.1f kg CO₂e (%.2f tons)\n', ...
%           emissions, emissions/1000);
%
%       % Norway apartment: 400 kWh/month electricity, electric heating (no gas)
%       emissions = calculateHomeEmissions('Norway', 400*12, 0);
%       fprintf('Annual home emissions: %.1f kg CO₂e (%.2f tons)\n', ...
%           emissions, emissions/1000);
%
%   See also: calculateTransportEmissions, getGridIntensity

% Input validation
arguments
    region (1,1) string
    annualElectricityKWh (1,1) double {mustBeNonnegative}
    annualNaturalGasKWh (1,1) double {mustBeNonnegative}
end

% Load grid intensity data
gridIntensity = getGridIntensity(region);  % Returns g CO₂/kWh

% Calculate emissions from electricity (location-dependent)
% Grid intensity varies dramatically: Norway 30 vs India 708 g/kWh
electricityEmissions_g = annualElectricityKWh * gridIntensity;

% Calculate emissions from natural gas (global factor)
% Natural gas: 200 g CO₂/kWh from IPCC 2019 Guidelines
% This is direct combustion emissions (scope 1)
naturalGasEmissionFactor = 200;  % g CO₂/kWh
naturalGasEmissions_g = annualNaturalGasKWh * naturalGasEmissionFactor;

% Total home emissions
totalEmissions_g = electricityEmissions_g + naturalGasEmissions_g;

% Convert to kilograms
annualEmissionsCO2e_kg = totalEmissions_g / 1000;

end