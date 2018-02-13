function results = plot_figures(fig,data)
    
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
            
            for s = 1:length(data)
                latents = kalman_filter(data(s));
                TU = sqrt(latents.s(:,1) + latents.s(:,2));
                RU = sqrt(latents.s(:,1)) - sqrt(latents.s(:,2));
                V = latents.m(:,1) - latents.m(:,2);
                X = [V RU V./TU];
                C = double(data(s).choice==1);
                results.b(s,:) = glmfit(X,C,'binomial','link','probit','constant','off');
                p = glmval(results.b(s,:)',X,'probit','constant','off');
                results.bic(s,1) = 3*log(length(C)) - C'*log(p) - (1-C')*log(1-p);
                results.b0(s,:) = glmfit(V,C,'binomial','link','probit','constant','off');
                p = glmval(results.b0(s,:)',V,'probit','constant','off');
                results.bic(s,2) = log(length(C)) - C'*log(p) - (1-C')*log(1-p);
            end
            
            [se,mu] = wse(results.b);
            errorbar(mu',se','ok','MarkerSize',12,'MarkerFaceColor','k');
            set(gca,'FontSize',25,'XTickLabel',{'V' 'RU' 'V/TU'},'XLim',[0.5 3.5],'YLim',[-.05 0.15]);
            hold on;
            plot(get(gca,'XLim'),[0 0],'--k','LineWidth',3)
            ylabel('Regression coefficient','FontSize',25);
            set(gcf,'Position',[200 200 500 400])
            
            % report stats
            [~,p,~,stat] = ttest(results.b(:,1));
            disp(['V vs 0: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.b(:,2));
            disp(['RU vs 0: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.b(:,3));
            disp(['TU vs 0: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            
        case 'Figure4'
            
            % Probit analysis of conditions
            
            for s = 1:length(data)
                latents = kalman_filter(data(s));
                V = latents.m(:,1) - latents.m(:,2);
                N = length(V);
                ix = false(N,4);
                for i = 1:4; ix(:,i) = data(s).cond==i; end
                C = double(data(s).choice==1);
                X = [ix bsxfun(@times,ix,V)];
                b = glmfit(X,C,'binomial','link','probit','constant','off');
                results.intercept(s,:) = b(1:4);
                results.slope(s,:) = b(5:8);
            end
            
            figure;
            subplot(1,2,2);
            [se,mu] = wse(results.slope);
            errorbar(mu',se','ok','MarkerSize',12,'MarkerFaceColor','k');
            set(gca,'FontSize',25,'XTickLabel',{'RS' 'SR' 'RR' 'SS'},'XLim',[0.5 4.5]);
            ylabel('Slope','FontSize',25);
            subplot(1,2,1);
            [se,mu] = wse(results.intercept);
            errorbar(mu',se','ok','MarkerSize',12,'MarkerFaceColor','k');
            set(gca,'FontSize',25,'XTickLabel',{'RS' 'SR' 'RR' 'SS'},'XLim',[0.5 4.5]);
            ylabel('Intercept','FontSize',25);
            set(gcf,'Position',[200 200 1000 400])
            
            % report stats
            [~,p,~,stat] = ttest(results.slope(:,1),results.slope(:,2));
            disp(['slope, RS vs. SR: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.slope(:,3),results.slope(:,4));
            disp(['slope, RR vs. SS: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.intercept(:,1),results.intercept(:,2));
            disp(['intercept, RS vs. SR: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.intercept(:,3),results.intercept(:,4));
            disp(['intercept, RR vs. SS: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.intercept(:,1));
            disp(['intercept, RS vs. 0: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.intercept(:,2));
            disp(['intercept, SR vs. 0: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            
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
            set(gca,'FontSize',25,'XTickLabel',{'Risky' 'Safe' 'RR' 'SS'},'XLim',[0.5 4.5]);
            ylabel('Log response time','FontSize',25);
            set(gcf,'Position',[200 200 500 400])
            
            % report stats
            [~,p,~,stat] = ttest(results.rt(:,1),results.rt(:,2));
            disp(['RT, risky vs. safe: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
            [~,p,~,stat] = ttest(results.rt(:,3),results.rt(:,4));
            disp(['RT, RR vs. SS: t(',num2str(stat.df),') = ',num2str(stat.tstat),', p = ',num2str(p)]);
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