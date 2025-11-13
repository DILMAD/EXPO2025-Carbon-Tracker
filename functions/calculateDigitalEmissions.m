function annualEmissionsCO2e_kg = calculateDigitalEmissions(streamingHoursPerDay, ...
    aiQueriesPerDay, cloudStorageGB, videoCallHoursPerWeek, emailsPerDay)
%CALCULATEDIGITALEMISSIONS Calculate annual CO₂-equivalent emissions from digital activities
%
%   annualEmissionsCO2e_kg = CALCULATEDIGITALEMISSIONS(streamingHoursPerDay,
%       aiQueriesPerDay, cloudStorageGB, videoCallHoursPerWeek, emailsPerDay)
%
%   Calculates carbon dioxide equivalent emissions in kilograms from digital
%   activities including streaming, AI usage, cloud storage, video calls, and email.
%   Emissions include data center energy, network transmission, and device usage.
%
%   INPUTS:
%       streamingHoursPerDay   - Video streaming hours per day (Netflix, YouTube, etc.)
%       aiQueriesPerDay        - AI model queries per day (ChatGPT, Copilot, etc.)
%       cloudStorageGB         - Total cloud storage used (GB)
%       videoCallHoursPerWeek  - Video conferencing hours per week (Zoom, Teams, etc.)
%       emailsPerDay           - Emails sent + received per day
%
%   OUTPUT:
%       annualEmissionsCO2e_kg - Total annual CO₂-equivalent emissions (kg)
%
%   EMISSION FACTORS:
%       Video streaming:  55 g CO₂/hour (HD quality, includes data centers + network)
%       AI queries:       10 g CO₂/query (large language model like GPT-4)
%       Cloud storage:    0.2 g CO₂/GB/year (annual storage + cooling)
%       Video calls:      150 g CO₂/hour (higher bandwidth than streaming)
%       Email:            4 g CO₂/email (average including attachments)
%
%   CONTEXT:
%       Digital emissions typically represent 2-5% of total personal footprint.
%       However, global digital infrastructure accounts for ~4% of global emissions
%       and is growing rapidly with AI and streaming adoption.
%
%       Data centers are becoming more efficient, but total usage is growing faster.
%       Streaming in 4K vs SD can increase emissions by 4-8x per hour.
%
%   SOURCES:
%       - IEA Digitalization & Energy Report 2024
%       - Shift Project: "Lean ICT" Report 2019
%       - Carbon Trust: Carbon Impact of Video Streaming
%       - University of Massachusetts Amherst: Energy and Policy Considerations 
%         for Deep Learning in NLP (2019)
%
%   EXAMPLE:
%       % Typical remote worker
%       emissions = calculateDigitalEmissions(2, 10, 100, 10, 50);
%       fprintf('Annual digital emissions: %.1f kg CO₂e\n', emissions);
%
%       % Heavy user
%       emissions = calculateDigitalEmissions(6, 50, 500, 20, 100);
%       fprintf('Heavy digital user: %.1f kg CO₂e\n', emissions);
%
%   See also: calculateTransportEmissions, calculateHomeEmissions

% Input validation
arguments
    streamingHoursPerDay (1,1) double {mustBeNonnegative}
    aiQueriesPerDay (1,1) double {mustBeNonnegative, mustBeInteger}
    cloudStorageGB (1,1) double {mustBeNonnegative}
    videoCallHoursPerWeek (1,1) double {mustBeNonnegative}
    emailsPerDay (1,1) double {mustBeNonnegative, mustBeInteger}
end

% Emission factors (g CO₂ per unit)
streamingFactor = 55;     % g CO₂/hour (HD streaming)
aiFactor = 10;            % g CO₂/query (LLM inference)
storageFactor = 0.2;      % g CO₂/GB/year
videoCallFactor = 150;    % g CO₂/hour (higher bandwidth)
emailFactor = 4;          % g CO₂/email

% Calculate annual emissions for each component (in grams)
streamingEmissions_g = streamingHoursPerDay * 365 * streamingFactor;
aiEmissions_g = aiQueriesPerDay * 365 * aiFactor;
storageEmissions_g = cloudStorageGB * storageFactor;
videoCallEmissions_g = videoCallHoursPerWeek * 52 * videoCallFactor;
emailEmissions_g = emailsPerDay * 365 * emailFactor;

% Total emissions
totalEmissions_g = streamingEmissions_g + aiEmissions_g + storageEmissions_g + ...
                   videoCallEmissions_g + emailEmissions_g;

% Convert to kilograms
annualEmissionsCO2e_kg = totalEmissions_g / 1000;

end