function plot_spectrograms(clean, noisy, enhanced, fs, i)
    figure('Name', ['Spectrogram Analysis - Sample ', num2str(i)]);
    
    win = hamming(256);
    noverlap = 128;
    nfft = 512;
    
    subplot(2,1,1);
    spectrogram(noisy, win, noverlap, nfft, fs, 'yaxis');
    title('Noisy Spectrogram'); colorbar;
    
    subplot(2,1,2);
    spectrogram(enhanced, win, noverlap, nfft, fs, 'yaxis');
    title('Enhanced Spectrogram'); colorbar;
    
    saveas(gcf, sprintf('figures/spectrogram_%d.fig', i));
    saveas(gcf, sprintf('figures/spectrogram_%d.png', i));
end