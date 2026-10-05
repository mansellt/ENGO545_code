clear;
clc;
close all;

%% Read data
file1 = 'data/predictions_07735_Vancouver_2026-11-03.csv';
file2 = 'data/predictions_07735_Vancouver_2026-11-10.csv';

opts1 = delimitedTextImportOptions("NumVariables",2);
opts1.DataLines = [2 Inf];
opts1.Delimiter = ",";
opts1.VariableNames = ["Date","TideHeight"];
opts1.VariableTypes = ["string","double"];

T1 = readtable(file1,opts1);
T2 = readtable(file2,opts1);

T = [T1; T2]; %combine tables

T.Date = datetime(T.Date,'InputFormat',"yyyy-MM-dd HH:mm 'PT'");

%% Select desired period
startTime = datetime(2026,11,2,0,0,0);
endTime = datetime(2026,11,16,0,0,0);

idx = T.Date >= startTime & T.Date < endTime;

T_plot = T(idx,:);

%% Plot
figure
hold on
%Bounds
%h < 1.5     66 - 3 -61.5
%h > -0.2    -15 + 5 + 9.8

upperBound = 1.5;
lowerBound = -0.2;

plot(T_plot.Date,T_plot.TideHeight, ...
    'LineWidth',1.2, 'DisplayName','Predicted Tide')

yline(upperBound,'r--', ...
    'LineWidth',1.2, 'DisplayName','Upper Bound')

yline(lowerBound,'g--', ...
    'LineWidth',1.2,'DisplayName','Lower Bound')

legend('show','Location','best')

xlim([startTime endTime])

%% Find time and heights between upper and lower bounds

idx_threshold = T_plot.TideHeight >= lowerBound ...
    & T_plot.TideHeight <= upperBound;

T_between = T_plot(idx_threshold,:);

%% find continuous time intervals
startIdx = find(diff([false; idx_threshold]) == 1);
endIdx   = find(diff([idx_threshold; false]) == -1);

startTimes = T_plot.Date(startIdx); % Extract start and end times
endTimes   = T_plot.Date(endIdx);

durationHours = hours(endTimes - startTimes);
windows = table(startTimes, endTimes, durationHours);

disp(windows)
