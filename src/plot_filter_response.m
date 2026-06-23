function plot_filter_response(b, fs)
    [h, f] = freqz(b, 1, 1024, fs);
    [gd, ~] = grpdelay(b, 1, 1024, fs);
    
    figure('Name', 'Filter Characterization');
    
    % Magnitude Response
    subplot(3,1,1);
    plot(f, 20*log10(abs(h)));
    ylabel('Mag (dB)'); title('Filter Frequency Response'); grid on;
    
    % Phase Response
    subplot(3,1,2);
    plot(f, unwrap(angle(h)));
    ylabel('Phase (rad)'); grid on;
    
    % Group Delay
    subplot(3,1,3);
    plot(f, gd);
    ylabel('Delay (samples)'); xlabel('Freq (Hz)'); grid on;
    
    saveas(gcf, 'figures/filter_response.fig');
    saveas(gcf, 'figures/filter_response.png');
end