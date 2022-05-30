function [S]= GetStatisticOfTile(S,Config)

    txt=sprintf('\t- Creation of tile statstic in process:');
    Verbose(txt,' ',[])
    N= size(S.processed.Tile,2); % N, Number Tiles in Scanset
    
  % Predefine output vectors for statistics
    [S]= PreDefineStatStuct(S,'Elev',N); 
    [S]= PreDefineStatStuct(S,'Elev_avg',N); 
    [S]= PreDefineStatStuct(S,'Elev_res',N); 

    kurtosisFlag= Config.statistic.rmBIASKurtosis==0;
    skewnessFlag= Config.statistic.rmBIASSkewness==0;

    for n= 1:N % loop over all tiles
        
         idx= S.processed.Tile(n).idx;   % tile id   
          
       % Read data for current tile 
          xt= S.raw.x(idx);  % x values of tile
          yt= S.raw.y(idx);  % y values of tile
          zt= S.raw.z(idx);  % z values of tile
          zt_avg= S.processed.z_average(idx);  % averaged z values of tile
          outlier=S.Outlier.Total(idx);
       
       % remove Outlier  
          xt(outlier)= []; 
          yt(outlier)= [];
          zt(outlier)= [];
          zt_avg(outlier)= [];
          
       % Read Rotation matrix for the horizontal alignment of tiles   
          d= S.processed.Tile(n).PositioningVector; % position vector of tile
          R= S.processed.Tile(n).RotationMatrix; 
          
          
         if isempty(xt) || isempty(R)
             zt_hor=nan;
             zt_avg_hor=nan;
             zt_res_hor=nan;
         else
           % Horizontal alignment of tile in process
             [~,~,zt_hor] = RotateTile(xt, yt, zt, d, R); 
%              zt_hor=zt_hor-mean(zt_hor);
             
             [~,~,zt_avg_hor] = RotateTile(xt, yt, zt_avg,d, R); 

           % Compute resdiual  
             zt_res_hor= zt_hor-zt_avg_hor;
             zt_res_hor=round(zt_res_hor.*100)./100;
             zt_res_hor=zt_res_hor-mean(zt_res_hor);
         
         end
         
         S.statistics.Elev(n).id = S.processed.Tile(n).ID;  
         S.statistics.Elev(n).mean=mean(zt_hor);
         S.statistics.Elev(n).median=median(zt_hor);
         S.statistics.Elev(n).std=std(zt_hor);
         S.statistics.Elev(n).rms=rms(zt_hor);
         S.statistics.Elev(n).range=range(zt_hor);
         S.statistics.Elev(n).kurtosis=kurtosis(zt_hor,kurtosisFlag);
         S.statistics.Elev(n).skewness=skewness(zt_hor,skewnessFlag);
         
         S.statistics.Elev_avg(n).id = S.processed.Tile(n).ID;  
         S.statistics.Elev_avg(n).mean=mean(zt_avg_hor);
         S.statistics.Elev_avg(n).median=median(zt_avg_hor);
         S.statistics.Elev_avg(n).std=std(zt_avg_hor);
         S.statistics.Elev_avg(n).rms=rms(zt_avg_hor);
         S.statistics.Elev_avg(n).range=range(zt_avg_hor);
         S.statistics.Elev_avg(n).kurtosis=kurtosis(zt_avg_hor,kurtosisFlag);
         S.statistics.Elev_avg(n).skewness=skewness(zt_avg_hor,skewnessFlag);
         
         S.statistics.Elev_res(n).id = S.processed.Tile(n).ID;  
         S.statistics.Elev_res(n).mean=mean(zt_res_hor);
         S.statistics.Elev_res(n).median=median(zt_res_hor);
         S.statistics.Elev_res(n).std=std(zt_res_hor);
         S.statistics.Elev_res(n).rms=rms(zt_res_hor);
         S.statistics.Elev_res(n).range=range(zt_res_hor);
         S.statistics.Elev_res(n).kurtosis=kurtosis(zt_res_hor,kurtosisFlag);
         S.statistics.Elev_res(n).skewness=skewness(zt_res_hor,skewnessFlag);
         
         
         
    end
    
    fprintf('[done]')
    
end



function [S]= PreDefineStatStuct(S,Fieldname,N)

     S.statistics.(Fieldname)(N).id = []; 
     S.statistics.(Fieldname)(N).mean=[];
     S.statistics.(Fieldname)(N).median=[];
     S.statistics.(Fieldname)(N).std=[];
     S.statistics.(Fieldname)(N).range=[];
     S.statistics.(Fieldname)(N).rms=[];
     S.statistics.(Fieldname)(N).kurtosis=[];
     S.statistics.(Fieldname)(N).skewness=[];    

end

function [X,Y,Z] = RotateTile(x,y,z,d,R)
% R : Rotation Matrix   
% d : Positioning Vector

% Transpose point cloud into origin to use rotation function    
      x= x-d(1); y= y-d(2); z= z-d(3);
      
% Rotate Point cloud around origin       
      X=  R(1,1).*x+ R(1,2).*y+ R(1,3).*z;
      Y=  R(2,1).*x+ R(2,2).*y+ R(2,3).*z;
      Z=  R(3,1).*x+ R(3,2).*y+ R(3,3).*z;
      
% Transpose Point cloud back to original position 
      X= X+d(1); Y= Y+d(2); Z= Z+d(3); 
      
           
end