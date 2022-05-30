function ControlPlot(FileDir,id,var)


FileList = GetImportListFromDir(FileDir,'*.txt');
N=size(FileList,2);
id=min([N id]);
fname= FileList(id).fname;
fpath=FileList(id).fpath;
currentFile=fullfile(fpath,fname);


Data=load([currentFile(1:end-4)']);
ProcessedData=load([currentFile(1:end-4) '_PreProc.mat']);
GriddedData=load([currentFile(1:end-4) '_Gridded.mat']);

xx=GriddedData.gridded.xx;  
yy=GriddedData.gridded.yy;  
 

if length(xx) > length(yy)
    m=3; n=1;
else
    m=1; n=3;
end

figure
p1=subplot(m,n,1);
x=Data.raw.x; 
y=Data.raw.y; 
outlier=ProcessedData.Outlier.Total;
plot(x,y,'k.')
hold on 
plot(x(outlier),y(outlier),'r.')
axis equal
title('Bathymerty PointCloud')
xlim([min(xx) max(xx)])
ylim([min(yy) max(yy)])
grid


p2=subplot(m,n,2);
Zres=GriddedData.gridded.Z_residual; 
pcolor(xx,yy,Zres)
colormap(p2,'gray')
colorbar
title('Bathymerty Gridded')
shading flat
axis equal
xlim([min(xx) max(xx)])
ylim([min(yy) max(yy)])
grid


p3=subplot(m,n,3);
Zres=GriddedData.gridded.Z_residual; 
Zres(Zres>-0.03)=NaN;
CMAP=zeros(64,3);
pcolor(xx,yy,Zres)
colormap(p3,CMAP)
colorbar
title('Trawl Marks')
shading flat
axis equal
xlim([min(xx) max(xx)])
ylim([min(yy) max(yy)])
grid


end