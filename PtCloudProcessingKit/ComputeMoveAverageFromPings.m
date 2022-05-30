function [S] = ComputeMoveAverageFromPings(S,Config)
%  using a moving average filter to remove morphologic effects from
%  Bathymerty


% Known issue
% by using a median to remove the smiley effect a bias of the ping occures
% with unknown extend.

if strcmpi(Config.ComputeMovAverageFromPings,'true')
    
    
    fprintf('\n\t\t- Computing mov. average for pings in process:.................');

    % reading variables
    x = S.raw.x;
    y = S.raw.y;
    z = S.raw.z;
    ping = S.raw.ping;
    win = Config.SmoothWindow;
    minTreshold = Config.minSampleNr2ComputeAverage; % minimum number of soundings reqired to compute the averaging
    
    % predefine variables
    index= single(1:length(x)); % required to maintain vector length
    newOutliers=zeros(size(z))==1; % blank vectors for possible outliers
    PingRange = unique(ping); % Get vector from min to max ping.
    N = length(PingRange);  % number of pings in Profile
    
    
    % Removes Outliers
    Outliers=S.Outlier.Total;
    if ~isempty(Outliers)
        x(Outliers)=[];
        y(Outliers)=[];
        z(Outliers)=[];
        ping(Outliers)=[];
        index(Outliers)=[];
    end
    
    z_average = nan(size(z)); % new field with filterter lf Surface
    
    % convert carthesian into polar coordinates, where rho is the radius
    % and z the height of the radius. With UMT lat and long coodirnates plus
    % the height causing a 2D+1D situation, polar coordinates are been used
    % to remove 1 dimention. Polar coordinates plot the height soley agianst
    % the radius removing a dimension. It is more efficient to compute the
    % moving average in 2D.
    
    % transformation into a 2D plain
    [theta,rho,z] = cart2pol(x,y,z);
    
    DispProgress = round(linspace(1,N,15)); % for progress feedback
    counter1 = 1;
    
    for n = 1:N % loop over all pings
        
        idx = PingRange(n)==ping; % columns containing the current ping
        z_idx =   z(idx);         % get corresponding depth values
        rho_idx = rho(idx);       % get corresponding crosstrack values
        
        % in case a ping has a low number of values depth is set to nan
        if sum(idx)<minTreshold
            z_idx = nan(size(z_idx));
        end
        
        % A robust version of 'loess' that assigns lower weight to outliers
        % in the regression. The method assigns zero weight to data outside
        % six mean absolute deviations.
        z_average(idx) =  smooth(rho_idx,z_idx,win,'rlowess'); % 0.023 sec
        
        if n == DispProgress(counter1)
            counter1 = counter1+1;
            fprintf('|');
        end
    end
    
    % in case there are pings, that could not be avaeraged, due to too few
    % sounding samples
    flag=isnan(z_average); % if flag = 1 there is a outlier in the column
    newOutliers(index)=flag;
    
    % converts the x,y,z values back from Polar coodinated to carthesian
    [~,~,z_average] =  pol2cart(theta,rho,z_average);
    
    % writing cmputed average back to struct
    S.processed.z_average  = nan(size(S.raw.z)); % maintain original length
    S.processed.z_average(index)  = z_average; %
    
    % Update Outlier Stuct
    S.Outlier.TooFewValues2ComputePingAverage = newOutliers;
    S = UpdateOutlier(S);
    
    
    fprintf(' \t\t[done]')
else
    
    
    x = S.raw.x;
    S.processed.z_average =zeros(size(x));
    
    newOutliers=zeros(size(x))==1;
    S.Outlier.TooFewValues2ComputePingAverage = newOutliers;
    S = UpdateOutlier(S);
    
    
end




end