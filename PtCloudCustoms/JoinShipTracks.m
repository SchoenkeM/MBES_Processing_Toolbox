function JoinShipTracks(InputDir,FileName)

OutputName=fullfile(InputDir,FileName);
currentPath=pwd;
fname=[]; fpath=[]; fileList=[]; %#ok<*NASGU>

if ~isdir(InputDir)
    fprintf('Failed to Open designated directory: %s\n\n',InputDir)
    return; 
end

cd(InputDir); 
fileList = dir('*.txt');
fname =[fname;{fileList.name}.']; 
fpath =[fpath;{fileList.folder}.'];  
N= length(fileList);

if ~isempty(fileList)
    N= length(fileList);
    for i= 1:N
        FileList(i).fullName = fullfile(fpath{i,:},fname{i,:});
    end
else
    fprintf('\t-> File list is empty. Join Process failed')
    cd(currentPath);
    return;
end

cd(currentPath);
clearvars fileList

dtime=[];
lat=[]; 
lon=[];
depth=[];

printLine
fprintf('\n\t - Joining of Ship Track tiles in process: ');
DispProgress = round(linspace(1,N,15)); 
counter1 = 1;     
for i = 1:N
    fid= fopen(FileList(i).fullName);

    formatSpec = '%s%f%f%f%[^\n\r]';
     delimiter = ',';
      startRow = 1;
      
  % Scan document
    dataArray = textscan(fid, formatSpec, 'Delimiter', delimiter,...
       'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN,'HeaderLines',...
       startRow-1, 'ReturnOnError', false);

   dtime= [dtime;dataArray{1,1}];
   lat  = [lat;dataArray{1,2}];
   lon  = [lon;dataArray{1,3}];
   depth= [depth;dataArray{1,4}];
   fclose(fid);
   
   if i == DispProgress(counter1) % When performance issues are fixed
        counter1 = counter1+1; 
         fprintf('|');  
   end 
   
end

fprintf('\t[done]\n\n')

if isfile(OutputName)
    try
        delete(OutputName)
        pause(1)
        if isfile(OutputName)
           fprintf('\n\t-> Output File: %s could not be deleted \n\n',OutputName)
        else
           fprintf('\n\t-> Older version of output File has been deleted\n\n')
        end
    catch
        fprintf('\n\t-> Output File: %s could not be deleted \n\n',OutputName)
    end    
end

T= table(dtime,lat,lon,depth);
writetable(T,OutputName,'WriteVariableNames',0);



end