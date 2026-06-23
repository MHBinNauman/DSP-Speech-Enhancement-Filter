function y = istft_ola(S, hop, win, N_fft)
    n_frames  = size(S, 2);
    frame_len = length(win);
    y_len     = (n_frames - 1) * hop + frame_len;
    y         = zeros(y_len, 1);
    norm_win  = zeros(y_len, 1);
    for m = 1:n_frames
        idx         = (m-1)*hop + 1 : (m-1)*hop + frame_len;
        frame_t     = real(ifft(S(:,m), N_fft));
        frame_t     = frame_t(1:frame_len) .* win;
        y(idx)      = y(idx) + frame_t;
        norm_win(idx) = norm_win(idx) + win.^2;
    end
    y = y ./ (norm_win + eps);
end