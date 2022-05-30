function [Data]=MBES_ImportPtCloudData(fpath,fname,Config)
%% Import MBES Footprint Data from a given Directory
%
% inputData: can be either single file or folder directory
% fType : characterizes the file format (fomat type)
%
%
%
%
% Version 0.1
%  
% Patch Notes: 
%
% 01.11.2021 Build a clean version vor MBES *.txt from QPS data only
%
%
%
%__________________________________________________________________________
% Implemented custom functions: 
%
% - printLine -> Cosmetic
% - printVarSize -> Cosmetic
%
% - GetImportListFromDir 
% - GetDataSkeleton
% - checkIfMatExist
% - txt2mat


%     
%  txt = sprintf('\t- Import file: ');
%  varin = FileList.fname(1:end-4);   
%  Verbose(txt,varin ,[]) 


fullDir= fullfile(fpath,fname);
% Check if input is single file or folder
    if ~isfile(fullDir) && ~isfolder(fullDir)
        fprintf(['\n\n\t-> Specified input File or Folder ',...
                    'could not be located at: %s'], fullDir)
        fprintf('\n\t-> Please check file path or file name');
        fprintf('\n\n\t-> Import process failed\n\n');
        Data=[];
        return; 
    end


%     FileList = GetImportListFromDir(inputData,fType);

%% Checks which *txt files are already converted to matlab format
    
%     action = checkIfMatExist(fullDir,'.mat');     
    
%% Contruct Blank Data Structure
    Data = GetDataSkeleton(fpath,fname);  
  
%% Get length of Import List


        
 txt = sprintf('\tImport of current file in process:');
 Verbose(txt,' ' ,[]) 

 currentFileDir=[fullDir(1:end-4)  '.mat'];

 if  strcmp(Config.LoadRawDataIfExist,'true') && isfile(currentFileDir)
     Data=load(currentFileDir);  

   % If file was originally stored under a different directory, the
   % file assinments have to be overwritten with the current ones.
     Data.ScanName   = fname; 
     Data.Directory  = fpath;
     fprintf('Existing *.mat-file recovered');
 else 
    
     Data = txt2mat(Data);
     if  strcmp(Config.AutoSave,'true')
         save([currentFileDir(1:end-4) '.mat'],'-struct','Data')   
     end
     fprintf('completed.');
     
 end 
 
    Data_Size=printVarSize(Data);  
    txt = sprintf('\t- INFO: Size of imported data:');
    Verbose(txt,' ',[]) 
    fprintf('%s',Data_Size);





end