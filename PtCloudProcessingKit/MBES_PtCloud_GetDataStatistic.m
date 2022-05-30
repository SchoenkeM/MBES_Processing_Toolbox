function data = MBES_PtCloud_GetDataStatistic(data,Config)
%% MBES GetStatistic for Tiles 
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
% -[S]= GetStatisticOfTile(S,Config);
% -[S]= GridStatisticParameters(S);



if isempty(data)
   fprintf('\t\t-> No data available in struct\n')
    return; 
end

currentFile= fullfile(data.Directory,data.ScanName);
OutputName=[currentFile(1:end-4) '_Stats.mat'];

txt= sprintf('\tDerive statistics in process:');
varunit=[];
Verbose(txt,' ',varunit)
if strcmp(Config.LoadStatisticDataIfExist,'true') && isfile(OutputName) 

   % This section is to load data and to overwrite the old directory
   % in case path of data has changed
     ScanName   =  data.ScanName;  
     Directory  =  data.Directory; % directroy from the Input Path
       statdata = load(OutputName);          
  data.ScanName = ScanName;
 data.Directory = Directory;    
 data.statistics= statdata ;
 
     fprintf('Existing *.mat version recovered');
else
     fprintf('initilialized');

    data= GetStatisticOfTile(data,Config);
    data= AssingStatisticParameters2Grid(data);  
    
    if  strcmp(Config.AutoSave,'true')
        Scan=data.statistics;
        save(OutputName,'-struct','Scan')
    end
end
          

Data_Size=printVarSize(data);  
txt = sprintf('\t- INFO: Size of data statistics:');
Verbose(txt,' ',[]) 
fprintf('%s',Data_Size);
     
             
end

