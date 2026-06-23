function plot_psd(clean, noisy, enhanced, fs, i)
    figure('Name', ['PSD Analysis - Sample ', num2str(i)]);
    
    % Using Welch's Method instead of fft as it reduces the noise in the
    % average giving a smoother waveform than raw fft
    [pxx_c, f] = pwelch(clean, hamming(256), 128, 512, fs);
    [pxx_n, ~] = pwelch(noisy, hamming(256), 128, 512, fs);
    [pxx_e, ~] = pwelch(enhanced, hamming(256), 128, 512, fs);
    
    % Plot in dB for logarithmic perception
    plot(f, 10*log10(pxx_c), 'k', 'LineWidth', 1.5); hold on;
    plot(f, 10*log10(pxx_n), 'Color', [1 0 0 0.5]);
    plot(f, 10*log10(pxx_e), 'b--', 'LineWidth', 1.2);
    
    grid on; xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
    title('Power Spectral Density Comparison');
    legend('Clean', 'Noisy', 'Enhanced');
    xlim([0 fs/2]);
    
    saveas(gcf, sprintf('figures/psd_%d.fig', i));
    saveas(gcf, sprintf('figures/psd_%d.png', i));
end
