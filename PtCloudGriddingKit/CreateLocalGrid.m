function [S]= CreateLocalGrid(S,Config)
% Creates Grid for the entire Profile. Distingures between outlier removed 
% averaged ping and true depth bathymerty

%     Verbose('- Creation of local grids in process:',' ',[])
    fprintf('\n\t\t- Creation of local grids in process:..........................');
             
    dx=Config.GridResolution; % Grid resolution 
    Grid_method= Config.GridMethod;
    TileLimitsX= Config.Tile.LengthX ;
    TileLimitsY= Config.Tile.LengthY ;

    x= S.raw.x;
    y= S.raw.y;
    z= S.raw.z;
    z_averaged=S.processed.z_average;
    
    
    N=size(S.processed.Tile,2);
   
    S.gridded.Tile(N).ID_grid=[];   
    S.gridded.Tile(N).Z=[];   
    S.gridded.Tile(N).Z_average=[];  
    S.gridded.Tile(N).Z_residual=[]; 
    S.gridded.Tile(N).Z_spatial=[];
    
  % Create Global Grid to grid local tiles 
     xx=  min(x(:)):dx:max(x(:)); % Wolrd X coorinate
     yy=  min(y(:)):dx:max(y(:)); % Wolrd Y coorinate  
     
  % add vectors to output struct
     S.gridded.xx=xx;
     S.gridded.yy=yy;    
     
    [XX,YY] = meshgrid(xx,yy); % Global World Grid
    Grid_ID = 1:length(XX(:));
    DispProgress = round(linspace(1,N,15)); % for progress feedback
    counter1 = 1;
    
    for n= 1:N 
        
       % Read data for current tile 
         idx= S.processed.Tile(n).idx;   % tile id
          xt= x(idx);  % x values of tile
          yt= y(idx);  % y values of tile
          zt= z(idx);  % z values of tile
         zt_avg= z_averaged(idx);  % averaged z values of tile
         rotAngle=S.processed.Tile(n).rotAngle; % rot angle of tile relative to xy plain
         d=S.processed.Tile(n).PositioningVector; % position vector of tile
         R=S.processed.Tile(n).RotationMatrix; % rotation matrix between face normal of tileand Z axis
    
       % Remove outliers
         id_outlier=S.Outlier.Total(idx);
         xt(id_outlier)= []; 
         yt(id_outlier)= [];
         zt(id_outlier)= [];
         zt_avg(id_outlier)= [];
         
         if ~isempty(xt) && ~isempty(R) && length(xt)>Config.lowerPointLimit4LocalGridding
           %%___________________________________________________________________
           % Computation Section of Surfaces

           % perform horizontal rotation
           % 1) for z values
             [~,~,zt_hor] = RotateTile(xt, yt, zt, d, R); 

           % 2) for averaged z values
             [xt,yt,zt_avg_hor] = RotateTile(xt, yt, zt_avg,d, R); 

           % 3) rotate surface from 1)parallel to XY plain for spatial analysis
             [theta,roh,z_pol]=cart2pol(xt,yt,zt_hor);
             [~,~,zt_par]=pol2cart(theta-rotAngle,roh,z_pol); % Surface points

           % 4) compute resdiual surface
             zt_res = zt_hor - zt_avg_hor;

          %%___________________________________________________________________         

          % Get X,Y direction vector for surfaces 2  
             xx_Par = -TileLimitsX/2:dx:TileLimitsX/2;
             yy_Par = -TileLimitsY/2:dx:TileLimitsY/2;
             [XX_par,YY_Par] = meshgrid(xx_Par,yy_Par);
          
          % Grids local tile in global reference frame    
             flag=inpolygon(XX,YY,S.processed.Tile(n).vertX,...
                                        S.processed.Tile(n).vertY);
                                    
           % get local grid coods from global grid layer                        
             [XX_loc,YY_loc]=meshgrid(unique(XX(flag)),unique(YY(flag)));
             id_grid=inpolygon(XX(:),YY(:),XX_loc(:),YY_loc(:));
          
           % Store XY Vec to Stuct              
             warning('off','all') % Warning results form averaging multiple values ;
                     % Grid Surface 1)               
                       Z = griddata(xt,yt,zt_hor,XX_loc,YY_loc,Grid_method);                      
                     % Grid Surface 2)  
                       Z_spatial = griddata(xt-d(1),yt-d(2),zt_par,XX_par,YY_Par,Grid_method);
                     % Averaged Surface rotated into horizontal position 
                       Z_average = griddata(xt,yt,zt_avg_hor, XX_loc,YY_loc,Grid_method); 
                     % Residual Surface rotated into horitional position   
                       Z_residual = griddata(xt,yt,zt_res, XX_loc,YY_loc,Grid_method); 
             warning('on','all')  
             
             S.gridded.Tile(n).ID_grid= Grid_ID(id_grid); 
             S.gridded.Tile(n).Z=Z;   
             S.gridded.Tile(n).Z_average= Z_average; 
             S.gridded.Tile(n).Z_residual=Z_residual;
             S.gridded.Tile(n).Z_spatial=Z_spatial;            
         end
         
         if n == DispProgress(counter1)
            counter1 = counter1+1;
            fprintf('|');
        end
         
         
         
    end
    
   
    
   fprintf(' \t\t[done]')
    
end

function [X,Y,Z] = RotateTile(x,y,z,d,R)
% R : Rotation Matrix   
% d : Positioning Vector

% Transpose point cloud into origin to apply rotation function    
      x= x-d(1); y= y-d(2); z= z-d(3);
      
% Rotate Point cloud around origin       
      X=  R(1,1).*x+ R(1,2).*y+ R(1,3).*z;
      Y=  R(2,1).*x+ R(2,2).*y+ R(2,3).*z;
      Z=  R(3,1).*x+ R(3,2).*y+ R(3,3).*z;
      
% Transpose Point cloud back to original position 
      X= X+d(1); Y= Y+d(2); Z= Z+d(3); 
      
           
end