%% HW2: EEG Analysis - Problem 2
% Paul Boutet (Student ID:314551810)

% This script solves Problem 2 of the assignment.


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

fprintf('\n--- Starting Problem 2: Analysis of Dataset 1 ---\n');


dataset1_path = 'data/HW2_dataset/S02_Sess05.set'; 
EEG_orig = pop_loadset('filename', dataset1_path);
EEG = EEG_orig; 

if isempty(EEG)
    error('Dataset 1 failed to load. Check the path: %s', dataset1_path);
end
fprintf('Dataset 1 loaded successfully.\n');
fprintf('Number of channels: %d\n', EEG.nbchan);
fprintf('Sampling rate: %d Hz\n', EEG.srate);


%% --- Plot 2D channel location map ---
fprintf('\n--- Plotting 2D channel location map... ---\n');
figure;
topoplot([], EEG.chanlocs, 'style', 'blank', 'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
title('Problem 2: 2D Channel Location Map for Dataset 1');
set(gcf, 'Name', 'P2: Channel Map');

%% --- Bandpass Filter the Data [1-48] Hz ---
fprintf('\n--- Applying bandpass filter [1-48] Hz... ---\n');
EEG = pop_eegfiltnew(EEG, 1, 48);
fprintf('Bandpass filtering complete.\n');


%% --- Run ICA and record computational time ---
fprintf('\n--- Running ICA. This may take a few minutes... ---\n');
tic; 
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on');
ica_time = toc;
fprintf('ICA computation finished in %.2f seconds.\n', ica_time);

%% --- Save ICA results to disk (SET and MAT) ---
fprintf('\n--- Saving ICA results to disk... ---\n');
try
    [dataPath, dataName, ~] = fileparts(dataset1_path);
    if isempty(dataPath)
        dataPath = pwd; 
    end
    ica_set_name = [dataName '_ica_filtered.set'];
    pop_saveset(EEG, 'filename', ica_set_name, 'filepath', dataPath);
    ica_mat_name = fullfile(dataPath, [dataName '_ica_filtered.mat']);
    save(ica_mat_name, 'EEG');
    fprintf('Saved ICA .set to %s and .mat to %s\n', fullfile(dataPath, ica_set_name), ica_mat_name);
    catch ME
    warning(ME.identifier, 'Failed to save ICA results: %s', ME.message);
end


%% --- Plot component maps in 2D ---
fprintf('\n--- Plotting component maps... ---\n');
pop_topoplot(EEG, 0, [1:EEG.nbchan], 'Problem 2: ICA Component Maps', [], 'electrodes', 'off');
set(gcf, 'Name', 'P2: ICA Component Maps');

%% --- Noise components ---

components_to_remove = [1, 2, 3, 4, 5, 6, 17, 32, 33, 35, 43, 44, 45]; 

fprintf('\n--- Identification of artifact components. ---\n');
if isempty(components_to_remove)
    fprintf('WARNING: No components selected for removal. The "after" plot will be identical to the "before" plot.\n');
    fprintf('Please inspect the component maps and update the `components_to_remove` variable.\n');
else
    fprintf('Components selected for removal: %s\n', num2str(components_to_remove));
end


%% --- Plot data before and after deleting noise components ---
fprintf('\n--- Plotting data before and after artifact removal... ---\n');

pop_eegplot(EEG_orig, 1, 1, 1);
title('Problem 2: Data BEFORE ICA Artifact Removal (First 10 seconds)');
set(findobj('Tag','EEGLAB'), 'Name', 'P2: Data BEFORE removal');

if ~isempty(components_to_remove)
    EEG_cleaned = pop_subcomp(EEG, components_to_remove, 0);

    pop_eegplot(EEG_cleaned, 1, 1, 1);
    title('Problem 2: Data AFTER ICA Artifact Removal (First 10 seconds)');
    set(findobj('Tag','EEGLAB'), 'Name', 'P2: Data AFTER removal');
else
    fprintf('Skipping artifact removal plot because no components were selected.\n');
end

fprintf('--- Problem 2 Complete ---\n');

