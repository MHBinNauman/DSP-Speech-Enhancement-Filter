function plot_waveforms(t, clean, noisy, enhanced, i)
    figure('Name', ['Waveform Comparison - Sample ', num2str(i)]);
    
    % Subplot 1: Clean
    subplot(3,1,1);
    plot(t, clean, 'Color', [0 0.4470 0.7410]); % Professional Blue
    title('Clean Speech'); ylabel('Amp'); grid on;
    
    % Subplot 2: Noisy
    subplot(3,1,2);
    plot(t, noisy, 'Color', [0.8500 0.3250 0.0980]); % Professional Red
    title('Noisy Speech (Airport Noise)'); ylabel('Amp'); grid on;
    
    % Subplot 3: Enhanced
    subplot(3,1,3);
    plot(t, enhanced, 'Color', [0.4660 0.6740 0.1880]); % Professional Green
    title('Enhanced Speech'); ylabel('Amp'); xlabel('Time (s)'); grid on;

    % Save results
    if ~exist('figures', 'dir'), mkdir('figures'); end
    saveas(gcf, sprintf('figures/waveform_%d.fig', i));
    saveas(gcf, sprintf('figures/waveform_%d.png', i));
end
