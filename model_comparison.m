function model_comparison(data)
    
    tbl = data2table(data,1);
    
    formula = 'C ~ -1 + V + (-1 + V|S)';
    results_V = fitglme(tbl,formula,'Distribution','Binomial','Link','Probit','FitMethod','Laplace')
    
    formula = 'C ~ -1 + VTU + (-1 + VTU|S)';
    results_VTU = fitglme(tbl,formula,'Distribution','Binomial','Link','Probit','FitMethod','Laplace')
    
    formula = 'C ~ -1 + V + RU + (-1 + V + RU|S)';
    results_VRU = fitglme(tbl,formula,'Distribution','Binomial','Link','Probit','FitMethod','Laplace')
    
    formula = 'C ~ -1 + V + RU + VTU + (-1 + V + RU + VTU|S)';
    results_VTURU = fitglme(tbl,formula,'Distribution','Binomial','Link','Probit','FitMethod','Laplace')
    
    save results_glme_fig3 results_V results_VTU results_VRU results_VTURU