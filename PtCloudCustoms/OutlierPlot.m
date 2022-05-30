function OutlierPlot(FileDir,id)


FileList = GetImportListFromDir(FileDir,'*.txt');
N=size(FileList,2);
id=min([N id]);
fname= FileList(id).fname;
fpath=FileList(id).fpath;
currentFile=fullfile(fpath,fname);

Data=load(currentFile(1:end-4));
ProcessedData=load([currentFile(1:end-4) '_PreProc.mat']);

x=Data.raw.x; 
y=Data.raw.y;


figure
subplot(2,3,1)
outlier=ProcessedData.Outlier.rmSwathBeams;
plot(x,y,'k.')
hold on 
plot(x(outlier),y(outlier),'r.')
title('FilterSwathBeams')
grid


subplot(2,3,2)
outlier=ProcessedData.Outlier.ScatteredBeams;
plot(x,y,'k.')
hold on 
plot(x(outlier),y(outlier),'r.')
title('FilterBeamsWith2FewValues')
grid

subplot(2,3,3)
outlier=ProcessedData.Outlier.ScatteredPings;
plot(x,y,'k.')
hold on 
plot(x(outlier),y(outlier),'r.')
title('FilterPingsWith2FewValues')
grid

subplot(2,3,4)
outlier=ProcessedData.Outlier.TooFewValues2ComputePingAverage;
plot(x,y,'k.')
hold on 
plot(x(outlier),y(outlier),'r.')
title('minSampleNr2ComputeAverage')
grid

subplot(2,3,5)
outlier=ProcessedData.Outlier.FilterByDetectionWindow;
plot(x,y,'k.')
hold on 
plot(x(outlier),y(outlier),'r.')
title('FilterByDetectionWindow')
grid

subplot(2,3,6)
outlier=ProcessedData.Outlier.Total;
plot(x,y,'k.')
hold on 
plot(x(outlier),y(outlier),'r.')
title('Filter Total')
grid

end