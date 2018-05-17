function results = plot_figures(fig,data,results)
    
    switch fig
        
        case 'Figure1'
            x = linspace(-10,10,100);
            plot(x,normpdf(x,2,4),'-k','LineWidth',5);
            hold on;
            x = -1; y = normpdf(x,x,4);
            plot([x x],[0 y],'-','LineWidth',5,'Color',[0.5 0.5 0.5])
            text(2-0.4,y+0.01,'R','FontSize',25);
            text(-1-0.4,y+0.01,'S','FontSize',25);
            set(gca,'FontSize',25,'YLim',[0 0.12]);
            ylabel('Probability density','FontSize',25);
            xlabel('Reward','FontSize',25);
            
        case 'Figure2'
            
            mu = linspace(-3,3,100);
            d = 1;
            p(1,:) = 1-normcdf(0,mu+d,1);
            p(2,:) = 1-normcdf(0,mu,1+d);
            
            figure;
            T = {'Relative uncertainty: intercept shift' 'Total uncertainty: slope shift'};
            for i = 1:2
                subplot(2,2,i);
                plot(mu,1-normcdf(0,mu,1),'-k','LineWidth',5); hold on;
                plot(mu,p(i,:),'-','LineWidth',5,'Color',[0.5 0.5 0.5]);
                if i==1
                    legend({'SR' 'RS'},'FontSize',25,'Location','East');
                else
                    legend({'SS' 'RR'},'FontSize',25,'Location','East');
                end
                set(gca,'FontSize',25,'XLim',[min(mu) max(mu)]);
                ylabel('Choice probability','FontSize',25);
                xlabel('Expected value difference (V)','FontSize',25);
                title(T{i},'FontSize',25','FontWeight','Bold');
            end
            
            for s = 1:length(data)
                latents = kalman_filter(data(s));
                TU = sqrt(latents.s(:,1) + latents.s(:,2));
                RU = sqrt(latents.s(:,1)) - sqrt(latents.s(:,2));
                for i = 1:4
                    results.TU(s,i) = mean(TU(data(s).cond==i));
                    results.RU(s,i) = mean(RU(data(s).cond==i));
                end
            end
            
            subplot(2,2,3);
            [se,mu] = wse(results.RU);
            errorbar(mu',se','ok','MarkerSize',12,'MarkerFaceColor','k');
            set(gca,'FontSize',25,'XTickLabel',{'RS' 'SR' 'RR' 'SS'},'XLim',[0.5 4.5]);
            ylabel('Relative uncertainty (RU)','FontSize',25);
            subplot(2,2,4);
            [se,mu] = wse(results.TU);
            errorbar(mu',se','ok','MarkerSize',12,'MarkerFaceColor','k');
            set(gca,'FontSize',25,'XTickLabel',{'RS' 'SR' 'RR' 'SS'},'XLim',[0.5 4.5]);
            ylabel('Total uncertainty (TU)','FontSize',25);
            set(gcf,'Position',[200 200 1000 800])
            
        case 'Figure3'
            
            % Probit analysis of computational variables
            
            load results_glme_fig3
            results = results_VTURU;
                        
            % plot results
            [beta,~,stats] = fixedEffects(results);
            errorbar(beta([3 1 2]),stats.SE([3 1 2]),'ok','MarkerSize',12,'MarkerFaceColor','k');
            set(gca,'FontSize',25,'XTickLabel',{'V' 'RU' 'V/TU'},'XLim',[0.5 3.5],'YLim',[0 1.4]);
            ylabel('Regression coefficient','FontSize',25);
            set(gcf,'Position',[200 200 500 400])
            
        case 'Figure4'
            
            % Probit analysis of conditions
            
            % fit generalized linear mixed effects model
            if nargin < 3 || isempty(results)
                tbl = data2table(data,1);
                formula = 'C ~ -1 + cond + cond:V + (-1 + cond + cond:V|S)';
                % note: Laplace method not used here because it doesn't seem to complete
                results = fitglme(tbl,formula,'Distribution','Binomial','Link','Probit','DummyVarCoding','Full');
                save results_glme_fig4 results
            end
            
            % hypothesis tests
            H = [1 -1 0 0 0 0 0 0; 0 0 1 -1 0 0 0 0; 0 0 0 0 1 -1 0 0; 0 0 0 0 0 0 1 -1];   % contrast matrix
            for i=1:4; [p(i),F(i),DF1(i),DF2(i)] = coefTest(results,H(i,:)); end
            disp(['intercept, RS vs. SR: F(',num2str(DF1(1)),',',num2str(DF2(1)),') = ',num2str(F(1)),', p = ',num2str(p(1))]);
            disp(['intercept, RR vs. SS: F(',num2str(DF1(2)),',',num2str(DF2(2)),') = ',num2str(F(2)),', p = ',num2str(p(2))]);
            disp(['slope, RS vs. SR: F(',num2str(DF1(3)),',',num2str(DF2(3)),') = ',num2str(F(3)),', p = ',num2str(p(3))]);
            disp(['slope, RR vs. SS: F(',num2str(DF1(4)),',',num2str(DF2(4)),') = ',num2str(F(4)),', p = ',num2str(p(4))]);
            
            % plot results
            figure;
            [beta,~,stats] = fixedEffects(results);
            subplot(1,2,1);
            errorbar(beta(1:4),stats.SE(1:4),'ok','MarkerSize',12,'MarkerFaceColor','k');
            set(gca,'FontSize',25,'XTickLabel',{'RS' 'SR' 'RR' 'SS'},'XLim',[0.5 4.5]);
            ylabel('Intercept','FontSize',25);
            subplot(1,2,2);
            errorbar(beta(5:8),stats.SE(5:8),'ok','MarkerSize',12,'MarkerFaceColor','k');
            set(gca,'FontSize',25,'XTickLabel',{'RS' 'SR' 'RR' 'SS'},'XLim',[0.5 4.5]);
            ylabel('Slope','FontSize',25);
            set(gcf,'Position',[200 200 1000 400])
            
        case 'Figure5'
            
            % RT analysis
            
            for s = 1:length(data)
                ix = (data(s).cond==1&data(s).choice==1) | (data(s).cond==2&data(s).choice==2);
                results.rt(s,1) = nanmean(log(data(s).RT(ix)));
                ix = (data(s).cond==1&data(s).choice==2) | (data(s).cond==2&data(s).choice==1);
                results.rt(s,2) = nanmean(log(data(s).RT(ix)));
                results.rt(s,3) = nanmean(log(data(s).RT(data(s).cond==3)));
                results.rt(s,4) = nanmean(log(data(s).RT(data(s).cond==4)));
            end
            
            figure;
            [se,mu] = wse(results.rt);
            errorbar(mu',se','ok','MarkerSize',12,'MarkerFaceColor','k');
            %set(gca,'FontSize',25,'XTickLabel',{'Risky' 'Safe' 'RR' 'SS'},'XLim',[0.5 4.5]);
            set(gca,'FontSize',25,'XTickLabel',{'Risky' 'Safe' 'RR' 'SS' 'RR' 'SS'},'XLim',[0.5 6.5]);
            ylabel('Log response time','FontSize',25);
            set(gcf,'Position',[200 200 500 400])
            
            % report stats
            [~,p,~,stat] = ttest(results.rt(:,1),results.rt(:,2));
            disp(['RT, risky vs. safe: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.rt(:,3),results.rt(:,4));
            disp(['RT, RR vs. SS: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            
 %--------------- OTHER FIGURES ---------------%
            
        case 'WSLS'
            
            % Win-stay-lose-switch
            K = 8;
            R = linspace(-30,30,K);
            D = round(R(1:end-1) + 0.5*diff(R));
            for s = 1:length(data)
                c = data(s).choice; r = data(s).reward(1:end-1);
                
                N = zeros(size(c));
                for n = 1:length(c)
                    if data(s).trial(n)==1; count = [0 0]; end
                    N(n,1) = count(c(n));
                    count(c(n)) = count(c(n)) + 1;
                end
                
                stay = c(2:end)==c(1:end-1);
                risky = (data(s).cond==1&data(s).choice==1) | (data(s).cond==2&data(s).choice==2) | data(s).cond==3;
                for j = 1:length(R)-1
                    ix = risky(1:end-1) & data(s).trial(2:end)>1 & r>R(j) & r<=R(j+1);
                    results.m(s,1,j) =  nanmean(stay(ix));
                    ix = ~risky(1:end-1) & data(s).trial(2:end)>1 & r>R(j) & r<=R(j+1);
                    results.m(s,2,j) =  nanmean(stay(ix));
                    
                    ix = data(s).trial(2:end)>1 & N(1:end-1)<median(N) & r>R(j) & r<=R(j+1);
                    results.p(s,1,j) =  nanmean(stay(ix));
                    ix = data(s).trial(2:end)>1 & N(1:end-1)>=median(N) & r>R(j) & r<=R(j+1);
                    results.p(s,2,j) =  nanmean(stay(ix));
                end
                
                results.m_change(s,1) = (results.m(s,1,K/2+1) - results.m(s,1,K/2-1))/(D(K/2+1)-D(K/2-1));
                results.m_change(s,2) = (results.m(s,2,K/2+1) - results.m(s,2,K/2-1))/(D(K/2+1)-D(K/2-1));
                results.p_change(s,1) = (results.p(s,1,K/2+1) - results.p(s,1,K/2-1))/(D(K/2+1)-D(K/2-1));
                results.p_change(s,2) = (results.p(s,2,K/2+1) - results.p(s,2,K/2-1))/(D(K/2+1)-D(K/2-1));
            end
            
            figure;
            subplot(2,2,1)
            mu = squeeze(nanmean(results.m));
            se = squeeze(nanstd(results.m)./sqrt(sum(~isnan(results.m))));
            errorbar(mu',se','-o','MarkerSize',12,'MarkerFaceColor','w','LineWidth',4);
            set(gca,'FontSize',25,'XLim',[0.5 length(D)+0.5],'XTickLabel',D,'XTick',1:length(D),'YLim',[-0.1 1.1]);
            ylabel('P(stay)','FontSize',25);
            xlabel('Last reward','FontSize',25);
            legend({'Risky' 'Safe'},'FontSize',25,'Location','East');
            
            subplot(2,2,2);
            mu = squeeze(nanmean(results.p));
            se = squeeze(nanstd(results.p)./sqrt(sum(~isnan(results.p))));
            errorbar(mu',se','-o','MarkerSize',12,'MarkerFaceColor','w','LineWidth',4);
            set(gca,'FontSize',25,'XLim',[0.5 length(D)+0.5],'XTickLabel',D,'XTick',1:length(D),'YLim',[-0.1 1.1]);
            ylabel('P(stay)','FontSize',25);
            xlabel('Last reward','FontSize',25);
            legend({'New' 'Old'},'FontSize',25,'Location','East');
            
            subplot(2,2,3);
            [se,mu] = wse(results.m_change);
            barerrorbar(mu',se');
            set(gca,'XTickLabel',{'Risky' 'Safe'},'FontSize',25,'XLim',[0.5 2.5]);
            ylabel('Slope','FontSize',25);
            
            subplot(2,2,4);
            [se,mu] = wse(results.p_change);
            barerrorbar(mu',se');
            set(gca,'XTickLabel',{'New' 'Old'},'FontSize',25,'XLim',[0.5 2.5]);
            ylabel('Slope','FontSize',25);
            
            set(gcf,'Position',[200 200 1000 800])
            
        case 'RT_switch'
            
            % RT stay/switch analysis
            
            K = 8;
            R = linspace(-30,30,K);
            D = round(R(1:end-1) + 0.5*diff(R));
            
            for s = 1:length(data)
                c = data(s).choice; r = data(s).reward(1:end-1);
                rt = data(s).RT(1:end-1);
                stay = c(2:end)==c(1:end-1);
                
                ii = data(s).trial(2:end)>1;
                z = log(rt/1000);
                X = [z rt z.*rt];
                b(s,:) = glmfit(X(ii,:),stay(ii),'binomial');
                
                N = zeros(size(c));
                for n = 1:length(c)
                    if data(s).trial(n)==1; count = [0 0]; end
                    N(n,1) = count(c(n));
                    count(c(n)) = count(c(n)) + 1;
                end
                
                for j = 0:5
                    ix = stay & data(s).trial(2:end)>1 & N(1:end-1)==j;
                    results.rt(s,1,j+1) =  nanmean(log(rt(ix)));
                    ix = ~stay & data(s).trial(2:end)>1 & N(1:end-1)==j;
                    results.rt(s,2,j+1) =  nanmean(log(rt(ix)));
                end
                
                for j = 1:length(R)-1
                    ix = rt<median(rt) & data(s).trial(2:end)>1 & r>R(j) & r<=R(j+1);
                    results.p(s,1,j) =  nanmean(stay(ix));
                    ix = rt>=median(rt) & data(s).trial(2:end)>1 & r>R(j) & r<=R(j+1);
                    results.p(s,2,j) =  nanmean(stay(ix));
                end
                
                results.p_change(s,1) = (results.p(s,1,K/2+1) - results.p(s,1,K/2-1))/(D(K/2+1)-D(K/2-1));
                results.p_change(s,2) = (results.p(s,2,K/2+1) - results.p(s,2,K/2-1))/(D(K/2+1)-D(K/2-1));
            end
            
            figure;
            mu = squeeze(nanmean(results.rt));
            se = squeeze(nanstd(results.rt)./sqrt(sum(~isnan(results.rt))));
            errorbar(mu',se','-o','MarkerSize',12,'MarkerFaceColor','w','LineWidth',4);
            set(gca,'FontSize',25,'XLim',[0 7],'XTickLabel',0:5,'XTick',1:6);
            ylabel('Log response time','FontSize',25);
            xlabel('# samples','FontSize',25);
            legend({'Stay' 'Switch'},'FontSize',25,'Location','North');
            set(gcf,'Position',[200 200 500 400])
            
            figure;
            subplot(1,2,1);
            mu = squeeze(nanmean(results.p));
            se = squeeze(nanstd(results.p)./sqrt(sum(~isnan(results.p))));
            errorbar(mu',se','-o','MarkerSize',12,'MarkerFaceColor','w','LineWidth',4);
            set(gca,'FontSize',25,'XLim',[0.5 length(D)+0.5],'XTickLabel',D,'XTick',1:length(D),'YLim',[-0.1 1.1]);
            ylabel('P(stay)','FontSize',25);
            xlabel('Last reward','FontSize',25);
            legend({'Fast' 'Slow'},'FontSize',25,'Location','East');
            
            subplot(1,2,2);
            [se,mu] = wse(results.p_change);
            barerrorbar(mu',se');
            set(gca,'XTickLabel',{'Fast' 'Slow'},'FontSize',25,'XLim',[0.5 2.5]);
            ylabel('Slope','FontSize',25);
            set(gcf,'Position',[200 200 1000 400]);
            
    end
    
end

function [se, m] = wse(X)
    
    % Within-subject error, following method of Cousineau (2005).
    %
    % USAGE: [se, m] = wse(X)
    %
    % INPUTS:
    %   X - [N x D] data with N observations and D subjects
    %
    % OUTPUTS:
    %   se - [1 x D] within-subject standard errors
    %   m - [1 x D] means
    %
    % Sam Gershman, June 2015
    
    m = squeeze(nanmean(X));
    X = bsxfun(@minus,X,nanmean(X,2));
    N = sum(~isnan(X));
    se = bsxfun(@rdivide,nanstd(X),sqrt(N));
    se = squeeze(se);
    
end