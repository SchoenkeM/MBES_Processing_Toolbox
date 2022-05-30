function [data]=MBES_PtCloud_Processing(data,Config)
% Explination missing
%
%
% Version 0.1
%
%
% Open issue
%
% - FilterByRunMedianWindow not implemented
%
% _________________________________________________________________________
% Patch notes: 
%
% 26.08.2021
%
% - Added Filter to remove specified Beam Angles from the data set
% - Feedback was added to RemoveScatteredBeams function 
% - Config is added as input variable and not as global anymore
%
%
%
%
%__________________________________________________________________________
% Implemented custom functions: 
%
%
% - Verbose "Cosmetic"
% - QualityCheck "Cosmetic"
%
%    - checkIfMatExist
%    - FilterBeamsWith2FewValues 
%    - FilterPingsWith2FewValues
%    - FilterSwathBeams
%    - ComputeMoveAverageFromPings
%    - FilterByDetectionWindow
%    - Split2Tiles
%    - GetAlignmentOfTiles
%    - UpdateOutlier
%    - FilterByRunMedianWindow (Bugged not implemented)




%% Here Data Processing starts
%

if isempty(data)
    fprintf('\t-> No data in struct\n')
    return; 
end


currentFile = fullfile(data.Directory,data.ScanName);
OutputName=[currentFile(1:end-4) '_PreProc.mat'];

txt= sprintf('\tPreprocssing of current file in process:');
Verbose(txt,' ',[])    

if strcmp(Config.LoadProcessedDataIfExist,'true') && isfile(OutputName) 

   % This section is to load data and to overwrite the old directory
   % in case path of data has changed
     ScanName   =  data.ScanName;  
     Directory  =  data.Directory; % directroy from the Input Path
       procdata = load(OutputName);          
  data.ScanName = ScanName;
 data.Directory = Directory;
 data.processed = procdata.processed;
   data.Outlier = procdata.Outlier;
    fprintf('Existing *.mat-file recovered');
    
    
else
    fprintf('initilialized');
   %%  processing will be performed
    
   % global Filter applied on entie Point cloud
  
     data = FilterBeamsWith2FewValues(data,Config); 
     data = FilterPingsWith2FewValues(data,Config);
     data = FilterSwathBeams(data,Config);
     data = ComputeMoveAverageFromPings(data,Config); 
     data = FilterByDetectionWindow(data,Config); 

   % Local Filter applied on Point Cloud in each Tile
     data = Split2Tiles(data,Config);
     data = GetAlignmentOfTiles(data); 



     
     if  strcmp(Config.AutoSave,'true') 
         SaveData.processed=data.processed;
         SaveData.Outlier=data.Outlier;
         save(OutputName,'-struct','SaveData')
     end
end

     Data_Size=printVarSize(data);  
     txt = sprintf('\t- INFO: Size of preprocessed data:');
     Verbose(txt,' ',[]) 
     fprintf('%s',Data_Size);

end





