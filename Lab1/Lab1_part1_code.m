%ENGO545 Lab1
clear all;
clc;

T = readtable('data/tidal_constituents_2025.txt', 'Delimiter','\t');

n = size(T, 1);
m = size(T, 2);

Ho = 6.64; %MSL relative to MLLW, which is tidal the datum for Seattle

t_nov_first72hrs = ((365 + 304)*24:(365 + 304)*24+72)';
t_last61days = [(2*365*24-61*24):(2*365*24)]';
t_2026 = [(365*24):(365*24*2)]';


fi = T.f_2025;
equi = T.V0u_2025_deg;
Hi = T.NOAA_Amplitude_ft;
ki = T.NOAA_Phase_deg;
ai = T.Speed_deg_per_hr;

ht_last61 = calc_h(Ho, fi, Hi, ai, t_last61days, equi, ki); 
ht_nov_first72hrs = calc_h(Ho, fi, Hi, ai, t_nov_first72hrs, equi, ki); 
ht_2026 = calc_h(Ho, fi, Hi, ai, t_2026, equi, ki); 

%% plot
figure;
hold on;
plot(t_nov_first72hrs, ht_nov_first72hrs)
xlabel('Time (hrs)')
ylabel('Height (feet)')
title('Predicted Tidal Height in the First 72 Hours of November 2026')

figure;
hold on;
plot(t_last61days, ht_last61)
xlabel('Time (hrs)')
ylabel('Height (feet)')
title('Predicted Tidal Height in the Last 61 Days of 2026')

figure;
hold on;
plot(t_2026, ht_2026)
xlabel('Time (hrs)')
ylabel('Height (feet)')
title('Predicted Tidal Height 2026')

%% compute range for each period
r_last61 = max(ht_last61) - min(ht_last61)
r_nov_first72hrs = max(ht_nov_first72hrs) - min(ht_nov_first72hrs)
r_2026 = max(ht_2026) - min(ht_2026)

%last 61 days is decent approximation of the range for the entire year.

%% Functions

function ht = calc_h(Ho, fi, Hi, ai, t, equi, ki)
%function that calculates the sum of waves for a given time period
ht = zeros(length(t),1);
    for i=1:length(t)
        hti = fi.*Hi.*cosd(ai.*t(i)+equi-ki);
        ht(i) = Ho + sum(hti);
    end 
end