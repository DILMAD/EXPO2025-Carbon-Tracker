function annualEmissionsCO2e_kg = calculateFoodEmissions(dietType)
%CALCULATEFOODEMISSIONS Calculate annual CO₂-equivalent emissions from diet
%
%   annualEmissionsCO2e_kg = CALCULATEFOODEMISSIONS(dietType)
%
%   Calculates carbon dioxide equivalent emissions in kilograms from annual
%   food consumption based on dietary pattern. Includes lifecycle emissions
%   from production, processing, transportation, and waste.
%
%   INPUTS:
%       dietType - Dietary pattern (string):
%                  'meat-heavy' : High consumption of beef, pork, poultry
%                  'balanced'   : Omnivore with moderate meat consumption
%                  'vegetarian' : No meat, includes dairy and eggs
%                  'vegan'      : Plant-based only, no animal products
%
%   OUTPUT:
%       annualEmissionsCO2e_kg - Total annual CO₂-equivalent emissions (kg)
%
%   EMISSION FACTORS (kg CO₂e per year):
%       Meat-heavy diet:  2,500 kg/year (6.85 kg/day)
%       Balanced diet:    1,800 kg/year (4.93 kg/day)
%       Vegetarian diet:  1,200 kg/year (3.29 kg/day)
%       Vegan diet:       1,000 kg/year (2.74 kg/day)
%
%   KEY INSIGHTS:
%       - Beef/lamb have highest emissions: 60-100 kg CO₂/kg meat
%       - Chicken/pork: 6-7 kg CO₂/kg meat
%       - Plant-based proteins: 0.5-2 kg CO₂/kg
%       - Dairy: 2-8 kg CO₂/kg depending on product
%       - Switching from meat-heavy to balanced reduces emissions by 28%
%       - Switching to vegetarian reduces emissions by 52%
%       - Switching to vegan reduces emissions by 60%
%
%   SOURCES:
%       - Poore & Nemecek (2018), "Reducing food's environmental impacts 
%         through producers and consumers", Science
%       - Our World in Data: Environmental Impacts of Food Production
%       - IPCC AR6 Working Group III Chapter 5 (Food Systems)
%       - Oxford Martin School: Future of Food Report
%
%   EXAMPLE:
%       % Compare different dietary patterns
%       diets = {'meat-heavy', 'balanced', 'vegetarian', 'vegan'};
%       for i = 1:length(diets)
%           emissions = calculateFoodEmissions(diets{i});
%           fprintf('%s diet: %.1f kg CO₂e/year (%.2f tons)\n', ...
%               diets{i}, emissions, emissions/1000);
%       end
%
%   See also: calculateTransportEmissions, calculateHomeEmissions

% Input validation
arguments
    dietType (1,1) string {mustBeMember(dietType, ...
        ["meat-heavy", "balanced", "vegetarian", "vegan"])}
end

% Emission factors based on lifecycle analysis from Poore & Nemecek (2018)
% and aggregated data from Our World in Data
dietEmissionFactors = dictionary();

% Meat-heavy diet: ~70% of calories from animal products
% High beef/lamb consumption, daily meat, high dairy
dietEmissionFactors("meat-heavy") = 2500;  % kg CO₂e/year

% Balanced omnivore diet: ~30% calories from animal products
% Moderate meat (mostly chicken/pork), some beef, moderate dairy
dietEmissionFactors("balanced") = 1800;  % kg CO₂e/year

% Vegetarian diet: No meat, includes dairy and eggs
% ~15% calories from dairy/eggs, rest from plants
dietEmissionFactors("vegetarian") = 1200;  % kg CO₂e/year

% Vegan diet: Plant-based only
% All calories from plant sources (grains, legumes, vegetables, fruits)
dietEmissionFactors("vegan") = 1000;  % kg CO₂e/year

% Return annual emissions
annualEmissionsCO2e_kg = dietEmissionFactors(dietType);

end