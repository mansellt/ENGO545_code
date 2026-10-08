%Lab2 Part 1

% ENGO 545 - Lab 2 Part 1
clear;
clc;
close all;

T = readtable('Data/ENGO545_Lab2_data.csv');

depth = T.Depth;
temp = T.Temperature;
salinity = T.Salinity;

%% 1
%Plot Temperature and Salinity vs Depth
%Temp Profile
figure;
plot(temp, depth, '-o', 'LineWidth', 1.2);
set(gca, 'YDir', 'reverse');
xlabel('Temperature (°C)');
ylabel('Depth (m)');
title('Temperature Profile');
grid on;

%Salinity Profile
figure;
plot(salinity, depth, '-o', 'LineWidth', 1.2);
set(gca, 'YDir', 'reverse');
xlabel('Salinity (ppt)');
ylabel('Depth (m)');
title('Salinity Profile');
grid on;

%% 2
% Calculate Speed of Sound
% Mackenzie Equation (1981)

c = 1448.96 ...
    + 4.591*temp ...
    - 5.304e-2*temp.^2 ...
    + 2.374e-4*temp.^3 ...
    + 1.340*(salinity - 35) ...
    + 1.630e-2*depth ...
    + 1.675e-7*depth.^2 ...
    - 1.025e-2*temp.*(salinity - 35) ...
    - 7.139e-13*temp.*depth.^3;

%Or maybe use this equation
%{
c = 1449.2 ...
    + 4.6*temp ...
    - 5.5e-2*temp.^2 ...
    + 2.9e-4*temp.^3 ...
    + (1.34 - 1.0e-2*temp).*(salinity - 35) ...
    + 1.6e-2*depth;
%}

% Display results
results = table(depth, temp, salinity, c, ...
    'VariableNames', {'Depth_m', 'Temperature_C', ...
                      'Salinity_ppt', 'SoundSpeed_mps'});

disp(results);

%% 3
% Plot Sound Velocity Profile

figure;
plot(c, depth, '-o', 'LineWidth', 1.2);
set(gca, 'YDir', 'reverse');
xlabel('Sound Speed (m/s)');
ylabel('Depth (m)');
title('Sound Velocity Profile (SVP)');
grid on;

%% 4
%estimate the survey depth

close all


%% 4
% Estimate surveyed depths using constant velocity layers

TWTT = [0.22 0.43 0.56 0.67 0.86]';
transducerDepth = 3.2;

t_obs = TWTT / 2; % Convert two-way travel time to one-way travel time
di = diff(depth); % Calculate thickness of each layer
di(1) = di(1) - transducerDepth; % Account for transducer depth
ci = c(1:end-1); % Assume constant sound speed using the top of each layer
ti = di ./ ci; % Calculate travel time through each layer
t_total = cumsum(ti); % Accumulate travel time

% Calculate estimated depths
D = zeros(length(t_obs),1);

for j = 1:length(t_obs)

    i = find(t_total >= t_obs(j), 1);  % Find layer where travel time is reached
    % Time before entering final layer
    if i == 1
        t_previous = 0;
    else
        t_previous = t_total(i-1);
    end

    D(j) = depth(i) + ci(i)*(t_obs(j) - t_previous); % Calculate total depth

end

disp(table(TWTT,D))