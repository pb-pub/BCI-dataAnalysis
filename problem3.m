%% HW2: EEG Analysis - Problem 3
% Paul Boutet (Student ID:314551810)

% This script solves Problem 3 of the assignment.
% It first computes all the different preprocessing pipelines on the dataset 
% and then computes the ERPs and SNRs for each pipeline.
% Same as for the other problems, to be able to review the results of the ICAs the
% results are saved to disk as SET and MAT files.

%%  Initialize EEGLAB
clear; close all; clc;

if ~exist('eeglab', 'file')
    warning('EEGLAB not found. Please add EEGLAB to your MATLAB path.');
    addpath('eeglab_current/eeglab2025.1.0/'); 
    if ~exist('eeglab', 'file')
        warning('EEGLAB still not found. Please check the path and try again.');
    end
end
eeglab;             

fprintf('\n--- Starting Problem 3: Analysis of Dataset 2 ---\n');


dataset1_path = 'data/HW2_dataset/S02_Sess05.set'; 
EEG_orig = pop_loadset('filename', dataset1_path);
 

if isempty(EEG)
    error('Dataset 1 failed to load. Check the path: %s', dataset1_path);
end
fprintf('Dataset 1 loaded successfully.\n');
fprintf('Number of channels: %d\n', EEG_orig.nbchan);
fprintf('Sampling rate: %d Hz\n', EEG_orig.srate);

%% Bandpass Filter the Data [1-48] Hz 

EEG_filtered = pop_eegfiltnew(EEG_orig, 1, 48);


