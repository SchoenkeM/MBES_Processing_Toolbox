function [S]= CreateGlobalGrid(S,Config)
% Creates Grid for the entire Profile. Distingures between outlier removed 
% averaged ping and true depth bathymerty
    txt=sprintf('\t- Creation of global grids in process:');
    Verbose(txt,' ',[])
    
    Mask_Z=nan(length(S.gridded.yy),length(S.gridded.xx)); % 12 Mb pro file
    Mask_Z_avg=nan(size(Mask_Z));  % 12 Mb pro file
    Mask_Z_res=nan(size(Mask_Z));  % 12 Mb pro file
    ID_Stat2Glob= nan(size(Mask_Z));   
    AllowOverlap= Config.AllowTilesToOverlapInGrid; 
    threshold   = Config.ValidTileOverplapPercentage;
    muteCorssTiles = Config.MuteCrossTilesInGrid;
       
    if isempty(muteCorssTiles)
        muteCorssTiles=0; % id zero is nor assinged during processing
    end
    
  % Loop to plot surface bathy of tile in a global frame.   
    N=size(S.processed.Tile,2);    
    for n = 1:N
    
      % calls Tile grid id
        grid_ID= S.gridded.Tile(n).ID_grid;
        
      % calls Tile bathymety values   
        Z = S.gridded.Tile(n).Z(:);
        Z_avg = S.gridded.Tile(n).Z_average(:);
        Z_res = S.gridded.Tile(n).Z_residual(:);
        
      % clear out NaN values from local grid to prevent overwriting of 
      % valid neighborinig bathymery vlaues by nans. 
        flag=isnan(Z);
        grid_ID(flag)=[];
        Z(flag)=[];
        Z_avg(flag)=[];
        Z_res(flag)=[];
        
        if strcmp(AllowOverlap,'false')       
          % number of remaining Data points written to grid modified by
          % threshold
            M = length(Z); 
            validNumerOfNoneNaNs=round(threshold*M);
            M=M-validNumerOfNoneNaNs;
            
          % number of nans in global grid position reserved for the 
          % current tile
            currentMask = Mask_Z(grid_ID);
            idx= sum(isnan(currentMask));
            
          % clear out nan values, which are not required for the global grid 
            if  idx<M
                grid_ID=[];
                Z=[];
                Z_avg=[];
                Z_res=[];
            end
        end
    
        current_CorssTrackID= S.processed.Tile(n).CrossTrackID;
        checkID= any(muteCorssTiles==current_CorssTrackID);
        if checkID
           grid_ID=[];
           Z=[];
           Z_avg=[];
           Z_res=[];
        end
        
      % writes value to mask    
        Mask_Z(grid_ID) = Z;
        Mask_Z_avg(grid_ID) = Z_avg;
        Mask_Z_res(grid_ID) = Z_res;
    
        ID_Stat2Glob(grid_ID)=S.processed.Tile(n).ID;  
    
    end  
    
  % Write bathymerty 2 Output Stucture
    S.gridded.ID_Stat2Glob = ID_Stat2Glob;
    S.gridded.Z          = Mask_Z;
    S.gridded.Z_average  = Mask_Z_avg;
    S.gridded.Z_residual = Mask_Z_res;
   

   fprintf('[done]')
    
end

