function PlotTiles(FileDir,ShiptrackDir,id)


FileList = GetImportListFromDir(FileDir,'*.txt');
N=size(FileList,2);
id=min([N id]);
fname= FileList(id).fname;
fpath=FileList(id).fpath;
currentFile=fullfile(fpath,fname);


Data=load([currentFile(1:end-4)']);
ProcessedData=load([currentFile(1:end-4) '_PreProc.mat']);


N = size(ProcessedData.processed.Tile,2);
TileX = cell2mat({ProcessedData.processed.Tile.vertX}.');
TileY = cell2mat({ProcessedData.processed.Tile.vertY}.');

TileX=[TileX TileX(:,1)];
TileY=[TileY TileY(:,1)];
figure
x=Data.raw.x; 
y=Data.raw.y; 
plot(x,y,'k.')
hold on 
for n=1:N
    plot(TileX(n,:),TileY(n,:),'r')
end
axis equal
title('Bathymerty PointCloud')
grid
xlim_var=get(gca,'Xlim');
ylim_var=get(gca,'Ylim');

[cLat,cLon]= ImportPolyLine(ShiptrackDir);

plot(cLat,cLon,'y','LineWidth',2)
xlim(xlim_var)
ylim(ylim_var);


end