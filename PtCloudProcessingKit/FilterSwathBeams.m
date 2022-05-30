function [S]= FilterSwathBeams(S,Config)   
    % Function delets beam angles, if after QPS corretion beams with 
    % bad signal quality are still contained within the data set

% Checks if form 
... MBES dataset

if strcmp(Config.FilterSwathBeams  ,'true') 
        
  % Feedback for user
    txt=sprintf('\t- Marking selected beam angles as outliers in process:');
    Verbose(txt,' ',[])  

    angle = S.raw.angle;  % read data 
    rmAngle= Config.Beams2Remove;  % specified swath angles set to remove
    Outliers=zeros(size(angle))==1; % Predefine Outlier Vector 
  
    N= length(rmAngle);   
    for n = 1:N % loop over all specified beam angles
         flag= angle==rmAngle(n); % flag in the option specified Beams 
         Outliers(flag)= 1;
    end
    
    S.Outlier.rmSwathBeams=Outliers;
  % Update Stuct  
    S = UpdateOutlier(S);
    
    fprintf('[done]') 
    QualityCheck(Outliers)
    
end

    Outliers=zeros(size(S.raw.angle))==1; % Predefine Outlier Vector 
    S.Outlier.rmSwathBeams=Outliers;
  % Update Stuct  
    S = UpdateOutlier(S);



end