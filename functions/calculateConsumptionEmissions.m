function annualEmissionsCO2e_kg = calculateConsumptionEmissions(shoppingFrequency, ...
    clothingPurchases, electronicsPurchases, furniturePurchases)
%CALCULATECONSUMPTIONEMISSIONS Calculate annual CO₂-equivalent emissions from consumption
%
%   annualEmissionsCO2e_kg = CALCULATECONSUMPTIONEMISSIONS(shoppingFrequency,
%       clothingPurchases, electronicsPurchases, furniturePurchases)
%
%   Calculates carbon dioxide equivalent emissions in kilograms from consumer
%   purchases including clothing, electronics, furniture, and general goods.
%   Includes embodied emissions from manufacturing, transport, and packaging.
%
%   INPUTS:
%       shoppingFrequency     - Overall shopping pattern (string):
%                               'minimal'  : Buy only necessities, repair/reuse
%                               'moderate' : Average consumer purchasing
%                               'frequent' : Regular shopping, fast fashion
%       clothingPurchases     - New clothing items per year (integer)
%       electronicsPurchases  - New electronic devices per year (integer)
%       furniturePurchases    - Large furniture items per year (integer)
%
%   OUTPUT:
%       annualEmissionsCO2e_kg - Total annual CO₂-equivalent emissions (kg)
%
%   EMISSION FACTORS:
%       Base consumption (kg CO₂/year):
%         - Minimal:  800  (repair > replace, minimal new purchases)
%         - Moderate: 1,500 (typical consumer)
%         - Frequent: 2,500 (fast fashion, regular upgrades)
%
%       Additional items:
%         - Clothing item:  20 kg CO₂ (includes manufacturing, transport)
%         - Electronics:    200 kg CO₂ (smartphone/tablet average)
%         - Furniture:      300 kg CO₂ (large item like sofa/bed)
%
%   KEY INSIGHTS:
%       - Manufacturing accounts for 70-90% of product lifecycle emissions
%       - Fast fashion: A t-shirt = 7 kg CO₂, jeans = 33 kg CO₂
%       - Smartphone production = 50-80 kg CO₂ (more than a year of charging)
%       - Extending device life by 1 year reduces emissions by 25%
%       - Buying used/refurbished reduces emissions by 70-90%
%
%   SOURCES:
%       - Ellen MacArthur Foundation: Circular Economy Reports
%       - WRAP UK: Valuing Our Clothes Report
%       - Apple Environmental Report 2024 (product lifecycle emissions)
%       - Journal of Cleaner Production: Lifecycle Assessment Studies
%
%   EXAMPLE:
%       % Moderate consumer
%       emissions = calculateConsumptionEmissions('moderate', 10, 1, 0);
%       fprintf('Annual consumption emissions: %.1f kg CO₂e\n', emissions);
%
%       % Minimal consumer (repair > replace)
%       emissions = calculateConsumptionEmissions('minimal', 3, 0, 0);
%       fprintf('Minimal consumer: %.1f kg CO₂e\n', emissions);
%
%   See also: calculateTransportEmissions, calculateFoodEmissions

% Input validation
arguments
    shoppingFrequency (1,1) string {mustBeMember(shoppingFrequency, ...
        ["minimal", "moderate", "frequent"])}
    clothingPurchases (1,1) double {mustBeNonnegative, mustBeInteger}
    electronicsPurchases (1,1) double {mustBeNonnegative, mustBeInteger}
    furniturePurchases (1,1) double {mustBeNonnegative, mustBeInteger}
end

% Base consumption emission factors (kg CO₂/year)
baseEmissionFactors = dictionary();
baseEmissionFactors("minimal") = 800;   % Repair, reuse, minimal new
baseEmissionFactors("moderate") = 1500; % Average consumer
baseEmissionFactors("frequent") = 2500; % Fast fashion, regular upgrades

% Additional item emission factors (kg CO₂ per item)
clothingFactor = 20;      % Average clothing item (t-shirt to jacket)
electronicsFactor = 200;  % Average device (phone, tablet, laptop)
furnitureFactor = 300;    % Large furniture item (sofa, bed, desk)

% Calculate base emissions from shopping frequency
baseEmissions = baseEmissionFactors(shoppingFrequency);

% Calculate additional emissions from specific purchases
clothingEmissions = clothingPurchases * clothingFactor;
electronicsEmissions = electronicsPurchases * electronicsFactor;
furnitureEmissions = furniturePurchases * furnitureFactor;

% Total consumption emissions
annualEmissionsCO2e_kg = baseEmissions + clothingEmissions + ...
                         electronicsEmissions + furnitureEmissions;

end