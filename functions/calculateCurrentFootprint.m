function footprint = calculateCurrentFootprint(userData)
%CALCULATECURRENTFOOTPRINT Calculate complete carbon footprint from user data
%
%   footprint = CALCULATECURRENTFOOTPRINT(userData)
%
%   Aggregates all emission sources to calculate total footprint
%
%   INPUT:
%       userData - Struct with fields:
%           region, commuteMode, dailyCommuteKm, commuteDays,
%           domesticFlights, avgDomesticFlightKm,
%           internationalFlights, avgInternationalFlightKm,
%           otherTravelKm, monthlyElectricityKWh, monthlyNaturalGasKWh,
%           dietType, streamingHoursPerDay, aiQueriesPerDay,
%           cloudStorageGB, videoCallHoursPerWeek, emailsPerDay,
%           shoppingFrequency, clothingPurchases, electronicsPurchases,
%           furniturePurchases
%
%   OUTPUT:
%       footprint - Struct with emission values in kg CO2e/year:
%           total, transport, home, food, digital, consumption
%           (also in tons for display)

% Calculate transport emissions
transportEmissions = calculateTransportEmissions(...
    userData.region, ...
    userData.commuteMode, ...
    userData.dailyCommuteKm, ...
    userData.commuteDays, ...
    userData.domesticFlights, ...
    userData.avgDomesticFlightKm, ...
    userData.internationalFlights, ...
    userData.avgInternationalFlightKm, ...
    userData.otherTravelKm);

% Calculate home energy emissions
homeEmissions = calculateHomeEmissions(...
    userData.region, ...
    userData.monthlyElectricityKWh * 12, ...
    userData.monthlyNaturalGasKWh * 12);

% Calculate food emissions
foodEmissions = calculateFoodEmissions(userData.dietType);

% Calculate digital emissions
digitalEmissions = calculateDigitalEmissions(...
    userData.streamingHoursPerDay, ...
    userData.aiQueriesPerDay, ...
    userData.cloudStorageGB, ...
    userData.videoCallHoursPerWeek, ...
    userData.emailsPerDay);

% Calculate consumption emissions
consumptionEmissions = calculateConsumptionEmissions(...
    userData.shoppingFrequency, ...
    userData.clothingPurchases, ...
    userData.electronicsPurchases, ...
    userData.furniturePurchases);

% Create footprint struct (in kg)
footprint = struct();
footprint.transport = transportEmissions;
footprint.home = homeEmissions;
footprint.food = foodEmissions;
footprint.digital = digitalEmissions;
footprint.consumption = consumptionEmissions;
footprint.total = transportEmissions + homeEmissions + foodEmissions + ...
                 digitalEmissions + consumptionEmissions;

% Add tons for easier reading
footprint.transportTons = transportEmissions / 1000;
footprint.homeTons = homeEmissions / 1000;
footprint.foodTons = foodEmissions / 1000;
footprint.digitalTons = digitalEmissions / 1000;
footprint.consumptionTons = consumptionEmissions / 1000;
footprint.totalTons = footprint.total / 1000;

% Calculate percentages
footprint.transportPercent = (transportEmissions / footprint.total) * 100;
footprint.homePercent = (homeEmissions / footprint.total) * 100;
footprint.foodPercent = (foodEmissions / footprint.total) * 100;
footprint.digitalPercent = (digitalEmissions / footprint.total) * 100;
footprint.consumptionPercent = (consumptionEmissions / footprint.total) * 100;

end