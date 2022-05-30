function DispSwathAngleRange(FileDir,id)


FileList = GetImportListFromDir(FileDir,'*.txt');
N=size(FileList,2);
id=min([N id]);
fname= FileList(id).fname;
fpath=FileList(id).fpath;
currentFile=fullfile(fpath,fname);

Data=load(currentFile(1:end-4));

angle = Data.raw.angle;  % read data 


fprintf('\n\t -> min Angle: %d; max Angle: %d\n',min(angle),max(angle));

end