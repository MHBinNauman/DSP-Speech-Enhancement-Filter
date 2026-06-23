function y = enhance_signal(x, b_fir, fs)
    % FIR Bandpass ---
    x_filt = filter(b_fir, 1, x);

    % Spectral Subtraction 
        % Parameters
    frame_len = 160;          % 20 ms
    hop_size  = 80;           % 50% overlap
    N_fft     = 256;
    win       = hamming(frame_len);
    G_min     = 0.1;          % Spectral floor
    beta      = 0.98;         % Noise tracker smoothing
    gamma_sm  = 0.85;         % Gain temporal smoothing

    % Psycho acoustic subbands: [start_bin, end_bin, alpha]
    % Freq resolution: 8000/256 = 31.25 Hz/bin
    band_cfg = [1,  5,  2.0;   % 0–156 Hz
                6,  10, 1.8;   % 156–312 Hz
                11, 22, 1.5;   % 312–687 Hz
                23, 54, 1.3;   % 687–1687 Hz (most critical)
                55, 96, 1.5;   % 1687–3000 Hz
                97, 129,1.8];  % 3000–4000 Hz

    n_bins   = N_fft/2 + 1;
    n_frames = floor((length(x_filt) - frame_len) / hop_size) + 1;

    % Voice Activity Detector
    E = zeros(1, n_frames);
    for m = 1:n_frames
        idx    = (m-1)*hop_size + 1 : (m-1)*hop_size + frame_len;
        % Computing energy of frame m
        E(m)   = sum(x_filt(idx).^2);
    end
    vad_thr  = prctile(E, 20);
    is_speech = E > vad_thr;

    % Initializing noise PSD from first silence frames
    N_psd  = zeros(n_bins, 1) + eps;
    n_init = 0;
    for m = 1:min(10, n_frames)
        if ~is_speech(m)
            idx    = (m-1)*hop_size + 1 : (m-1)*hop_size + frame_len;
            frm    = x_filt(idx) .* win;
            Sf     = fft(frm, N_fft);
            N_psd  = N_psd + abs(Sf(1:n_bins)).^2;
            n_init = n_init + 1;
        end
    end
    if n_init > 0
        N_psd = N_psd / n_init;
    end

    % Spectral subtraction frame loop
    S_enh  = zeros(N_fft, n_frames);
    G_prev = ones(n_bins, 1);

    for m = 1:n_frames
        idx     = (m-1)*hop_size + 1 : (m-1)*hop_size + frame_len;
        frm_w   = x_filt(idx) .* win;
        Sf      = fft(frm_w, N_fft);
        S_half  = Sf(1:n_bins);
        P       = abs(S_half).^2; % Power spec of current frame

        % Noise is to be updated in silence frames only
        if ~is_speech(m)
            N_psd = beta * N_psd + (1 - beta) * P;
        end

        % Multi band imp:
            % Compute gain per psycho acoustic subband
        G = ones(n_bins, 1);
        for b_idx = 1:size(band_cfg, 1)
            b1 = band_cfg(b_idx, 1);
            b2 = min(band_cfg(b_idx, 2), n_bins);
            a  = band_cfg(b_idx, 3);    % alpha 
            % bin selection
            bins       = b1:b2;
            % Gain imp for over-subtraction
            g_bins     = 1 - a * sqrt(N_psd(bins)) ./ (sqrt(P(bins)) + eps);
            G(bins)    = max(g_bins, G_min);
        end

        % Temporal smoothing
        G_smooth = gamma_sm * G_prev + (1 - gamma_sm) * G;
        G_prev   = G_smooth;

        % Apply to complex spectrum
        S_enh_half         = G_smooth .* S_half;
        S_enh(:,m)         = [S_enh_half; conj(flipud(S_enh_half(2:end-1)))];
    end

    % Overlap-add ISTFT
    y = istft_ola(S_enh, hop_size, win, N_fft);
    % Zero-pad if istft_ola output is shorter than x 
    if length(y) < length(x)
        y(end+1:length(x)) = 0;
    end
    y = y(1:length(x));    % Length align 
end