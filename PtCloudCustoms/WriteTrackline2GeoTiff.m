function WriteTrackline2GeoTiff(data,Config)
% Exports Bahtymerty and corresponding Statistic parameter as geotiff
%
% Band  1 Bathymerty
% Band  2 Tile ID of the current Survey profile
% Band  3 Cross-Track Tile ID of the current Survey profile
% Band  4 median of Tile
% Band  5 std of Tile
% Band  6 range of Tile
% Band  7 rms of Tile
% Band  8 kurtosis of Tile
% Band  9 skewness of Tile

%%

if strcmp(Config.WriteGeoTiff ,'true') 
    txt= sprintf('\tExport Tile as GeoTiff:');
    varunit=[];
    Verbose(txt,' ',varunit)
    
    
    
    if isempty(data.statistics)
       fprintf('\t\t-> No statistic data available in struct\n')
       return; 
    end
    
    
    OutputDir= [data.Directory '\'];
    name_bathy= ['Tiff_Bathymerty_' data.ScanName(1:end-4)];
    name_bathy_avg= ['Tiff_Averaged_Bathymerty_' data.ScanName(1:end-4)];
    name_bathy_res= ['Tiff_Resdidual_Bathymerty_' data.ScanName(1:end-4)];
    
    xx=data.gridded.xx;  
    yy=data.gridded.yy;  
    
    key.ProjectedCSTypeGeoKey = Config.GeoKey;% WGS84 UTM 32N  
    R7 = maprasterref('RasterSize',size(data.gridded.Z),...
                        'ColumnsStartFrom','south');
    
    R7.XWorldLimits=[xx(1) xx(end)];
    R7.YWorldLimits=[yy(1) yy(end)];  
       
    tvalue=Config.SetTransperentValue;


    %% Bathymetrie with statistic parameters

    Data2Tiff_Bathy=cat(3,setTvalue(data.gridded.Z,tvalue),...      
                          setTvalue(data.statistics.Elev_grid.TileID,tvalue),...
                          setTvalue(data.statistics.Elev_grid.CrossTrackID,tvalue),...
                          setTvalue(data.statistics.Elev_grid.median,tvalue),...
                          setTvalue(data.statistics.Elev_grid.std,tvalue),...
                          setTvalue(data.statistics.Elev_grid.range,tvalue),...
                          setTvalue(data.statistics.Elev_grid.rms,tvalue),...
                          setTvalue(data.statistics.Elev_grid.kurtosis,tvalue),...
                          setTvalue(data.statistics.Elev_grid.skewness,tvalue));

   Data2Tiff_Bathy=double(Data2Tiff_Bathy);
   OutputName=[OutputDir name_bathy '.tif'];  
   geotiffwrite(OutputName,Data2Tiff_Bathy,R7,'GeoKeyDirectoryTag',key);
    %% Averaged Bathymerty with statistic paramaters

    Data2Tiff_Bathy=cat(3,setTvalue(data.gridded.Z_average,tvalue),...      
                          setTvalue(data.statistics.Elev_grid.TileID,tvalue),...
                          setTvalue(data.statistics.Elev_grid.CrossTrackID,tvalue),...
                          setTvalue(data.statistics.Elev_avg_grid.median,tvalue),...
                          setTvalue(data.statistics.Elev_avg_grid.std,tvalue),...
                          setTvalue(data.statistics.Elev_avg_grid.range,tvalue),...
                          setTvalue(data.statistics.Elev_avg_grid.rms,tvalue),...
                          setTvalue(data.statistics.Elev_avg_grid.kurtosis,tvalue),...
                          setTvalue(data.statistics.Elev_avg_grid.skewness,tvalue));

   Data2Tiff_Bathy=double(Data2Tiff_Bathy);
   OutputName=[OutputDir name_bathy_avg '.tif'];  
   geotiffwrite(OutputName,Data2Tiff_Bathy,R7,'GeoKeyDirectoryTag',key);
    
    
    
    %% Residual Bathymerty with statistic paramaters

    Data2Tiff_Bathy=cat(3,setTvalue(data.gridded.Z_residual,tvalue),...      
                          setTvalue(data.statistics.Elev_grid.TileID,tvalue),...
                          setTvalue(data.statistics.Elev_grid.CrossTrackID,tvalue),...
                          setTvalue(data.statistics.Elev_res_grid.median,tvalue),...
                          setTvalue(data.statistics.Elev_res_grid.std,tvalue),...
                          setTvalue(data.statistics.Elev_res_grid.range,tvalue),...
                          setTvalue(data.statistics.Elev_res_grid.rms,tvalue),...
                          setTvalue(data.statistics.Elev_res_grid.kurtosis,tvalue),...
                          setTvalue(data.statistics.Elev_res_grid.skewness,tvalue));
    
    Data2Tiff_Bathy=double(Data2Tiff_Bathy);
    OutputName=[OutputDir name_bathy_res '.tif'];  
    geotiffwrite(OutputName,Data2Tiff_Bathy,R7,'GeoKeyDirectoryTag',key);
    
    
    
    fprintf('successfull')
end

end


function xOut= setTvalue(xIn,tvalue)
% replaces all nan values in XIn by the defined transparent value
% in QGIS this value will be used as Transparent value
    mask= isnan(xIn);
    xIn(mask==1) =tvalue;
    xOut=xIn;
end