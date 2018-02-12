function latents = kalman_filter(data)
    
    % Kalman filter learning model.
    %
    % USAGE: latents = kalman_filter(data)
    
    V = [0.00001 16];   % reward variances for safe and risky options
    N = length(data.block);
    Q = zeros(N,2)+V(1);
    Q(data.cond==1|data.cond==3,1) = V(2);
    Q(data.cond==2|data.cond==3,2) = V(2);
    
    for n = 1:N
        
        % initialization at the start of each block
        if n == 1 || data.block(n)~=data.block(n-1)
            m = [0 0];      % posterior mean
            s = [100 100];  % posterior variance
        end
        
        c = data.choice(n);
        r = data.reward(n);
        
        % store latents
        latents.m(n,:) = m;
        latents.s(n,:) = s;
        
        % update
        k = s(c)/(s(c)+Q(n,c));    % Kalman gain
        err = r - m(c);            % prediction error
        m(c) = m(c) + k*err;       % posterior mean
        s(c) = s(c) - k*s(c);      % posterior variance
        
    end