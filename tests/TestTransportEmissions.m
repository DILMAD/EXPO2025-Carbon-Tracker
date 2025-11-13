classdef TestTransportEmissions < matlab.unittest.TestCase
    %TESTTRANSPORTEMISSIONS Unit Test
    
    properties (TestParameter)
        testRegion = {'USA', 'Europe', 'Asia', 'Global'}
    end
    
    methods(Test)
        
        function testZeroInputsReturnZero(testCase)
            emissions = calculateTransportEmissions('Global', 'Car_Gasoline', ...
                0, 0, 0, 0, 0, 0, 0);
            
            testCase.verifyEqual(emissions, 0, ...
                'Zero inputs should produce zero emissions');
        end
        
        function testCarCommuterOnlyEmissions(testCase)
            emissions = calculateTransportEmissions('Global', 'Car_Gasoline', ...
                20, 250, 0, 0, 0, 0, 0);
            
            expectedEmissions = 1640.0;  % kg CO₂
            
            testCase.verifyEqual(emissions, expectedEmissions, 'RelTol', 0.01, ...
                'Car commute-only emissions should match calculation: 20km×2×250days×164g/km');
        end
        
        function testFlightOnlyEmissions(testCase)
            emissions = calculateTransportEmissions('Global', 'Car_Gasoline', ...
                0, 0, 2, 1500, 1, 8000, 0);
            
            % 2 domestic: 2×2×1500×156 = 936,000 g
            % 1 intl: 1×2×8000×147 = 2,352,000 g
            % Total: 3,288,000 g = 3,288 kg
            expectedEmissions = 3288.0;
            
            testCase.verifyEqual(emissions, expectedEmissions, 'RelTol', 0.01, ...
                'Flight-only emissions should match calculation');
        end
        
        function testRegionalVariationSameInputs(testCase, testRegion)
            emissions = calculateTransportEmissions(testRegion, 'Car_Gasoline', ...
                15, 240, 1, 1000, 0, 0, 30);
            
            testCase.verifyGreaterThan(emissions, 500, ...
                sprintf('Emissions for %s should be positive and reasonable', testRegion));
            testCase.verifyLessThan(emissions, 3000, ...
                sprintf('Emissions for %s should not be unreasonably high', testRegion));
        end
        
        function testElectricCarRegionalVariation(testCase)
            emissionsNorway = calculateTransportEmissions('Norway', 'Car_Electric_BEV', ...
                20, 250, 0, 0, 0, 0, 40);
            
            emissionsIndia = calculateTransportEmissions('India', 'Car_Electric_BEV', ...
                20, 250, 0, 0, 0, 0, 40);
            
            testCase.verifyLessThan(emissionsNorway, emissionsIndia * 0.5, ...
                'Norway EV emissions should be <50% of India due to clean grid (30 vs 708 gCO2/kWh)');
        end
        
        function testZeroEmissionModes(testCase)
            emissionsWalking = calculateTransportEmissions('Global', 'Walking', ...
                5, 250, 0, 0, 0, 0, 0);
            
            emissionsCycling = calculateTransportEmissions('Global', 'Cycling', ...
                10, 250, 0, 0, 0, 0, 0);
            
            testCase.verifyEqual(emissionsWalking, 0, ...
                'Walking should produce zero emissions when other travel is also zero');
            testCase.verifyEqual(emissionsCycling, 0, ...
                'Cycling should produce zero emissions when other travel is also zero');
        end
        
        function testNegativeInputsThrowError(testCase)
            testCase.verifyError(@() calculateTransportEmissions('Global', ...
                'Car_Gasoline', -10, 250, 0, 0, 0, 0, 0), ...
                'MATLAB:validators:mustBeNonnegative', ...
                'Negative daily commute should throw validation error');
        end
        
        function testInvalidRegionFallsBackToGlobal(testCase)
            % Invalid region should fall back to Global factors (with warning)
            emissions = calculateTransportEmissions('InvalidRegion', 'Car_Gasoline', ...
                20, 250, 0, 0, 0, 0, 0);
            
            % Should still work using Global factors
            testCase.verifyGreaterThan(emissions, 0, ...
                'Invalid region should fall back to Global emission factors');
        end
        
        function testHighValueFrequentFlyer(testCase)
            emissions = calculateTransportEmissions('Global', 'Car_Gasoline', ...
                30, 250, 24, 1200, 6, 10000, 100);
            
            testCase.verifyGreaterThan(emissions, 10000, ...
                'Heavy business traveler should have >10 tons CO2 emissions');
            
            testCase.verifyLessThan(emissions, 50000, ...
                'Even extreme travel should be <50 tons CO2 (sanity check)');
        end
        
        function testPublicTransitCommuter(testCase)
            emissionsTrain = calculateTransportEmissions('Europe', 'Train_Rail', ...
                25, 240, 0, 0, 0, 0, 15);
            
            emissionsBus = calculateTransportEmissions('Europe', 'Bus', ...
                25, 240, 0, 0, 0, 0, 15);
            
            testCase.verifyLessThan(emissionsTrain, 1500, ...
                'Train commuter should have relatively low emissions (<1.5 tons)');
            testCase.verifyLessThan(emissionsBus, 2000, ...
                'Bus commuter should have moderate emissions (<2 tons)');
        end
        
        function testRoundTripCalculation(testCase)
            emissions = calculateTransportEmissions('Global', 'Car_Gasoline', ...
                20, 1, 0, 0, 0, 0, 0);
            
            % 20km × 2 (round trip) × 164 g/km = 6,560 g = 6.56 kg
            expectedEmissions = 6.56;
            
            testCase.verifyEqual(emissions, expectedEmissions, 'AbsTol', 0.01, ...
                'Function should correctly calculate round-trip commute emissions');
        end
        
    end
    
    methods(Test, TestTags = {'Integration'})
        
        function testDataFileExists(testCase)
            dataPath = fullfile('..', 'data', 'transportEmissionFactors.csv');
            testCase.verifyTrue(isfile(dataPath), ...
                'transportEmissionFactors.csv must exist in data folder');
        end
        
        function testDataFileStructure(testCase)
            emissionData = readtable(fullfile('..', 'data', 'transportEmissionFactors.csv'));
            
            requiredCols = {'Transport_Mode', 'Vehicle_Type', 'Region', ...
                           'CO2e_Factor_g_per_unit', 'Source', 'Year'};
            
            for i = 1:length(requiredCols)
                testCase.verifyTrue(ismember(requiredCols{i}, emissionData.Properties.VariableNames), ...
                    sprintf('Column %s must exist in CSV', requiredCols{i}));
            end
        end
        
    end
    
    methods(Test, TestTags = {'Documentation'})
        
        function testFunctionHasHelp(testCase)
            helpText = help('calculateTransportEmissions');
            testCase.verifyNotEmpty(helpText, ...
                'Function must have help documentation');
            
            testCase.verifyTrue(contains(helpText, 'INPUTS'), ...
                'Help must document inputs');
            testCase.verifyTrue(contains(helpText, 'OUTPUT'), ...
                'Help must document outputs');
        end
        
        function testFunctionInCorrectLocation(testCase)
            functionPath = which('calculateTransportEmissions');
            testCase.verifyTrue(contains(functionPath, 'functions'), ...
                'Function should be in functions/ directory');
        end
        
    end
    
end