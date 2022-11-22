% Spatial Processing Software is an approach to classify anthropogenic 
% impaced seafloor surface by bottom trawling, whose characteristics 
% differ significantly from geologic morphologies. Advantage is that the
% statistic of the measured bathymerty is computed befor the aktual
% grid is performed
%
%
% Update 25.08.2021 v0.1
% Include QPS exportet Ship track to compute tiles. 
%
% Update 01.10.2021 v0.2
% Major changes. Create stand alone version exclusivly  
% for Mulitbeam application
%
% Update 30.11.2021 
% Major changes. Implement a loop over all processing steps, so that 
% files are porcessed one after another, which saves the RAM not to
% get overloaded and allows the function to be run on every PC.
% Therefore all feedback loops got adjusted. 
%
% BugFix 10.12.2021 
% In Split2Tile line 150; It appeared during Ship turns, that the max value
% of points in tile exceeds more than 55000, which was the previous
% reference value to compute the 10% threshold. Several tiles with less 
% than 5000 data points were wrongly deleted, so that whole profiles were
% empty after processing.
%
% Update 12.01.2022
% In WriteTrackline2GeoTiff function. Qgis can not handle nan values, which
% lead to errors in several GDAL functions. Therefore option is
% implemented to chose between the options "nan" and "-9999" for 
% transparent values
% 
%
%
% First Release 30.11.2021 v1.0.1 
% 
%
%
%
% Know Bug and issiue: 
%
% - several function discriptions are still missing
% - Spatial Processing function exist but is not implemented so far
% - the bands in output GeoTiff have no labeling ( just numbert 1 to 11)
% - the average median function is to too slow without parfor loop and is  
%   not implemented
% 
%==========================================================================
% Copyright including all subfunctions by the author Mischa Sch�nke, 2021 
%
% mail: mischa.schoenke@io-warnemuende.de
%
% This function was developed within the MGF project, for the purpose
% to improve the evaluation of small scale surface feature measured
% by a multibeam echosunder. 
%
% Revision 1.0  2021/11/30
%==========================================================================

close all
clear all

%% ========================================================================

% Setup paths relative to git repository
areaId  = 'Control'; % Either 'Control' or 'MPA'
BaseDir = '../../GIS/layers/data/QPSSourceFile';

ShipTrackDir = [BaseDir,'/Tracklog_',areaId];
ShipTrackName = ['ShipTrack_',areaId,'.txt'];

%% ========================================================================
% Use JoinShipTracks to join multiple QPS Ship tracks files for an entire
% survey areas. A Ship track is required for propper MBES bathymetry tiles 
% processing. 
% InputDir: folder containing all ship tracks exported form QPS
% example:  JoinShipTracks(InputDir,OutputName.txt)

JoinShipTracks(ShipTrackDir,ShipTrackName);

%% ========================================================================
% Specify Imput folder for MBES Data, which were QPS exported and stored 
% as x,y,z,beanAngle,PingNumber *.txt- files

%__________________________________________________________________________
% Relative to git repository

MBESInputData = []; % set path to folder containing MBES data here 

ShipTrackDir= fullfile(ShipTrackDir,ShipTrackName);

%% Settings Section
%==========================================================================         
    Config.LoadRawDataIfExist          = 'true';
    Config.LoadProcessedDataIfExist    = 'true';
    Config.LoadGridDataIfExist         = 'true'; 
    Config.LoadStatisticDataIfExist    = 'true';     
     
% Set Global Filter:
    Config.FilterBeamsWith2FewValues    = 'true';        
    Config.minPercentage4BeamValues     = 0.1;            % [%] Flags Beam angles with less than 10% of the maximal number of data points per Beam (max. Nr. = 256).
   
    Config.FilterPingsWith2FewValues    = 'true';
    Config.minPercentage4PingValues     = 0.3;            % [%] Flags Pings with less than 30% of the maximum number of data points per Ping .

    Config.FilterSwathBeams             = 'true';
    Config.Beams2Remove                 = [1:35,965:1000];  % removes the selected beam swath angels (e.g. [1,4,145:150])         
   
    Config.ComputeMovAverageFromPings   = 'true';         
    Config.SmoothWindow                 = 0.1;            % Use a span of 10% of the total number of data points per ping to compute a moving average for each ping.
    Config.minSampleNr2ComputeAverage   = 30;             % min Number of samples required to compute moving average
    
    Config.FilterByDetectionWindow      = 'true';         
    Config.ReferenceHeight              = 'MovAverage';   % [MovAverage,median, mean] -> reference height for vertical detection window
    Config.DetectionRange               = [-0.5 +0.5];    % [m] in vertical direction -> 0 is refenenz hiigh of current ping  
    
    Config.Tile.CenterLine              = ShipTrackDir;   % A polyline is required as center line for tile processing
    Config.Tile.LengthX                 = 10;             % along line length[m]  
    Config.Tile.LengthY                 = 10;             % across line length [m]
    Config.Tile.NrOfCrossTrackTiles     = 8;              % the number of tiles is symmetrically aligned to the center line
    Config.Tile.lowerPointPercInTile    = 0.10;           % minimum percentage of Points in Tile compared to maximal number of points
    
    Config.statistic.rmBIASKurtosis     = 1;   % [1] bias is removed; 0 Bias is not removed     
    Config.statistic.rmBIASSkewness     = 1;   % [1] bias is removed; 0 Bias is not removed  
    
% Grid Data config         
    Config.RemoveOutlier                 = 'true';
    Config.GridResolution                = 0.25;      % Grid resolution [m]  
    Config.GridMethod                    = 'natural'; % Grid Method: ['linear','nearest','natural','cubic']  
    Config.lowerPointLimit4LocalGridding = 50;        % valid minimum number of Points (per defined squaremeter) for gridding, after Outlier removal                          
    Config.AllowTilesToOverlapInGrid     = 'false';
    Config.ValidTileOverplapPercentage   = 0.30;
    Config.MuteCrossTilesInGrid          = [];         % except 0; tile cross tile id runs 1:N in starboard direction and -1:-N in port direction
   
% Write to Geotif config       
    Config.WriteGeoTiff                  = 'true';
    Config.GeoKey                        = 32632;     % UTM 32 N, WGS 84
    Config.SetTransperentValue           = -9999;


%==========================================================================   
%% Processing Section (Do not edit here)
%   
%tic
    runDataAnalysis(MBESInputData,Config) 
%toc     
%% Control Plot Examples


%==========================================================================
% Section to image resaults
%     FileList = GetImportListFromDir(MBESInputData,'*.txt');
%     id=12;
%     DispSwathAngleRange(MBESInputData,id)
%     QuickDispStatGrid(MBESInputData,id,'rms')
%     ControlPlot(MBESInputData,id)
%     OutlierPlot(MBESInputData,id)   
%     PlotTiles(MBESInputData,ShipTrackDir,id)