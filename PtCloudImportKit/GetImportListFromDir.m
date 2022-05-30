function [FileList]= GetImportListFromDir(InputData,InputType)
% function to import all files of type "ext" from input directoy
% "ImputDir". The input patameter of "InputDir" and ext are char by type.
% 'ext' format e.g. can be specified by '*.txt'. 


    if isfile(InputData)
        [fpath,fname]=fileparts(InputData);
    
        FileList.fname = [fname '.txt'] ;
        FileList.fpath = fpath;

    elseif isfolder(InputData)
        
        currentPath=pwd;
        cd(InputData); 

        fileList = dir(InputType);

        N= length(fileList);
        FileList(N).fname     = [];
        FileList(N).fpath     = [];

        for i = 1:N
            FileList(i).fname= fileList(i).name;
            FileList(i).fpath = fileList(i).folder;    
        end
        cd(currentPath);
        
    else

        fprintf('\t-> File list is empty. Import Process failed')

    end

end