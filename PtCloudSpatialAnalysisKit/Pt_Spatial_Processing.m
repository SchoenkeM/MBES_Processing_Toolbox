function [data] = Pt_Spatial_Processing(data)


printLine
fprintf('\nSpatial Analysis of data in process...\n')

%% If the option " Config.LoadProcessedData ='false' " is set data  
N = size(data,2);    % N, Number of all ScanSets
FileList(N).ProcExist=[]; % length of Files in import struct

for i= 1:N % Loop over all Scans
   OutputName=[ data(i).FullName(1:end-4) '_PreProc.mat'];
   FileList(i).ProcExist=isfile(OutputName);
end
LoadProcData = checkIfMatExist(FileList,'ProcExist');


%%
for i= 1:N % Loop over all Scans   
    
    txt= sprintf('File (%02.0f/%02.0f) is been processed:',i,N);
    varin = data(i).ScanName(1:end-4);   
    varunit=[];
    Verbose(txt,varin,varunit)

    if  LoadProcData==1 && isempty(data(i).Spectral.K)
        
                
       % This section is to load data and to overwrite the directory
       % in case path of data has changed
         ScanName   =  data(i).ScanName; 
         Directory  =  data(i).Directory;
         FullName   =  data(i).FullName ;
 
         data(i)=load(OutputName);  
         
         data(i).ScanName= ScanName;
         data(i).Directory= Directory;
         data(i).FullName = FullName;
         
         
        fprintf('completed. Existing *.mat version recovered');
    else
       tic
        data(i)=Compute2DPowerSpectrum(data(i));
        toc
        
    end
end    





end


