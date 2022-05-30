function  [data] = MBES_PtCloud_GridData(data,Config)
%% Grids PtCloud Scatter data for global bathymerty and local tile
%
% version 0.1
%
%
%
%
%
% patch notes
%
%
% Implemented Custom Subfunctions
%
% - checkIfMatExist
% - CreateLocalGrid
% - CreateGlobalGrid
% -

if isempty(data)
    fprintf('\t\t-> No data in struct\n')
    return; 
end


currentFile= fullfile(data.Directory,data.ScanName);

txt= sprintf('\tGridding of current file in process:');
Verbose(txt,' ' ,[])      

OutputName=[currentFile(1:end-4) '_Gridded.mat'];
%%  processing will be performed


if strcmp(Config.LoadGridDataIfExist,'true') && isfile(OutputName) 

   % This section is to load data and to overwrite the old directory
   % in case path of data has changed
     ScanName   =  data.ScanName;  
     Directory  =  data.Directory; % directroy from the Input Path
       griddata = load(OutputName);          
  data.ScanName = ScanName;
 data.Directory = Directory;    
   data.gridded = griddata.gridded;

     fprintf('Existing *.mat version recovered');
else
     fprintf('initilialized');
     
    % first local tile gridding is required to place the final local
    % grids within global coordinate fragework
      data = CreateLocalGrid(data,Config); 

    % second, places the local Grids wihtin the global framework
      data = CreateGlobalGrid(data,Config); 
      
     if  strcmp(Config.AutoSave,'true')
         SaveData.gridded=data.gridded;
         save(OutputName,'-struct','SaveData')
     end
end

Data_Size=printVarSize(data);  
txt = sprintf('\t- INFO: Size of gridded data:');
Verbose(txt,' ',[]) 
fprintf('%s',Data_Size);
     




end

