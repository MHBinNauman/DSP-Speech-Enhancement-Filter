function segsnr = compute_segsnr(clean, degraded, fs)
    clean = clean(:);
    degraded = degraded(:);
    
    N = min(length(clean), length(degraded));
    clean = clean(1:N);
    degraded = degraded(1:N);
    
    clean(isnan(clean) | isinf(clean)) = 0;
    degraded(isnan(degraded) | isinf(degraded)) = 0;
    
    frame_len = round(0.020 * fs);
    frame_shift = round(0.010 * fs);
    
    if N < frame_len
        error_signal = clean - degraded;
        segsnr = 10 * log10((sum(clean.^2) + eps) / (sum(error_signal.^2) + eps));
        return;
    end
    
    win = hamming(frame_len);
    
    num_frames = floor((N - frame_len) / frame_shift) + 1;
    
    frame_snr = zeros(num_frames, 1);
    frame_energy = zeros(num_frames, 1);
    
    for k = 1:num_frames
        start_idx = (k - 1) * frame_shift + 1;
        end_idx = start_idx + frame_len - 1;
    
        clean_frame = clean(start_idx:end_idx) .* win;
        degraded_frame = degraded(start_idx:end_idx) .* win;
    
        noise_frame = clean_frame - degraded_frame;
    
        signal_power = sum(clean_frame.^2);
        noise_power = sum(noise_frame.^2);
    
        frame_energy(k) = signal_power;
    
        frame_snr(k) = 10 * log10((signal_power + eps) / (noise_power + eps));
    end
    
    energy_threshold = 1e-4 * max(frame_energy);
    valid_frames = frame_energy > energy_threshold;
    
    frame_snr(frame_snr > 35) = 35;
    frame_snr(frame_snr < -10) = -10;
    
    if any(valid_frames)
        segsnr = mean(frame_snr(valid_frames));
    else
        segsnr = mean(frame_snr);
    end
end