function [S]= AssingStatisticParameters2Grid(S)



 
                        
  % Loop to plot surface bathy of tile in a global frame.   
 
    Global_ID=S.gridded.ID_Stat2Glob;

    varStuct.median=nan(size(Global_ID));
    varStuct.std=nan(size(Global_ID));
    varStuct.range=nan(size(Global_ID));
    varStuct.rms=nan(size(Global_ID));
    varStuct.kurtosis=nan(size(Global_ID));
    varStuct.skewness=nan(size(Global_ID));
    
    Elev_grid=varStuct;
    Elev_grid.TileID=nan(size(Global_ID));
%     Elev_grid.LongTrackID=nan(size(Global_ID));
    Elev_grid.CrossTrackID=nan(size(Global_ID));
    
    Elev_avg_grid=varStuct;
    Elev_res_grid=varStuct;
    
    N=size(S.processed.Tile,2);    
    DispProgress = round(linspace(1,N,15)); % for progress feedback
    counter1 = 1;
    
    fprintf('\n\t\t- Creation of global grid statstic in process:.................');  
    for n = 1:N
    
      % calls Tile grid id
      
        tile_ID= S.statistics.Elev(n).id;
        flag= Global_ID==tile_ID;
      
        
        Elev_grid.TileID(flag)=single(S.processed.Tile(n).ID);      
%      Elev_grid.LongTrackID(flag)=single(S.processed.Tile(n).LongTrackID);     
        Elev_grid.CrossTrackID(flag)=single(S.processed.Tile(n).CrossTrackID);
        
        Elev_grid.median(flag)=S.statistics.Elev(n).median;
        Elev_grid.std(flag)=S.statistics.Elev(n).std;
        Elev_grid.range(flag)=S.statistics.Elev(n).range;
        Elev_grid.rms(flag)=S.statistics.Elev(n).rms;
        Elev_grid.kurtosis(flag)=S.statistics.Elev(n).kurtosis;
        Elev_grid.skewness(flag)=S.statistics.Elev(n).skewness;

        Elev_avg_grid.median(flag)=S.statistics.Elev_avg(n).median;
        Elev_avg_grid.std(flag)=S.statistics.Elev_avg(n).std;
        Elev_avg_grid.range(flag)=S.statistics.Elev_avg(n).range;
        Elev_avg_grid.rms(flag)=S.statistics.Elev_avg(n).rms;
        Elev_avg_grid.kurtosis(flag)=S.statistics.Elev_avg(n).kurtosis;
        Elev_avg_grid.skewness(flag)=S.statistics.Elev_avg(n).skewness;

        Elev_res_grid.median(flag)=S.statistics.Elev_res(n).median;
        Elev_res_grid.std(flag)=S.statistics.Elev_res(n).std;
        Elev_res_grid.range(flag)=S.statistics.Elev_res(n).range;
        Elev_res_grid.rms(flag)=S.statistics.Elev_res(n).rms;
        Elev_res_grid.kurtosis(flag)=S.statistics.Elev_res(n).kurtosis;
        Elev_res_grid.skewness(flag)=S.statistics.Elev_res(n).skewness;
    
        if n == DispProgress(counter1)
            counter1 = counter1+1;
            fprintf('|');
        end
    end  
    
  % Write bathymerty 2 Output Stucture
    S.statistics.Elev_grid = Elev_grid;
    S.statistics.Elev_avg_grid = Elev_avg_grid;
    S.statistics.Elev_res_grid = Elev_res_grid;

    fprintf(' \t\t[done]')
    
end

