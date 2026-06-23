function score = compute_pesq_score(ref, deg, fs)
    ref = ref(:);
    deg = deg(:);
    
    N = min(length(ref), length(deg));
    ref = ref(1:N);
    deg = deg(1:N);
    
    ref(isnan(ref) | isinf(ref)) = 0;
    deg(isnan(deg) | isinf(deg)) = 0;
    
    max_ref = max(abs(ref));
    max_deg = max(abs(deg));
    
    if max_ref > 1
        ref = ref / max_ref;
    end
    
    if max_deg > 1
        deg = deg / max_deg;
    end
    
    try
        score = pesq(ref, deg, fs, 'narrowband');
    
    catch
        try
            score = pesq(ref, deg, fs);
    
        catch ME
            warning('PESQ could not be computed. Audio Toolbox or pesq() function may be missing.');
            warning('MATLAB error: %s', ME.message);
    
            score = NaN;
            return;
        end
    end
    
    score = double(score(1));
    
    if score < 1
        score = 1;
    elseif score > 4.5
        score = 4.5;
    end
end