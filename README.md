# Advanced DSP Denoising Toolkit: SAR Imagery & Speech Enhancement

[![Language](https://img.shields.io/badge/Language-MATLAB-orange.svg)](https://www.mathworks.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Overview
This repository contains a robust Digital Signal Processing (DSP) toolkit implemented in MATLAB. It is designed to tackle complex noise degradation across two distinct domains: **2D Synthetic Aperture Radar (SAR) imagery** and **1D Monaural Speech signals**. The algorithms focus on preserving structural integrity and perceptual quality while effectively mitigating highly non-stationary and multiplicative noise profiles.

## Key Features & Modules

### 1. Monaural Speech Enhancement
A psychoacoustic model-driven spectral subtraction and implicit Wiener filtering framework designed to suppress non-stationary, broadband noise (e.g., airport, drone, babble).
* **VAD-Driven PSD Estimation:** Continuously tracks and updates the noise Power Spectral Density (PSD) during speech pauses using Voice Activity Detection (VAD).
* **Psychoacoustic Over-subtraction:** Eliminates "musical noise" by applying dynamically varying over-subtraction factors ($\alpha$) across unequal critical frequency bands, mimicking the human auditory system.
* **Linear-Phase FIR Filtering:** Utilizes Hamming-windowed FIR filters to ensure a strictly constant group delay ($< 20$ ms), preventing the temporal smearing of vocal formants and transient consonants.

### 2. SAR Image Speckle Reduction
A framework for compounding and filtering multiplicative speckle noise ($p(u) = e^{-u}$) in radar cross-sections.
* **Noise Transformation:** Exploits spatial averaging to transition residual noise from an exponential distribution to an additive Gaussian model via the Central Limit Theorem.
* **Mean Preservation:** Implements advanced penalty-factor algorithms to prevent artificial signal brightening often caused by standard filtering.

## Datasets & Evaluation Metrics

### Speech Processing (NOIZEUS Corpus)
Tested against the standardized 8 kHz **NOIZEUS** dataset (IEEE phonetically-balanced sentences). 
* **Objective Metrics:** Perceptual Evaluation of Speech Quality (PESQ - ITU-T P.862), Segmental SNR (SegSNR), Log-Likelihood Ratio (LLR), Cepstral Distance (CD), and Weighted Spectral Slope (WSS).

### Image Processing (SAR)
* **Objective Metrics:** Equivalent Number of Looks (ENL), Speckle Suppression Index (SSI), and Speckle Suppression and Mean Preservation Index (SMPI).

## Prerequisites
* **MATLAB** (R2021a or newer recommended)
* Signal Processing Toolbox
* ITU-T P.862 `pesq.m` evaluation script (required for objective speech quality scoring)

## Quick Start (Speech Enhancement)
```matlab
% 1. Load clean and noisy audio files
[clean_speech, Fs] = audioread('NOIZEUS/clean/sp01.wav');
[noisy_speech, Fs] = audioread('NOIZEUS/airport_5dB/sp01_airport_sn5.wav');

% 2. Process via Psychoacoustic Spectral Subtraction
enhanced_speech = psychoacoustic_enhance(noisy_speech, Fs);

% 3. Evaluate Performance
score = pesq(clean_speech, enhanced_speech, Fs);
fprintf('PESQ Score: %.3f\n', score);
