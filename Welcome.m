%[text] # **Hack Your Carbon Impact: Build and Publish an Emissions Tracker with MATLAB**
%[text] **Welcome to this workshop at MATLAB EXPO 2025!**
%[text] Climate change is one of the greatest engineering challenges of our time. In this hands-on workshop with MATLAB, you'll build practical tools to measure, analyze, and generate an action plan that can help you reduce your carbon emissions.
%[text] **No climate science/tech background required**, just curiosity and a willingness to make an impact. 
%[text] ### **Workshop Goals**
%[text] By the end of this workshop, you will:
%[text] - Calculate carbon footprints across transport, home, food, and lifestyle
%[text] - Understand regional differences in emission intensity
%[text] - Use an interactive web app for climate action planning
%[text] - Publish your work to GitHub to share with the world
%[text] - Learn how engineering drives climate tech solutions \
%[text] **Setup Check:** First, we'll make sure your environment is ready. 
  %[control:button:5e24]{"position":[1,2]}
%[text] 
% Check current directory
currentDir = pwd;
fprintf('Current Directory: %s\n', currentDir); %[output:9223a35c]
% Add all project folders to MATLAB path
addpath(genpath(pwd));
fprintf('Project folders added to MATLAB path\n'); %[output:2981979e]
% Check if key data files exist
dataFiles = {'data/regionalAverages.csv', 'data/transportEmissionFactors.csv', 'data/actionLibrary.csv'};
allDataPresent = true;
for i = 1:length(dataFiles)
    if ~isfile(dataFiles{i})
        fprintf('Missing: %s\n', dataFiles{i});
        allDataPresent = false;
    end
end

if allDataPresent %[output:group:7733f39f]
    fprintf('Workshop workspace ready\n'); %[output:76d5d5e5]
end %[output:group:7733f39f]
cd exercises
%%
%[text] ### Workshop Structure and Quick Navigation
%[text] This workshop consists of 5 progressive exercises:
%[text] #### Exercise 1: Transport Emissions Calculator
%[text] Build a function to calculate travel emissions. Work on Exercise 1 using:
  %[control:button:25e3]{"position":[1,2]}
open('Ex1_BuildTransportFunction.m')
%%
%[text] #### Exercise 2: Personal Carbon Footprint
%[text] Calculate YOUR complete emissions story. Work on Exercise 2 using: 
  %[control:button:0588]{"position":[1,2]}
open('Ex2_PersonalImpactStory.m')
%%
%[text] #### Exercise 3: Publishing to GitHub 
%[text] Share your work with the world. Work on Exercise 3 using:
  %[control:button:2635]{"position":[1,2]}
open('Ex3_PublishToGitHub.m')
%%
%[text] #### Exercise 4: Interactive Action Tracker 
%[text] Use a web app for reduction planning. Work on Exercise 4 using: 
  %[control:button:9121]{"position":[1,2]}
open('Ex4_CarbonActionTracker.m')
Ex4_CarbonActionTracker %[output:8cf916f2]
%%
%[text] #### Exercise 5: Simscape Example
%[text] Work on Exercise 5 using [this link.](file:./exercises/Ex5_SimscapeExample.m)
%[text] 
%[text] ## Workshop Tips
%[text] **Best Practices:**
%[text] - Work at your own pace: Exercises are modular and self-contained
%[text] - Run every code cell: Learning happens by doing!
%[text] - Customize with YOUR context: Make it personal and relevant
%[text] - Share your results: GitHub is for showing off! \
%[text] **Common Issues:**
%[text] - If an exercise doesn't run, check you're in the correct directory
%[text] - Missing functions? Make sure you're in the project root
%[text] - Git authentication? Use a Personal Access Token from GitHub settings \
%[text] ### Acknowledgments
%[text] This workshop made possible by MathWorks and the MATLAB EXPO 2025!
%[text] Special thanks to data providers:
%[text] - Ember (Global Electricity Review)
%[text] - Our World in Data (Carbon & Energy Database)
%[text] - IPCC (Emission Factor Database)
%[text] - UK DEFRA (GHG Conversion Factors) \
%[text] **License & Usage**
%[text] Workshop Materials: © 2025 MathWorks, Inc. All rights reserved. Educational use permitted with attribution.
%[text] Code you write is yours! Share it under any open-source license.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"hidecode","rightPanelPercent":6.1}
%---
%[control:button:5e24]
%   data: {"label":"RUN THIS FIRST","run":"SectionAndStaleSectionsAbove"}
%---
%[control:button:25e3]
%   data: {"label":"Start Exercise 1","run":"Section"}
%---
%[control:button:0588]
%   data: {"label":"Start Exercise 2","run":"Section"}
%---
%[control:button:2635]
%   data: {"label":"Start Exercise 3","run":"Section"}
%---
%[control:button:9121]
%   data: {"label":"Start Exercise 4","run":"Section"}
%---
%[output:9223a35c]
%   data: {"dataType":"text","outputData":{"text":"Current Directory: \/MATLAB Drive\/MATLAB_EXPO_2025_CarbonImpact\n","truncated":false}}
%---
%[output:2981979e]
%   data: {"dataType":"text","outputData":{"text":"Project folders added to MATLAB path\n","truncated":false}}
%---
%[output:76d5d5e5]
%   data: {"dataType":"text","outputData":{"text":"Workshop workspace ready\n","truncated":false}}
%---
%[output:8cf916f2]
%   data: {"dataType":"text","outputData":{"text":"Carbon Action Tracker started successfully.\nLoading interface...\n\n","truncated":false}}
%---
