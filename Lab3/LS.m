
clear; clc; close all;

%% Load filtered data
T = readtable('filtered_plate_results.csv');

%% Calculate uncertainty of each interval mean
% Std_m = standard deviation of individual observations
% Count = number of observations retained

T.StdMean_m = T.Std_m ./ sqrt(T.Count);

%% Average down and up observations for each run
runs = unique(T.Run);
results = table();

for r = runs'

    % Select observations for this run
    data = T(T.Run == r, :);
    data = sortrows(data, 'Interval');

    % Down observations (1-7)
    down = data.Mean_m(1:7);
    sd_down = data.StdMean_m(1:7);

    % Up observations (8-14), reversed
    up = flipud(data.Mean_m(8:14));
    sd_up = flipud(data.StdMean_m(8:14));

    %% Average down and up
    avg = (down + up)/2;

    % Propagate variances
    sd_avg = sqrt(sd_down.^2 + sd_up.^2)/2;

    %% Store results
    R = table(repmat(r,7,1), (1:7)', ...
        down, up, avg, sd_avg, ...
        'VariableNames', ...
        {'Run','Interval','Down_m','Up_m', ...
         'Average_m','StdAverage_m'});

    results = [results; R];

end

%% Display individual run results
disp('Down and Up Averages with Standard Deviations:');
disp(results);

%% Average Run 1 and Run 2
run1 = results(results.Run == 1, :);
run2 = results(results.Run == 2, :);

run1 = sortrows(run1, 'Interval');
run2 = sortrows(run2, 'Interval');

avg1 = run1.Average_m;
avg2 = run2.Average_m;

sd1 = run1.StdAverage_m;
sd2 = run2.StdAverage_m;

%% Final average
finalAvg = (avg1 + avg2)/2;

% Final variance propagation
finalStd = sqrt(sd1.^2 + sd2.^2)/2;

%% Final results table
finalResults = table(run1.Interval, ...
    avg1, avg2, finalAvg, finalStd, ...
    'VariableNames', ...
    {'Interval','Run1_m','Run2_m', ...
     'FinalAverage_m','FinalStd_m'});

%% Display final results
disp('Final Averaged Sonar Distances:');
disp(finalResults);

%% Export results
writetable(results, 'averaged_plate_results.csv');
writetable(finalResults, 'final_plate_results.csv');
