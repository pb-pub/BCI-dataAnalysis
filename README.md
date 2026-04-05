# BCI Data Analysis

This repository contains MATLAB scripts for EEG data analysis as part of Homework 2 (HW2) in a Brain-Computer Interface (BCI) course. The analysis focuses on preprocessing EEG signals, artifact removal using Independent Component Analysis (ICA), and Event-Related Potential (ERP) computation with Signal-to-Noise Ratio (SNR) evaluation.

## Prerequisites

- MATLAB (R2020a or later recommended)
- EEGLAB toolbox (version 2025.1.0 included in this repository)
- Basic understanding of EEG signal processing concepts

## Installation and Setup

1. Clone or download this repository to your local machine.

2. Ensure MATLAB is installed and can run scripts.

3. The EEGLAB toolbox is already included in the `eeglab_current/` directory. The scripts will automatically add this path if EEGLAB is not found in your MATLAB path.

4. Place EEG data files in the `data/` directory following the expected structure (see Data Description below).

## Project Structure

```
BCI-dataAnalysis/
├── problem1.m          # Problem 1: Basic ICA analysis on two datasets
├── problem2.m          # Problem 2: Filtered ICA analysis
├── problem3.m          # Problem 3: Pipeline comparison with ERP/SNR
├── data/               # EEG data files
│   ├── HW2_dataset/    # Dataset 1: Subject S02 Session 05
│   └── dataset2/       # Dataset 2: Eye open/closed conditions
├── eeglab_current/     # EEGLAB toolbox (version 2025.1.0)
├── report/             # Output directory for analysis results
└── README.md           # This file
```

## Usage

Run the MATLAB scripts in numerical order:

1. `problem1.m`: Performs basic ICA analysis on Dataset 1 and spectral analysis on Dataset 2
2. `problem2.m`: Applies bandpass filtering before ICA on Dataset 1
3. `problem3.m`: Compares four preprocessing pipelines and computes ERPs/SNR

Each script will:
- Load the required datasets
- Perform the specified preprocessing steps
- Generate plots and save results
- Display computational times and analysis metrics

### Running Individual Scripts

Open MATLAB and navigate to the repository directory, then run:

```matlab
problem1
problem2
problem3
```

## Data Description

### Dataset 1 (HW2_dataset/)
- File: `S02_Sess05.set` (and associated `.fdt` file)
- Subject: S02, Session 05
- Contains EEG data with feedback events (correct/error)
- Used for ICA artifact removal and ERP analysis

### Dataset 2 (dataset2/)
- Files: `eyeopened-eeglab.set`, `eyeclosed-eeglab.set`
- Contains resting state EEG data under two conditions
- Used for spectral analysis comparison

All data files are in EEGLAB `.set` format with corresponding `.fdt` binary data files.

## Analysis Overview

### Problem 1
- Loads Dataset 1 and performs ICA decomposition
- Identifies and removes artifact components manually
- Analyzes Dataset 2 with spectral plots for eye open/closed conditions
- Generates channel location maps and data visualizations

### Problem 2
- Applies 1-48 Hz bandpass filter to Dataset 1
- Performs ICA on filtered data
- Removes identified artifact components
- Compares data before and after preprocessing

### Problem 3
Compares four preprocessing pipelines:
1. No preprocessing
2. Bandpass filtering only (1-48 Hz)
3. ICA artifact removal only
4. Bandpass filtering + ICA artifact removal

For each pipeline:
- Epochs data around feedback events (-200ms to 1300ms)
- Computes ERPs for correct vs error feedback at FCz electrode
- Calculates SNR based on pre-stimulus noise and post-stimulus peak amplitude

## Technical Details

### ICA Implementation
- Uses EEGLAB's `pop_runica` with 'runica' algorithm and extended mode
- Components classified using ICLabel plugin for automated artifact detection
- Manual component selection in Problems 1-2, automated in Problem 3

### Filtering
- Bandpass filter: 1-48 Hz using `pop_eegfiltnew`
- Applied before ICA in Problems 2-3

### ERP Analysis
- Epoching: -200ms to 1300ms relative to feedback events
- Baseline correction: -200ms to 0ms
- Channel of interest: FCz (frontal midline)
- SNR calculation: peak amplitude (0-1000ms) / pre-stimulus standard deviation

### Artifact Removal
- Manual selection based on component topography and time course
- Automated classification using ICLabel (>70% probability for artifacts)
- Components removed: muscle, eye, channel noise, line noise, and non-brain components

## Output and Results

- ICA results saved as `.set` and `.mat` files in `data/HW2_dataset/`
- Plots generated for channel maps, component topographies, spectra, and ERPs
- SNR values printed to console for each pipeline in Problem 3
- All visualizations include descriptive titles and labels

## Dependencies

- EEGLAB 2025.1.0 (included)
- MATLAB Signal Processing Toolbox (recommended)
- ICLabel plugin (included with EEGLAB)

## Author

Paul Boutet (Student ID: 314551810)

## Notes

- Scripts include timing measurements for ICA computations
- Error handling for missing files and failed operations
- All plots are interactive and can be saved manually from MATLAB figures
- Computational times may vary based on system hardware and MATLAB version