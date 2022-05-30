function  S = GetAlignmentOfTiles(S)
% Function in the first step the uniquetol box reduces the data set, by 
% fitting a strongly reduced number of equally distributed intepolated and 
% unique values inside the point cloud. In a secound step polyfit box is 
% used to fit a plain inside the unique values from the first step.
% In a third step a rotation matrix R is derived by the normal vector from 
% the fitted plain and any vector lying on to the -z axis. The resulting 
% rotation matrix R is used to rotate the orignal x,y,z- point cloud values
% onto a plain parallel to the x axis. 
 

% Read x,y,z data from struct  

   
fprintf('\n\t\t- Determining the spatial alignment of tiles in process:.......');
x= S.raw.x; 
y= S.raw.y; 
z_lf= S.processed.z_average;

outlier=S.Outlier.Total;

N=size(S.processed.Tile,2);


Factor=10;                  % Comnpression Factor to compute the compensation area   
alignmentVector = [0 0 -1]; % Normal vector of the compensation area 
                                  ...parallel to the alignment Vector

DispProgress = round(linspace(1,N,15)); % for progress feedback
counter1 = 1;                              

for n= 1:N % loop over all tile of the current profile profile
    vertex_x=S.processed.Tile(n).vertX; % x vertex of the current tile
    vertex_y=S.processed.Tile(n).vertY; % y vertex of the current tile
    idx=S.processed.Tile(n).idx; % index of the z values of the current tile

  % create current data set based on index 
    temp_x=x(idx);
    temp_y=y(idx);
    temp_z=z_lf(idx);
    currentOutlier=outlier(idx);

%         figure(1)
%         plot(x,y,'k.')
%         hold on 
%         plot(vertex_x,vertex_y,'r')
%         plot(temp_x,temp_y,'or')
%         drawnow 
%         pause(1)
%         hold off
%         
  % removes outlier from current data set 
    if sum(currentOutlier)>0
        temp_x(currentOutlier)=[];
        temp_y(currentOutlier)=[];
        temp_z(currentOutlier)=[];
    end

   % divides the point cloud within the x and y verticies into smaller
   % tiles, where each subtile x,y length is 10% of the total tile length.
   % Within each subtile the median of the corresponding x,y,z values 
   % is been computed. 
    [xcomp,ycomp,zcomp]=CompressTile(temp_x,temp_y,temp_z,...
                                             vertex_x,vertex_y,Factor);
                                         
    % zcomp is a xxn matrix were m and n are size Factor-1 max 81 values
    if isempty(zcomp) || length(zcomp(:))< (Factor-1) % 10 percent of samples required to compute surface alinment    
        d=[];
        R=[];
        FitConfidence{1,2}=[];
        FitConfidence{2,2}=[];
    else    
        % Fit plain throgh Point Cloud and compute rotation matrix between norm
        % vector of the fitted plain and Z axis in negative direction.
        [R,d,FitConfidence]= GetPtCloudRotMat(xcomp,ycomp,zcomp,alignmentVector);     
    end

   % Add computation details to the tile stuct 
     S.processed.Tile(n).PositioningVector = d;
     S.processed.Tile(n).RotationMatrix = R;
     S.processed.Tile(n).FitConfidence_rmse = FitConfidence{1,2};
     S.processed.Tile(n).FitConfidence_r2   = FitConfidence{2,2};

    if n == DispProgress(counter1)
        counter1 = counter1+1;
        fprintf('|');
    end

end 


fprintf(' \t\t[done]')



end 



function [xcomp,ycomp,zcomp]=CompressTile(x,y,z,vertex_x,vertex_y,Factor)

lenX=norm([vertex_x(1) vertex_y(1)]-[vertex_x(2) vertex_y(2)]); % len vector in x 
lenY=norm([vertex_x(1) vertex_y(1)]-[vertex_x(4) vertex_y(4)]); % len vector in y 

ppx=([vertex_x(2) vertex_y(2)]-[vertex_x(1) vertex_y(1)])./lenX; % dir vector in x
ppy=([vertex_x(4) vertex_y(4)]-[vertex_x(1) vertex_y(1)])./lenY; % dir vector in y

xIntervalls=linspace(0,lenX,Factor);
yIntervalls=linspace(0,lenY,Factor);

