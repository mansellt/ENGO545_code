
clear; clc; close all;

files = ["data/group2hydro.txt", "data/group2hydrorun2.txt"];
results = table();

for f = 1:numel(files)

    %% Read sonar observations
    lines = readlines(files(f));

    distance = [];
    time = [];

    for i = 1:numel(lines)
        values = sscanf(char(lines(i)), 'D %f %f');

        if numel(values) == 2
            distance(end+1,1) = values(1);
            time(end+1,1) = values(2)/1000;
        end
    end

    % Start time at zero
    time = time - time(1);

    %% Create main graph
    fig = figure('Name', char(files(f)), ...
                 'NumberTitle', 'off');

    ax = axes(fig);

    plot(ax, time, distance, 'k.');
    xlabel(ax, 'Elapsed time (s)');
    ylabel(ax, 'Sonar distance (m)');
    title(ax, "Select stable intervals: " + files(f));
    grid(ax, 'on');
    hold(ax, 'on');

    n = input('How many intervals do you want to select? ');

    %% Select intervals
    for j = 1:n

        % Return focus to main graph
        figure(fig);
        axes(ax);
        drawnow;

        fprintf('\nInterval %d of %d\n', j, n);
        fprintf('Click START and END on the main graph.\n');

        [x,~] = ginput(2);

        t1 = min(x);
        t2 = max(x);

        % Extract selected data
        idx = time >= t1 & time <= t2;
        d = distance(idx);

        if isempty(d)
            warning('No data selected. Skipping interval.');
            continue;
        end

        %% Filter outliers
        med = median(d);
        tolerance = 0.06;

        keep = abs(d - med) <= tolerance;
        cleaned = d(keep);

        if isempty(cleaned)
            warning('No data retained.');
            continue;
        end

        %% Statistics
        avg = mean(cleaned);
        sd = std(cleaned);
        count = numel(cleaned);

        fprintf('Mean: %.4f m\n', avg);
        fprintf('Std: %.4f m\n', sd);
        fprintf('Retained: %d / %d\n', count, numel(d));

        %% Highlight selected interval on main graph
        plot(ax, time(idx), distance(idx), '.', ...
             'Color', [0.8 0.8 0.8]);

        selectedTime = time(idx);
        plot(ax, selectedTime(keep), cleaned, 'b.');

        yline(ax, avg, 'b--');

        xline(ax, t1, 'g--');
        xline(ax, t2, 'r--');

        %% Store results
        newRow = table(f, j, t1, t2, avg, sd, count, ...
            'VariableNames', ...
            {'Run','Interval','Start_s','End_s', ...
             'Mean_m','Std_m','Count'});

        results = [results; newRow];

    end
end

%% Export results
disp(results);
writetable(results, 'filtered_plate_results.csv');

fprintf('\nFiltering complete.\n');
