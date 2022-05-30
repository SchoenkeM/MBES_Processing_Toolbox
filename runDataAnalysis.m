function runDataAnalysis(MBESInputData,Config)

Config.AutoSave = 'true'; % implemented for developer purpose.


FileList = GetImportListFromDir(MBESInputData,'*.txt');
printLine
fprintf('\nAnalyis of MBES data in process...\n')

N = size(FileList,2);    % N, Number of Files in List
for n= 1:N % Loop over FileList
    
     fname= FileList(n).fname;
     fpath=FileList(n).fpath;
    
     txt = sprintf('-> File (%02.0f/%02.0f) is been processed:',n,N);
     varin = fname(1:end-4);   
     Verbose(txt,varin ,[]) 

     Data = MBES_ImportPtCloudData(fpath,fname,Config);
    
     action = CheckIfDataIsAlongPolyline(Data,Config);
     
     if action % check if data exist along polyline
         Data = MBES_PtCloud_Processing(Data,Config);

         Data = MBES_PtCloud_GridData(Data,Config); 

         Data = MBES_PtCloud_GetDataStatistic(Data,Config);

         WriteTrackline2GeoTiff(Data,Config);
     end
end

fprintf('\n\nAnalysis complete\n\n')

end