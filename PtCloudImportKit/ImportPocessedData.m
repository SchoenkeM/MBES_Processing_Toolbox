function [Data] = ImportPocessedData


    Config = GetGlobalConfig;  
    InputDir = Config.InputDir;

    [FileList,FileNames] = GetImportListFromDir(InputDir);
    N=length(FileList);

    printLine
    fprintf('\nImport processed PtCloud data...\n')
    fprintf('\n\tImport Directory: %s\n',InputDir); 
    
    for i = 1:length(FileList)
    txt = sprintf(' -> Import of processed file (%02.0f/%02.0f): ',i,N);
         filename=cell2mat(FileNames(i));
         varin = filename(1:end-4) ;   
        try
           Data(i)=load([FileList{i,1}(1:end-4) '_PreProc.mat']); 
           answer = sprintf('[done]. Existing *.mat version recovered');
        catch
           answer = sprintf('[failed]. Unable to find or open file');
        end  
    ULS200Verbose(txt,varin,answer)   
    end
    
 
   S=whos('Data'); 
   if isempty(S)==0
       Sbytes=round(S.bytes./1000000); 

       if Sbytes >= 1000 
           Sbytes = Sbytes./1000;
           Einheit = 'Gb';
       else
           Einheit = 'Mb';
       end
       
   fprintf('\n\n\tINFO: Data processing is skipped')    
   fprintf('\n\tINFO: Size of imported data: %0.2f %s\n',Sbytes,Einheit);    
   end
   
   fprintf('\nImport process is finished.') 
   

end