%% ICA only
load_ica = false;
if ~load_ica
    tic; 
    EEG_ica = pop_runica(EEG_orig, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');
    ica_time = toc;
    fprintf('ICA computation finished in %.2f seconds.\n', ica_time);
    EEG_ica = iclabel(EEG_ica);

    % Find components noise components with > 70% probability and remove them
    muscle_class_idx = find(strcmp(EEG_ica.etc.ic_classification.ICLabel.classes, 'Muscle'));
    eye_class_idx = find(strcmp(EEG_ica.etc.ic_classification.ICLabel.classes, 'Eye'));
    channel_noise_idx = find(strcmp(EEG_ica.etc.ic_classification.ICLabel.classes, 'Channel Noise'));
    line_noise_idx = find(strcmp(EEG_ica.etc.ic_classification.ICLabel.classes, 'Line Noise'));
    brain_idx = find(strcmp(EEG_ica.etc.ic_classification.ICLabel.classes, 'Brain'));

    noise_components = find( ...
        EEG_ica.etc.ic_classification.ICLabel.classifications(:, muscle_class_idx) > 0.7 | ...
        EEG_ica.etc.ic_classification.ICLabel.classifications(:, eye_class_idx) > 0.7 | ...
        EEG_ica.etc.ic_classification.ICLabel.classifications(:, channel_noise_idx) > 0.7 | ...
        EEG_ica.etc.ic_classification.ICLabel.classifications(:, line_noise_idx) > 0.7 | ...
        EEG_ica.etc.ic_classification.ICLabel.classifications(:, brain_idx) < 0.01 ...
    );
    
    fprintf('Found %d artifactual components to remove.\n', length(noise_components));
    EEG_ica = pop_subcomp(EEG_ica, noise_components, 0);
else
    fprintf('Loading precomputed ICA results from disk...\n');
    [dataPath, dataName, ~] = fileparts(dataset1_path);
    if isempty(dataPath)
        dataPath = pwd; 
    end
    ica_mat_name = fullfile(dataPath, [dataName '_ica_only.mat']);
    if exist(ica_mat_name, 'file')
        loaded_data = load(ica_mat_name);
        EEG_ica = loaded_data.EEG_ica;
        fprintf('Loaded ICA results from %s\n', ica_mat_name);
    else
        error('Precomputed ICA results not found at %s. Please run ICA computation.', ica_mat_name);
    end
end

%% Save ICA results to disk (SET and MAT) 
fprintf('\n--- Saving ICA results to disk for all pipelines... ---\n');
try
    [dataPath, dataName, ~] = fileparts(dataset1_path);
    if isempty(dataPath)
        dataPath = pwd; 
    end
    % Save ICA only results
    ica_set_name = [dataName '_ica_only.set'];
    pop_saveset(EEG_ica, 'filename', ica_set_name, 'filepath', dataPath);
    ica_mat_name = fullfile(dataPath, [dataName '_ica_only.mat']);
    save(ica_mat_name, 'EEG_ica');
    fprintf('Saved ICA only .set to %s and .mat to %s\n', fullfile(dataPath, ica_set_name), ica_mat_name);
catch ME
    warning(ME.identifier, 'Failed to save ICA results: %s', ME.message);
end



%% Bandpass + ICA
load_ica_filtered = false;
if ~load_ica_filtered
    tic;
    EEG_filtered_ica = pop_runica(EEG_filtered, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');
    ica_filtered_time = toc;
    fprintf('ICA computation finished in %.2f seconds.\n', ica_filtered_time);
    EEG_filtered_ica = iclabel(EEG_filtered_ica);

    % Find components noise components with > 70% probability and remove them
    muscle_class_idx = find(strcmp(EEG_filtered_ica.etc.ic_classification.ICLabel.classes, 'Muscle'));
    eye_class_idx = find(strcmp(EEG_filtered_ica.etc.ic_classification.ICLabel.classes, 'Eye'));
    channel_noise_idx = find(strcmp(EEG_filtered_ica.etc.ic_classification.ICLabel.classes, 'Channel Noise'));
    line_noise_idx = find(strcmp(EEG_filtered_ica.etc.ic_classification.ICLabel.classes, 'Line Noise'));
    brain_idx = find(strcmp(EEG_filtered_ica.etc.ic_classification.ICLabel.classes, 'Brain'));

    noise_components = find( ...
        EEG_filtered_ica.etc.ic_classification.ICLabel.classifications(:, muscle_class_idx) > 0.7 | ...
        EEG_filtered_ica.etc.ic_classification.ICLabel.classifications(:, eye_class_idx) > 0.7 | ...
        EEG_filtered_ica.etc.ic_classification.ICLabel.classifications(:, channel_noise_idx) > 0.7 | ...
        EEG_filtered_ica.etc.ic_classification.ICLabel.classifications(:, line_noise_idx) > 0.7 | ...
        EEG_filtered_ica.etc.ic_classification.ICLabel.classifications(:, brain_idx) < 0.01 ...
    );

    fprintf('Found %d artifactual components to remove.\n', length(noise_components));
    EEG_filtered_ica = pop_subcomp(EEG_filtered_ica, noise_components, 0);
else
    fprintf('Loading precomputed filtered + ICA results from disk...\n');
    [dataPath, dataName, ~] = fileparts(dataset1_path);
    if isempty(dataPath)
        dataPath = pwd; 
    end
    ica_mat_name = fullfile(dataPath, [dataName '_filtered_ica.mat']);
    if exist(ica_mat_name, 'file')
        loaded_data = load(ica_mat_name);
        EEG_filtered_ica = loaded_data.EEG_filtered_ica;
        fprintf('Loaded filtered + ICA results from %s\n', ica_mat_name);
    else
        error('Precomputed filtered + ICA results not found at %s. Please run ICA computation.', ica_mat_name);
    end
end

%% Save filtered + ICA results to disk (SET and MAT) for all pipelines
fprintf('\n--- Saving filtered + ICA results to disk for all pipelines... ---\n');
try
    [dataPath, dataName, ~] = fileparts(dataset1_path);
    if isempty(dataPath)
        dataPath = pwd; 
    end
    % Save ICA only results
    ica_set_name = [dataName '_filtered_ica.set'];
    pop_saveset(EEG_filtered_ica, 'filename', ica_set_name, 'filepath', dataPath);
    ica_mat_name = fullfile(dataPath, [dataName '_filtered_ica.mat']);
    save(ica_mat_name, 'EEG_filtered_ica');
    fprintf('Saved ICA only .set to %s and .mat to %s\n', fullfile(dataPath, ica_set_name), ica_mat_name);
catch ME
    warning(ME.identifier, 'Failed to save filtered + ICA results: %s', ME.message);
end


%% Processing and ERP/SNR Calculation

EEG = [EEG_orig, EEG_filtered, EEG_ica, EEG_filtered_ica];

CORRECT_FEEDBACK_MARKER = {'FeedBack_correct'};
ERROR_FEEDBACK_MARKER   = {'FeedBack_wrong'};
pipelines = {'No Filter', 'Bandpass filtering [1-48] Hz', 'IC removal', 'Bandpass + IC removal'};


for eegset_idx = 1:length(EEG)
    fprintf('\n--- Processing EEG dataset %d ---\n', eegset_idx);
    EEG_current = EEG(eegset_idx);
    current_pipeline = pipelines{eegset_idx};
    
    % --- Epoching ---
    fprintf('\n--- Epoching data from -0.2 to 1.3 seconds... ---\n');
    EEG_current = pop_epoch(EEG_current, [CORRECT_FEEDBACK_MARKER, ERROR_FEEDBACK_MARKER], [-0.2  1.3], 'epochinfo', 'yes');
    
    % --- Baseline Correction ---
    fprintf('Removing baseline mean (-200 to 0 ms)...\n');
    EEG_current = pop_rmbase(EEG_current, [-200 0], []);

       
    % --- Find the index of the target channel (FCz) ---
    fprintf('Finding index of channel %s...\n', 'FCz');
    fcz_idx = find(strcmp({EEG_current.chanlocs.labels}, 'FCz'));
    if isempty(fcz_idx)
        error('FATAL: Channel FCz not found in the dataset!');
    end

    % --- Separate datasets for error and correct trials ---
    fprintf('Separating trials for error and correct feedback...\n');
    EEG_error = pop_selectevent(EEG_current, 'type', ERROR_FEEDBACK_MARKER, 'deleteevents', 'on');
    EEG_correct = pop_selectevent(EEG_current, 'type', CORRECT_FEEDBACK_MARKER, 'deleteevents', 'on');

    % --- Calculate the average ERP (the mean across all trials for each condition) ---
    fprintf('Calculating average ERPs for error and correct feedback...\n');
    erp_error = mean(EEG_error.data(fcz_idx, :, :), 3);
    erp_correct = mean(EEG_correct.data(fcz_idx, :, :), 3);

    % --- Plot the ERPs ---
    fprintf('Plotting ERPs...\n');
    figure('Name', sprintf('ERP at %s - Pipeline: %s', 'FCz', current_pipeline), 'NumberTitle', 'off');
    plot(EEG_current.times, erp_correct, 'b', 'LineWidth', 1.5);
    hold on;
    plot(EEG_current.times, erp_error, 'r', 'LineWidth', 1.5);
    grid on;
    xlabel('Time (ms)');
    ylabel('Amplitude (µV)');
    title(sprintf('ERPs at %s (%s)', 'FCz', strrep(current_pipeline, '_', ' ')));
    legend('Correct Feedback', 'Error Feedback');
    ax = gca;
    ax.FontSize = 12;

    % --- Calculate and display SNR for the error feedback ERP ---
    fprintf('Calculating SNR for error feedback ERP...\n');
    % Find time indices for pre-stimulus and post-stimulus intervals
    pre_stim_indices = find(EEG_current.times >= -200 & EEG_current.times <= 0);
    post_stim_indices = find(EEG_current.times >= 0 & EEG_current.times <= 1000);
    
    % Calculate noise = std dev of the pre-stimulus ERP waveform
    noise_std = std(erp_error(pre_stim_indices));
    
    % Calculate signal = peak amplitude of the post-stimulus ERP waveform
    % The peak is the maximum absolute deviation from the baseline.
    peak_amp = max(abs(erp_error(post_stim_indices)));
    snr_value = peak_amp / noise_std;
    
    fprintf('\n--- RESULTS FOR PIPELINE: %s ---\n', current_pipeline);
    fprintf('Peak Amplitude (0-1000ms): %.4f µV\n', peak_amp);
    fprintf('Noise STD (-200-0ms): %.4f µV\n', noise_std);
    fprintf('SNR (Error Feedback Only): %.4f\n', snr_value);
    fprintf('-------------------------------------\n');

end