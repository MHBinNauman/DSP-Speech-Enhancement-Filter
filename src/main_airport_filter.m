clear; clc; close all;

src_dir = fileparts(mfilename('fullpath'));
addpath(genpath(src_dir));
if ~exist('figures', 'dir'), mkdir('figures'); end

fs = 8000;
audio_samples = 10;    % Processing 10 samples min
% Storing metrics of each sample
results = struct();   

clean_dir = 'C:\Users\Hisham\Desktop\Computer Engineering\Semester 6\Digital Signal Processing\Semester Project\dataset\clean';
noisy_dir = 'C:\Users\Hisham\Desktop\Computer Engineering\Semester 6\Digital Signal Processing\Semester Project\dataset\5dB';

% Designing FIR filter for reusing for all samples
N_order = 150;
b_fir = fir1(N_order, [150 3400]/(fs/2), 'bandpass', hamming(N_order+1));

for i = 1:audio_samples
    fprintf('\nProcessing Sample - %d\n', i);

    % Loading the clean and noisy pair
    clean_audio = fullfile(clean_dir, sprintf('sp%02d.wav', i));
    noisy_audio = fullfile(noisy_dir, sprintf('sp%02d_airport_sn5.wav', i));
    [clean, ~] = audioread(clean_audio);
    [noisy, ~] = audioread(noisy_audio);

    % Preprocessing:
    N = min(length(clean), length(noisy));
        % Align length
    clean = clean(1:N);
    noisy = noisy(1:N);
        % Remove DC
    clean = clean - mean(clean);
    noisy = noisy - mean(noisy);
        % Normalize
    noisy = noisy / max(abs(noisy));
    clean = clean / max(abs(clean));

    % Baseline metrics
    segsnr_n = compute_segsnr(clean, noisy, fs);
    pesq_n = compute_pesq_score(clean, noisy, fs);

    % Enhance
    tic;
    enhanced = enhance_signal(noisy, b_fir, fs);
    t_proc = toc; % Time recorded

    % Post-enhancement metrics for comparison
    segsnr_e   = compute_segsnr(clean, enhanced, fs);
    pesq_e     = compute_pesq_score(clean, enhanced, fs);
    mse_val    = mean((clean - enhanced).^2);

    % Store
    results(i).iteration = i;
    results(i).segsnr_noisy = segsnr_n;
    results(i).segsnr_enh = segsnr_e;
    results(i).segsnr_imp = segsnr_e - segsnr_n;
    results(i).pesq_noisy = pesq_n;
    results(i).pesq_enh = pesq_e;
    results(i).pesq_imp = pesq_e - pesq_n;
    results(i).mse = mse_val;
    results(i).proc_time = t_proc;

    fprintf(' SegSNR: %.2f → %.2f dB (+%.2f)\n', segsnr_n, segsnr_e, segsnr_e - segsnr_n);
    fprintf(' PESQ: %.3f → %.3f (+%.3f)\n', pesq_n, pesq_e, pesq_e - pesq_n);
    fprintf(' MSE: %.6f\n', mse_val);
    fprintf(' Time: %.4f s\n', t_proc);

    % Generating and saving figures for whatever iteration you want to
    if i == 1 || i == 3
        t_ax = (0:N-1) / fs;
        plot_waveforms(t_ax, clean, noisy, enhanced, i);
        plot_psd(clean, noisy, enhanced, fs, i);
        plot_spectrograms(clean, noisy, enhanced, fs, i);
        plot_filter_response(b_fir, fs);
    end
end

% Print summary table
fprintf('\n===== RESULTS SUMMARY =====\n');
fprintf('%-6s %-12s %-12s %-12s %-12s %-12s %-10s %-10s\n', ...
        'Iteration No.','SegSNR_N','SegSNR_E','PESQ_N','PESQ_E','MSE','Time(s)','SegSNR_imp');
for i = 1:audio_samples
    r = results(i);
    fprintf('%-6d    %-12.2f    %-12.2f    %-12.3f  %-12.3f  %-12.6f  %-10.4f  %-10.2f\n', ...
            i, r.segsnr_noisy, r.segsnr_enh, r.pesq_noisy, ...
            r.pesq_enh, r.mse, r.proc_time, r.segsnr_imp);
end

% Mean across iterations
mean_segsnr_imp = mean([results.segsnr_imp]);
mean_pesq_imp = mean([results.pesq_imp]);
mean_mse = mean([results.mse]);
mean_time = mean([results.proc_time]);
fprintf('\nMEAN: SegSNR imp = %.2f dB - PESQ imp = %.3f - MSE = %.6f - Time = %.4f s\n', mean_segsnr_imp, mean_pesq_imp, mean_mse, mean_time);