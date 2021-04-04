function [percussion, harmonic] = hpss_function(x, percussion, harmonic, stft_sample_size, window_size, iteration, beta, fs, window)
    % initiallising values    
    length_percussion = (500*stft_sample_size)/fs;      
    length_harmonic = fs/(5*(stft_sample_size - iteration));  
    temp_x = zeros(window_size, 1);       
    STFT = zeros(stft_sample_size, ceil(length_harmonic/2));
    p = temp_x;
    h = temp_x;  
    eof = 0;
    i = 0;
    half_s_size = stft_sample_size/2;

    while eof == 0
        [next_set, eof] = x();

        % creating current frame
        temp_x = vertcat(temp_x(iteration+1:window_size), next_set);
        X = fft(temp_x.*window, stft_sample_size); 
        half_of_samples = X(1:(half_s_size));

        % STFT Calculation
        STFT = STFT(:, 2:size(STFT, 2));
        STFT(:, size(STFT, 2)+1) = X;

        % Median Filtering
        STFT_abs = abs(STFT(1:(half_s_size), :)); 
        H_mask = movmedian(STFT_abs, length_harmonic, 2);
        P_mask = movmedian(STFT_abs, length_percussion, 1);
        h_values = (H_mask./(P_mask + eps)) > beta; %eps added to avoid 0/0 situation
        p_values = (P_mask./(H_mask + eps)) >= beta; 
        

        % P & H mask Calc
        P_mask = p_values(:, size(p_values, 2)).*half_of_samples;
        H_mask = h_values(:, size(h_values, 2)).*half_of_samples; 
    
        % P & H mask re-size
        P_mask = cat(1, P_mask, flipud(conj(P_mask)));  
        H_mask = cat(1, H_mask, flipud(conj(H_mask))); 
        
        %calculate waves through IFFT
        harmonic_wave = real(ifft(H_mask, stft_sample_size));
        percussive_wave = real(ifft(P_mask, stft_sample_size));

        % Applying weighting
        h = h + harmonic_wave(1:(half_s_size)).*stft_sample_size/sum(window.*window);
        p = p + percussive_wave(1:(half_s_size)).*stft_sample_size/sum(window.*window);

        % output
        percussion(p(1:iteration));
        harmonic(h(1:iteration));

        % h and p cat
        h = vertcat(h(iteration+1:window_size), zeros(iteration, 1));
        p = vertcat(p(iteration+1:window_size), zeros(iteration, 1));

        i = i + 1;
    end
end