[xx,yy]=meshgrid(xIntervalls,yIntervalls); % length multiplier

% multiply the vertex points times the vector length to compute a grid 
% with the aliment parallel to the directorn vectors from x and y
XX= xx.*ppx(1)+yy.*ppy(1)+vertex_x(1); 
YY= xx.*ppx(2)+yy.*ppy(2)+vertex_y(1);

N=length(xIntervalls)-1;
M=length(yIntervalls)-1;

xcomp=nan(N,M);
ycomp=nan(N,M);
zcomp=nan(N,M);

% get median value for each grid cell
% geht besser, aber hatte ich keine Zeit zu 
for n= 1:N
    for m= 1:M
        xv=[XX(n,m) XX(n+1,m) XX(n+1,m+1) XX(n,m+1)];
        yv=[YY(n,m) YY(n+1,m) YY(n+1,m+1) YY(n,m+1)];
        flag=inpolygon(x,y,xv,yv);
        xcomp(n,m)=nanmedian(x(flag));
        ycomp(n,m)=nanmedian(y(flag));
        zcomp(n,m)=nanmedian(z(flag));
    end
end

% remove gridd cells with no data points
mask=isnan(xcomp);
xcomp(mask)=[];
ycomp(mask)=[];
zcomp(mask)=[];

end

function [R,d,FitConfidence]= GetPtCloudRotMat(x,y,z,v)
% The functions computes the rotation matrix R to rotate the point cloud 
% defined by x,y,z to be rotated orthogonally to the imput vector
% v[x´,y´,z´]
%
% Version 0.1
               
    % Builds grid with 20 points from thinned scan set
       NumberOfNodes=40; 
  
       [X,Y] = meshgrid(linspace(min(x(:)),...
                                 max(x(:)),NumberOfNodes),...
                        linspace(min(y(:)),...
                                 max(y(:)),NumberOfNodes));            

    % Prepares Data for surface fitting toolbox
       [xData, yData, zData] = prepareSurfaceData(x(:),y(:),z(:));
                                                 
                                             
    % Set up fittype and options.                                            
       ft = fittype( 'poly11' );

    % Fit model to data.
    warning('off')
       [fitresult,gof2] = fit( [xData, yData], zData, ft );     
     warning('on')       
    % Extract plain coefficients Fit_z =@(x,y) a + b*x + c*y;
       a = fitresult.p00; b = fitresult.p10; c = fitresult.p01;
       
    % Extract goodness of fit
%        rmse = gof2.rmse; rsquare= gof2.rsquare;
       FitConfidence = [{'rmse'} {gof2.rmse};...
                         {'rsquare'} {gof2.rsquare}];
                     
    % Fit plain to get fittet x1 y 2 z1 data   
       FitPlain = @(x,y) a + b*x + c*y; % create funtion for plain fit
           zfit = FitPlain(X(:),Y(:)); % fit plain
        median_X = median(X(:));
        median_Y = median(Y(:));
        median_Z = FitPlain(median_X,median_Y); % fit plain
               d = [median_X; median_Y;median_Z]; % Lotfu� der Ebene
    % compute grid to build matrix from plainfit function zfit
        Z = reshape(zfit,NumberOfNodes,NumberOfNodes);

    % extrakt Points from Marix        
        P1 = [X(end,1),Y(end,1),Z(end,1)];    
        P2 = [X(1,1),Y(1,1),Z(1,1)];
        P3 = [X(end,end),Y(end,end),Z(end,end)];

    % computes direction vector    
        P21=P1-P2;  P31=P1-P3;

    % computes cross product    
        normal = cross(P21, P31);

    % compute norm vector    
        n = normal./norm(normal).*-1;

    % cumputes rotation matrix
        R = fcn_RotationFromTwoVectors_v01( n, v);
        
end

function  R = fcn_RotationFromTwoVectors_v01(A, B)
% http://math.stackexchange.com/questions/180418/calculate-rotation
% -matrix-to-align-vector-a-to-vector-b-in-3d
%
% R*v1=v2
% v1 and v2 should be column vectors with 3x1 dimensions

%% Method 3
    v = cross(A,B);
    ssc = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
    R = eye(3) + ssc + ssc^2*(1-dot(A,B))/(norm(v))^2;
end