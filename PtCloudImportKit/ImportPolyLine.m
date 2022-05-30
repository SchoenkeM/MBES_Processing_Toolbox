function [lat,lon]= ImportPolyLine(ShipTrackDir)
% is not fully develloped 
% requires 2020-05-28 15:39:33.205,614858.64,6045147.6,-1.02 as input 
% which corresponds to ship track MBES output from QPS, with the fields
% Date Time, Lat, Lon, DepthOrSpeed

   fid= fopen(ShipTrackDir);

    formatSpec = '%*s%f%f%*s%[^\n\r]';
     delimiter = ',';
      startRow = 1;
      
  % Scan document
    dataArray = textscan(fid, formatSpec, 'Delimiter', delimiter,...
       'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN,'HeaderLines',...
       startRow-1, 'ReturnOnError', false);

   lat=dataArray{1,1};
   lon=dataArray{1,2};
   
   fclose(fid);
end
