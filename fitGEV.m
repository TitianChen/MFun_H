function [parmhat,hobs,hfit] = fitGEV(y,varargin)
% [parmhat,hobs,hfit] = fitGEV(y,varargin) fit the GEV function to a target
% cdf
%
% Input
%	* d: vector distance [1 x Nyy]
%	* freq: vector frequency [1 x Nfreq]
%	* coh: coherence experimentally measured [Nyy x Nfreq]
%	* beta0: skew angle
%	* guess: Initial values of the coefficients [1x Ncoeff]
%	* type: type of coherence model (string)
%	* U: mean wind speed at recorded wind field
%  Output
%	* CoeffFit: Fitted coefficients
%
% Author info
%  E. Cheynet last modified 01/09/2016
%
% see also mygevcdf
% 
%% Inputparser
p = inputParser();
p.CaseSensitive = false;
p.addOptional('method','Gringorten');
p.addOptional('dataPlot',0);
p.addOptional('returnPeriod',20);
p.addOptional('colorI',[0.9,0.9,0.9]);
p.parse(varargin{:});
% shorthen the variables name
method = p.Results.method ;
dataPlot = p.Results.dataPlot ;
returnPeriod = p.Results.returnPeriod;
colorI = p.Results.colorI;

switch method,
    case 'moments'
        parmhat(1) = 0; % Assume Gumbel distribution
        parmhat(2) = sqrt(6)/pi.*nanstd(y);
        parmhat(3) = nanmean(y)-0.5772.*parmhat(2);
    case 'Gumbel'
        parmhat(1) = 0; % Assume Gumbel distribution
        p= [1:numel(y)]./(numel(y)+1);
        [parmhat(2:3)]=polyfit(-log(-log(p(:))),sort(y(:)),1);
    case 'Gringorten'
        parmhat(1) = 0; % Assume Gumbel distribution
        p= ([1:numel(y)]-0.44)./(numel(y)+0.12);
        [parmhat(2:3)]=polyfit(-log(-log(p(:))),sort(y(:)),1);
    otherwise
        error(' method is unknown');
end
if dataPlot ==1,
    % measured
    x = ([1:numel(y)])/(numel(y)+1);
    r = 1./(1-x);
    % computed
    X = linspace(min(y),2*max(y),1e4);
    F  = gevcdf(X,parmhat(1),parmhat(2),parmhat(3)); % for fitted parameters
    R = 1./(1-F);
    
    % figure
    hold on;box on;
    hobs = plot(r,sort(y),'ko','markerfacecolor',colorI); % cdf of y
    hfit = plot(R(1,:),X,'color',colorI);
    xlabel('Return period (years)');
    ylabel('wind velocity (m/s)');
    ylim([0.9*min(X(R<returnPeriod)),1.1*max(X(R<returnPeriod))])
    xlim([0,returnPeriod])
    legend('Measured','fitted', 'location','SouthEast')
    grid on
    set(gcf,'color','w')
    % return period-rain
    [~,ind_R] = min(abs(R(1,:)-returnPeriod ));
    fprintf([num2str(round(x(end))),'-year AM is ',num2str(X(ind_R),3),' m/s (based on ',num2str(nanmax(date)-nanmin(date)),' years of data) \n'])
else
    [hobs,hfit] = deal([]);
end
end