function QuickDispStatGrid(FileDir,n,var)


FileList = GetImportListFromDir(FileDir,'*.txt');
N=size(FileList,2);

n=min([N n]);
fname= FileList(n).fname;
fpath=FileList(n).fpath;
currentFile=fullfile(fpath,fname);
OutputName1=[currentFile(1:end-4) '_Gridded.mat'];
OutputName2=[currentFile(1:end-4) '_Stats.mat'];
Data1=load(OutputName1);

xx=Data1.gridded.xx;  
yy=Data1.gridded.yy;  
 

figure
p1=subplot(2,1,1);
Zres=Data1.gridded.Z_residual; 
pcolor(xx,yy,Zres)
caxis([-0.04 -0.01])
colormap(p1,'gray')
colorbar
shading flat
axis equal
axis tight
title('Residual')


Data2=load(OutputName2);
p2=subplot(2,1,2);
stat=Data2.Elev_res_grid.(var); 
pcolor(xx,yy,stat)
colormap(p2,'jet')
colorbar
title(var)
shading flat
axis equal
axis tight


end