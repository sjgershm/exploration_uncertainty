function tbl = data2table(data,standardize)
    
    if nargin < 2; standardize = 0; end
    
    RS = []; SS = []; C = []; V = []; S = []; RU = []; TU = []; rt = []; risky = []; cond = [];
    for s = 1:length(data)
        latents = kalman_filter(data(s));
        V = [V; latents.m(:,1) - latents.m(:,2)];
        risky = [risky; double((data(s).cond==1&data(s).choice==1)|(data(s).cond==2&data(s).choice==2)) - double((data(s).cond==1&data(s).choice==2)|(data(s).cond==2&data(s).choice==1))];
        RS = [RS; double(data(s).cond==1) - double(data(s).cond==2)];
        SS = [SS; double(data(s).cond==4) - double(data(s).cond==3)];
        cond = [cond; data(s).cond];
        C = [C; double(data(s).choice==1)];
        N = length(data(s).choice);
        S = [S; zeros(N,1)+s];
        TU = [TU; sqrt(latents.s(:,1) + latents.s(:,2))];
        RU = [RU; sqrt(latents.s(:,1)) - sqrt(latents.s(:,2))];
        rt = [rt; data(s).RT];
    end
    
    SSV = SS.*V;
    VTU = V./TU;
    rt = log(rt);
    cond = categorical(cond);
    
    if standardize==1
        VTU = zscore(VTU);
        V = zscore(V);
        RU = zscore(RU);
    end
    
    tbl = table(RS,SS,SSV,C,S,RU,VTU,V,rt,risky,cond);