%% HW2: EEG Analysis - Problem 1
% Paul Boutet (Student ID:314551810)

% This script solves Problem 1-1 and 1-2 of the assignment.

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


%%  PROBLEM 1-1: Analysis of Dataset 1

fprintf('\n--- Starting Problem 1-1: Analysis of Dataset 1 ---\n');


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
title('Problem 1-1: 2D Channel Location Map for Dataset 1');
set(gcf, 'Name', 'P1-1: Channel Map');


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
    ica_set_name = [dataName '_ica.set'];
    pop_saveset(EEG, 'filename', ica_set_name, 'filepath', dataPath);
    ica_mat_name = fullfile(dataPath, [dataName '_ica.mat']);
    save(ica_mat_name, 'EEG');
    fprintf('Saved ICA .set to %s and .mat to %s\n', fullfile(dataPath, ica_set_name), ica_mat_name);
    catch ME
    warning(ME.identifier, 'Failed to save ICA results: %s', ME.message);
end


%% --- Plot component maps in 2D ---
fprintf('\n--- Plotting component maps... ---\n');
pop_topoplot(EEG, 0, [1:EEG.nbchan], 'Problem 1-1: ICA Component Maps', [], 'electrodes', 'off');
set(gcf, 'Name', 'P1-1: ICA Component Maps');


%% --- Noise components ---

components_to_remove = [48, 56, 53, 12, 14, 15, 18, 19, 20, 22, 23, 25, 29, 31, 37, 42, 43, 44, 45, 49, 46, 50, 55, 2, 3, 4, 8, 11, 16, 17]; 

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
title('Problem 1-1: Data BEFORE ICA Artifact Removal (First 10 seconds)');
set(findobj('Tag','EEGLAB'), 'Name', 'P1-1: Data BEFORE removal');
set(findobj('Name','P1-1: Data BEFORE removal'), 'winlength', 10);

if ~isempty(components_to_remove)
    EEG_cleaned = pop_subcomp(EEG, components_to_remove, 0);

    pop_eegplot(EEG_cleaned, 1, 1, 1);
    title('Problem 1-1: Data AFTER ICA Artifact Removal (First 10 seconds)');
    set(findobj('Tag','EEGLAB'), 'Name', 'P1-1: Data AFTER removal');
    set(findobj('Name','P1-1: Data AFTER removal'), 'winlength', 10);
else
    fprintf('Skipping artifact removal plot because no components were selected.\n');
end

fprintf('--- Problem 1-1 Complete ---\n');


%% PROBLEM 1-2: Analysis of Dataset 2 

fprintf('\n--- Starting Problem 1-2: Analysis of Dataset 2 ---\n');

dataset2_path_eyeopened = 'data/dataset2/eyeopened-eeglab.set'; 
dataset2_path_eyeclosed = 'data/dataset2/eyeclosed-eeglab.set';
EEG_eyeopened = pop_loadset('filename', dataset2_path_eyeopened);
EEG_eyeclosed = pop_loadset('filename', dataset2_path_eyeclosed);

if isempty(EEG_eyeopened) || isempty(EEG_eyeclosed)
    error('Dataset 2 failed to load. Check the paths: %s and %s', dataset2_path_eyeopened, dataset2_path_eyeclosed);
end

%% --- Plot 2D channel location map ---
fprintf('\n--- Plotting 2D channel location map for Dataset 2... ---\n');
figure;
topoplot([], EEG_eyeclosed.chanlocs, 'style', 'blank', 'electrodes', 'labelpoint', 'chaninfo', EEG2.chaninfo);
title('Problem 1-2: 2D Channel Location Map for Dataset 2');    

%% --- Plot spectra and map in 2D. ---
fprintf('\n--- Plotting spectra and map for Dataset 2... ---\n');
figure;
pop_spectopo(EEG_eyeclosed, 1, [0  EEG_eyeclosed.pnts], 'EEG' , 'freqrange',[2 50],'electrodes','off');
title('Problem 1-2: Spectra for Eye-Closed Condition');
set(gcf, 'Name', 'P1-2: Spectra Eye-Closed');
figure;
pop_spectopo(EEG_eyeopened, 1, [0  EEG_eyeopened.pnts], 'EEG' , 'freqrange',[2 50],'electrodes','off');
title('Problem 1-2: Spectra for Eye-Opened Condition');
set(gcf, 'Name', 'P1-2: Spectra Eye-Opened');

%% --- Plot the first 10-second channel data ---
fprintf('\n--- Plotting first 10 seconds of channel data for Dataset 2... ---\n');
pop_eegplot(EEG_eyeclosed, 1, 1, 1);
title('Problem 1-2: Eye-Closed Condition (First 10 seconds)');
set(findobj('Tag','EEGLAB'), 'Name', 'P1-2: Eye-Closed Data');
set(findobj('Name','P1-2: Eye-Closed Data'), 'winlength', 10);
pop_eegplot(EEG_eyeopened, 1, 1, 1);
title('Problem 1-2: Eye-Opened Condition (First 10 seconds)');
set(findobj('Tag','EEGLAB'), 'Name', 'P1-2: Eye-Opened Data');
set(findobj('Name','P1-2: Eye-Opened Data'), 'winlength', 10);

fprintf('--- Problem 1-2 Complete ---\n');

