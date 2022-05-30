function [S]= FilterPingsWith2FewValues(S,Config) 
% [%] Flags Pings with less than 30% of the maximum number of data points
% per ping. E.g. if the maxium number of swath beams per ping is 250, than
% pings which only contain 20 values become flagged as poor quality pings. 

if strcmpi(Config.FilterPingsWith2FewValues,'true')    
  % of swath values left. This step serches for pings with a significant 
  % low amount of beam per Ping

    txt=sprintf('\t- Detection of pings with a low number of soundings in process:');
    Verbose(txt,' ',[])

    ping = S.raw.ping; % get vectors with pings
    threshold=Config.minPercentage4PingValues;
    
    pingRange = unique(ping); % get range of pings
    groupPing = group(ping); % groups the beams by ping number 

  % computes the number of values per ping
    NrOfBeamsPerPing= cellfun(@(x) length(x),groupPing,...  
                                                   'UniformOutput',false);
    NrOfBeamsPerPing = cell2mat(NrOfBeamsPerPing); 

  % computes max number of values per ping
    maxNrOfBeamsPerPing= max(NrOfBeamsPerPing);

  % flags pings which have less than a third number of values in comparison  
  % to the max naumber of values in one ping
    flag =NrOfBeamsPerPing < maxNrOfBeamsPerPing.*threshold;
    OutlierPings= pingRange(flag);
  
  % Creates Outlier vector as logical
    Outliers=zeros(size(ping))==1;
    
  % Runs over all pings and set flags, if current angle is equal to 
  % OutlierBeam pings
    for n = 1:length(OutlierPings)
        Outliers(ping==OutlierPings(n)) = 1;   
    end
    
     
  % Write outlier to Stuct  
    S.Outlier.ScatteredPings= Outliers ;

  % Updates Outlier struct
    S = UpdateOutlier(S); 
    fprintf('[done]') 
    QualityCheck(Outliers)
    
    
else
  
    
    Outliers=zeros(size(S.raw.ping))==1;
    S.Outlier.ScatteredPings= Outliers ;
  % Updates Outlier struct
    S = UpdateOutlier(S); 
    
    
end % ind if case

end


function [y] = group(x)

    uniqueNum = unique(x);

    if size(uniqueNum,1) > size(uniqueNum,2)
        uniqueNum=uniqueNum';     
    end
    
    
    y=cell(size(uniqueNum));
    for i = 1:length(uniqueNum)        
        y(1,i) = {x(x== uniqueNum(i))};   
    end
    

end