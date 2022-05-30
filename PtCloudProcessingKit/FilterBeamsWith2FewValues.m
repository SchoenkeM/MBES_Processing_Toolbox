function [S]= FilterBeamsWith2FewValues(S,Config)   
 % [%] Flags Beam angles with less than 10% of the maximal number of data 
 % points per Beam. If the data set is manually preprocessed in QPS this
 % functions searches for Beams with a singificant low number if data
 % points. E.g if the outer beams were manually deleted, than single
 % soundings can be missed and beam 1 conrains overall 200 soundings in
 % comparission to 300000 soundings recoreded by one of the center beams

if strcmpi(Config.FilterBeamsWith2FewValues,'true')
        

    txt=sprintf(['\t- Detection of beam angles with',...
                  ' a low number of soundings in process:']);   
    Verbose(txt,' ',[])

%% runs over the angles and serches for Swath beam angels which occure 
% rarely within the datates.

    angle = S.raw.angle;
    groupAngle = group(angle); % groups the beams by beam angle 

  % computes the number of beams per angle ( Beam 1 => 2834 measument
  % points, Beam 23 => 98324 measument points)
    NrOfValuesPerBeam = cellfun(@(x) length(x), groupAngle,'UniformOutput' ,false);
    NrOfValuesPerBeam = cell2mat(NrOfValuesPerBeam); 

%   % Gets the beam number (" MBES beam 1,2,...., 265)
%     SwathBeamNr = cellfun(@(x) min(x), groupAngle,'UniformOutput' ,false);
  
  % converts beam number and number of measument by beam number to numbers
    SwathBeamNr  = unique(angle);

  % computes mean and std of the measument points by beam number
    maxBeamNr= max(NrOfValuesPerBeam);
    threshold=Config.minPercentage4BeamValues;
 
  % flags all beams number outside mean +/- standard deviation  
    flag = NrOfValuesPerBeam < maxBeamNr.*threshold;
 
  % Get beams with significant low number of measument points
    OutlierBeams= SwathBeamNr(flag);
  
  % Creates Outlier vector as logical
    Outliers=zeros(size(angle))==1;

  % Runs over all beam angles and set flags, if current angle is equal to 
  % OutlierBeam angle
    for n = 1:length(OutlierBeams)
        Outliers(angle==OutlierBeams(n)) = 1;   
    end
    
    
  % Write outlier to Stuct  
    S.Outlier.ScatteredBeams= Outliers ;

  % Updates Outlier struct
    S = UpdateOutlier(S); 

   fprintf('[done]') 
   QualityCheck(Outliers)
else
    

    Outliers=zeros(size(S.raw.angle))==1;
  % Write outlier to Stuct  
    S.Outlier.ScatteredBeams= Outliers ;
  % Updates Outlier struct
    S = UpdateOutlier(S); 
    
    
end % end if case


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