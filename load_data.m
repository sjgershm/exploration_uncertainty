function data = load_data
    
    % Load data.
    %
    % USAGE: data = load_data
    
    X = csvread('data.csv',1);
    F = {'subject' 'block' 'trial' 'mu1' 'mu2' 'choice' 'reward' 'RT' 'cond'};
    S = unique(X(:,1));
    
    for s = 1:length(S)
        ix = X(:,1)==S(s);
        for f = 1:length(F)
            data(s).(F{f}) = X(ix,f);
        end
        
        [~,k] = max([data(s).mu1 data(s).mu2],[],2);
        data(s).acc = mean(data(s).choice==k);
    end
    
    acc = [data.acc];
    data(acc<0.55) = [];