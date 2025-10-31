%% HW2: EEG Analysis - Problem 1
% Paul Boutet (Student ID:314551810)

% This script solves Problem 1-1 and 1-2 of the assignment.

%%  SETUP: Initialize EEGLAB
clear; close all; clc;

if ~exist('eeglab', 'file')
    warning('EEGLAB not found. Please add EEGLAB to your MATLAB path.');
    addpath('eeglab_current/eeglab2025.1.0/'); 
    if ~exist('eeglab', 'file')
        warning('EEGLAB still not found. Please check the path and try again.');
    end
end
eeglab; 


%%  PROBLEM 1-1: Analysis of Dataset 1

fprintf('\n--- Starting Problem 1-1: Analysis of Dataset 1 ---\n');


dataset1_path = 'data/HW2_dataset/S02_Sess05.set'; 
EEG_orig = pop_loadset('filename', dataset1_path);
EEG = EEG_orig; 

% Check if data was loaded correctly
if isempty(EEG)
    error('Dataset 1 failed to load. Check the path: %s', dataset1_path);
end
fprintf('Dataset 1 loaded successfully.\n');
fprintf('Number of channels: %d\n', EEG.nbchan);
fprintf('Sampling rate: %d Hz\n', EEG.srate);


% --- Plot 2D channel location map ---
fprintf('\n--- Plotting 2D channel location map... ---\n');
figure;
topoplot([], EEG.chanlocs, 'style', 'blank', 'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
title('Problem 1-1: 2D Channel Location Map for Dataset 1');
set(gcf, 'Name', 'P1-1: Channel Map');


% --- Run ICA and record computational time ---
fprintf('\n--- Running ICA. This may take a few minutes... ---\n');
tic; 
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');
ica_time = toc;
fprintf('ICA computation finished in %.2f seconds.\n', ica_time);


% --- Plot component maps in 2D ---
fprintf('\n--- Plotting component maps... ---\n');
pop_topoplot(EEG, 0, [1:EEG.nbchan], 'Problem 1-1: ICA Component Maps', [], 'electrodes', 'off');
set(gcf, 'Name', 'P1-1: ICA Component Maps');


% --- Noise components ---
% This step requires you to visually inspect the component maps from Step 3
% and their properties (e.g., time series, power spectra) to identify artifacts.
%
% WHAT TO LOOK FOR in your report's explanation:
%   - Eye Blinks: Strong frontal activity, often a single large red blob.
%   - Horizontal Eye Movements: Dipole activity (red/blue) at the far frontal/temporal channels.
%   - Muscle Artifacts (EMG): High-frequency activity, often localized to a single
%     electrode or a small patch on the periphery (e.g., temporal or neck).
%   - Line Noise: Very sharp peak at 50/60 Hz in the power spectrum.

components_to_remove = []; 

fprintf('S\n--- Manual identification of artifact components. ---\n');
if isempty(components_to_remove)
    fprintf('WARNING: No components selected for removal. The "after" plot will be identical to the "before" plot.\n');
    fprintf('Please inspect the component maps and update the `components_to_remove` variable.\n');
else
    fprintf('Components selected for removal: %s\n', num2str(components_to_remove));
end


% --- Plot data before and after deleting noise components ---
fprintf('\n--- Plotting data before and after artifact removal... ---\n');

figure;
pop_eegplot(EEG_orig, 1, 1, 1);
title('Problem 1-1: Data BEFORE ICA Artifact Removal (First 10 seconds)');
set(findobj('Tag','EEGLAB'), 'Name', 'P1-1: Data BEFORE removal');

if ~isempty(components_to_remove)
    EEG_cleaned = pop_subcomp(EEG, components_to_remove, 0);
    
    figure;
    pop_eegplot(EEG_cleaned, 1, 1, 1);
    title('Problem 1-1: Data AFTER ICA Artifact Removal (First 10 seconds)');
    set(findobj('Tag','EEGLAB'), 'Name', 'P1-1: Data AFTER removal');
else
    fprintf('Skipping artifact removal plot because no components were selected.\n');
end

fprintf('--- Problem 1-1 Complete ---\n');


%% PROBLEM 1-2: Analysis of Dataset 2 (Your CSV data)

fprintf('\n--- Starting Problem 1-2: Analysis of Dataset 2 ---\n');

% --- Configuration ---
dataset2_path = 'data/Dataset2.csv'; %<-- MODIFIEZ CE CHEMIN
sampling_rate = 256; % <-- MODIFIEZ CELA pour correspondre à votre enregistrement
channel_names = {'Fp1', 'Fp2', 'C3', 'C4'}; % <-- MODIFIEZ avec vos noms de canaux (4 canaux)

% --- Load CSV data and convert to EEGLAB format ---
if ~exist(dataset2_path, 'file')
    warning('Dataset 2 not found at %s. Skipping Problem 1-2.', dataset2_path);
else
    fprintf('Loading data from CSV file...\n');
    % readmatrix is modern, use csvread for older MATLAB versions
    csv_data = readmatrix(dataset2_path); 

    % Data is often channels x samples, but CSV might be samples x channels.
    % We need to ensure the data matrix is (channels x samples).
    if size(csv_data, 1) < size(csv_data, 2)
        % If there are fewer rows than columns, assume it's already channels x samples
    else
        % Otherwise, transpose it
        csv_data = csv_data'; 
    end
    
    % Import the data into an EEGLAB structure
    EEG2 = pop_importdata('dataformat', 'array', 'data', csv_data, ...
        'setname', 'Dataset 2', 'srate', sampling_rate, ...
        'nbchan', length(channel_names));

    % Add channel locations
    % EEGLAB will try to find standard locations based on the labels
    EEG2 = pop_chanedit(EEG2, 'lookup','standard-10-5-cap385.elp');

    
    % --- Step 1: Plot 2D channel location map ---
    fprintf('Step 1: Plotting 2D channel location map...\n');
    figure;
    topoplot([], EEG2.chanlocs, 'style', 'blank', 'electrodes', 'labelpoint', 'chaninfo', EEG2.chaninfo);
    title('Problem 1-2: 2D Channel Location Map for Dataset 2');
    set(gcf, 'Name', 'P1-2: Channel Map');

    
    % --- Step 2: Plot spectra and map in 2D ---
    fprintf('Step 2: Plotting power spectra and map...\n');
    % This function plots both the power spectral density for each channel
    % and a topographic map of the power in specified frequency bands.
    figure;
    pop_spectopo(EEG2, 1, [], 'EEG' , 'percent', 15, 'freq', [6 10 22], 'freqrange',[2 45],'electrodes','off');
    set(gcf, 'Name', 'P1-2: Power Spectra');
    % In your report, discuss what you see. Is there a large peak at 50/60Hz (line noise)?
    % Is there a peak in the alpha band (~8-12 Hz) when eyes were closed?

    
    % --- Step 3: Plot the first 10-second channel data ---
    fprintf('Step 3: Plotting the first 10 seconds of channel data...\n');
    figure;
    pop_eegplot(EEG2, 1, 1, 1);
    title('Problem 1-2: First 10 seconds of channel data');
    set(findobj('Tag','EEGLAB'), 'Name', 'P1-2: Raw Data Plot');
    % In your report, discuss what you observe. Are there obvious eye blinks
    % (large, slow waves, especially in Fp1/Fp2)? Are there slow drifts?
    % Does the signal look noisy?
    
    fprintf('--- Problem 1-2 Complete ---\n');
end