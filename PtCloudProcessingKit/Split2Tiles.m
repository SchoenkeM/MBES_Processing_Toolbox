function [S]= Split2Tiles(S,Config)
% Computes Gridnodes for a point cloud 
% [Tile]= Split2Tiles(X,Y,cx,cy,lenX,lenY)
%  X: x-coords
%  Y: y-coords
% cx: Center Line x-coords in UTM
% cy: Center Line Track y-coords in UTM
% lenX: length of area in X direction
% lenY: length of area in Y direction

% not implementet yet -> Overlap: is the overlap in [%] between tiles
%
% Bugfix: 
%
% 11.12.2021 
% line 150: Thershold value is set from max to median
%
%
% debugPlot=1; for debug purpose

lengthX = Config.Tile.LengthX;  % [m] in horizontal along ship direction
lengthY = Config.Tile.LengthY;  % [m] in horizontal acorss ship direction
NrCrossTiles= Config.Tile.NrOfCrossTrackTiles;
PolylineDir= Config.Tile.CenterLine;      
threshold=Config.Tile.lowerPointPercInTile;
x = S.raw.x; % import lat from rawdata struct
y = S.raw.y; % import lon from rawdata struct
index = 1:length(x);
%% Computing vectors with length X along sheip track
txt=sprintf('\t- Computing position of tiles along the center line in process:');
Verbose(txt,' ',[])

    if isfile(PolylineDir)
        [cLat,cLon]= ImportPolyLine(PolylineDir);
    else
        fprintf(['\t\t-> Unable to find or open file containing the ',...
            'tile center line from: %s\n'],PolylineDir)
        fprintf('\t\t-> Gridding process aborted\n')
        return; 

    end 
 
% if debugPlot==1                                                             % <------------------- Delete later
%      figure(1) 
%      plot(x,y,'.k')
%      hold on 
%      plot(cLat,cLon,'y.')
%      xlim([min(x) max(x)])
%      ylim([min(y) max(y)])   
% end
% compoutes boundary limits of current survey profile
    k = convhull(x,y);
    xvec= x(k); yvec= y(k);
   
% Checks which ship track positions are located within current MBES profile   
   flag = inpolygon(cLat,cLon,xvec,yvec);    
   cLat=cLat(flag); cLon=cLon(flag); 
   
% if debugPlot==1                                                            % <------------------- Delete later
%    plot(cLat,cLon,'b.')
% end

% Compute tile position along the Shiptrack   
   if ~isempty(cLat) % in case there are no Tiles along the polyline
        [P1,P2,PP2,~]= ComputeTilesAlongTrack(cLat,cLon,lengthX);
        NrOfTiles=NrCrossTiles.*size(P1,2);
        fprintf('[done]')
   else
       P1=[];
       P2=[];
       PP2=[];
       fprintf('[No data points along Polyline]')
       return;
   end
  

%% Loop over all along track position and detect tiles in across track 
% position 
    dy = ceil((0:NrCrossTiles-1) - NrCrossTiles/2);
    N= size(P1,2); 
    M= N*length(dy);
   
    Tile(M).ID=[];
    Tile(M).LongTrackID=[];
    Tile(M).CrossTrackID=[];
    
    Tile(M).vertX=[];
    Tile(M).vertY=[];
    Tile(M).rotAngle=[];
    Tile(M).idx=[];
    Tile(M).NrOfValues=[];

    txt=sprintf('\t- Creation of %.0f tiles in process:',NrOfTiles);
    Verbose(txt,' ',[])
    counter=1; 
    %______________________________________________________________________
    % For loop Start
    for i = 1:N  
      % compute vertex point 3 and 4 based on P1 and P2 and
      % direction vector for the first tile at the Ship track line
         P3 = P2(:,i) + PP2(:,i).*lengthY; 
         P4 = P1(:,i) + PP2(:,i).*lengthY;     
         vertX_temp = [P1(1,i) P2(1,i) P3(1,1) P4(1,1)]; 
         vertY_temp = [P1(2,i) P2(2,i) P3(2,1) P4(2,1)];
 
         for j = 1: NrCrossTiles
           % uses PP2 direction vector to move the Tile from the ship 
           % track in cross track direction up and down, where 
           % positive dy defined for starboard and negative for port side.
             pp= PP2(:,i).*(lengthY.*dy(j));
             vertX= vertX_temp + pp(1);
             vertY= vertY_temp + pp(2);
%              if debugPlot==1                                             % <------------------- Delete later
%                     plot([vertX vertX(1)],[vertY vertY(1)],'r')
%              end
           % get the rotatio value for the Tile relativ to cathesian 
           % x axis
             [theta,~]= cart2pol(vertX-vertX(2),vertY-vertY(2));
             CrossTrackID=dy(j)+(dy(j)>=0)*1;

           % Add to struct 
             Tile(counter).ID=counter;
             Tile(counter).LongTrackID=i;
             Tile(counter).CrossTrackID=CrossTrackID;         
             Tile(counter).vertX=vertX;
             Tile(counter).vertY=vertY;
             Tile(counter).rotAngle=theta(1);
 
            counter = counter+1;                       
         end % end while loop over all tiles on starbord and port side
             
    end % end for loops over all intervalls

    % For loop End
    %______________________________________________________________________
   

% ValuesUsedInPolygons=zeros(size(index)); % Ensure that each x/y value is only assinged to a single tile

for n= 1:size(Tile,2)
   flag = inpolygon(x,y,Tile(n).vertX,Tile(n).vertY); 
   
%     if debugPlot==1                                                            % <------------------- Delete later
%              plot(x(flag),y(flag),'.r')
%     end
%    ValuesUsedInPolygons(flag)=ValuesUsedInPolygons(flag)+1; 
%    flag(ValuesUsedInPolygons(flag)>1)=[];
   Tile(n).idx=single(index(flag));
   Tile(n).NrOfValues=single(sum(flag));
%    
end

% remove Tiles with no data points from scan set
NrOfValues= [Tile.NrOfValues].';
% idx1= NrOfValues==0;

dx=Config.GridResolution;
expectedNrOfDataPoints=lengthX/dx*lengthY/dx;

expectedNrOfDataPoints=max(median(NrOfValues),expectedNrOfDataPoints);
thresholdValue= expectedNrOfDataPoints.*threshold;
idx= NrOfValues<thresholdValue;
Tile(idx)=[];

S.processed.Tile=Tile;
fprintf('[done]')  

    


end %end main function 

function [P1,P2,PP2,Obj_id]= ComputeTilesAlongTrack(cLat,cLon,dx)
% P1 and P2 are the Verticies for one Tile on the Ship track 
% pp2 is the direction vector perpendicual to the direction between P1 and
% P2, which is used to compute tile across the ship track


% To compute the number of tiles in Along track position the 
% function start at the fist ship track position and runes along ship track
% creating vectors along ship track with length dx.
   diff_m= diff([cLat(:),cLon(:)]);
   Tracklength_m= sum(sqrt(sum(diff_m.*diff_m,2))); 
   
% Computes the Number of Tiles along the Track N   
   N= ceil(Tracklength_m./dx); % The ceil rounds up

% the esrimated number of tiles to ensure to covers more distance
% than needed distance
    P1=zeros(2,N);  % Ortsvektor
    P2=zeros(2,N);  % Ortsvektor
    PP2=zeros(2,N); % Richtungsvektor in y
    Obj_id=zeros(1,N); % Richtungsvektor in y
% starts at the first ship track point
    currentPointX=cLat(1); 
    currentPointY=cLon(1);
    Obj_Counter=1;                                                                                               
%% Compute tiles along Ship track position
    for n = 1:N                                                                                     
                                                                                                    
       % computes a circle around current point, to find the next Point in 
       % range dx +1m
         [cx,cy]=kreisdraw(dx+1,currentPointX,currentPointY);

       % flags Ship Track Point within circle
          flag = inpolygon(cLat,cLon,cx,cy); 
        
       if sum(flag)==0
           if ~isempty(cLat)
              currentPointX=cLat(1);
              currentPointY=cLon(1);
           end
              Obj_Counter=Obj_Counter+1; 
           
       else
           
       % computed cummultative distance with the receptor Point as origin    
          diff_m= diff([[currentPointX;cLat(flag)],...
                        [currentPointY;cLon(flag)]]);

          length_m= cumsum(sqrt(sum(diff_m.*diff_m,2))); 
         
       % Finds the closest point along the ship travel direction whose distance 
       % from the receptor point best matches to the tile length. This
       % point is used only to determine the direction of the vector
         idx= find(length_m==max(length_m)); % requires at least one valid distance

       % Uses the direction vector between receptor point and the of the "idx"
       % flaged point to set a point along the path with the exact tile length
         nextPoint= [cLat(idx);cLon(idx)];
         P1(:,n) = [currentPointX;currentPointY]; % current Point "Aufpunkt" for the cicrle
         [pp1,pp2]=GetDirVec(P1(:,n),nextPoint);
         pp= pp1.*dx; % computes a direction vecor with length dx
         P2(:,n)= P1(:,n) + pp; % adds direction vector to the Ortsvector
         PP2(:,n)= pp2; % adds orthogonal direction vector to the struct
%          plot(P1(:,n),P2(:,n),'ro')                                         % <------------------- Delete
       % Overwrites the current point  
         currentPointX=P2(1,n);
         currentPointY=P2(2,n);  
         Obj_id(n)= Obj_Counter;
       % removes ship track poins before current position. With the abolute 
       % distance been used an error may occure that causes to serach the next
       % point in negative travel direction. 
        cLat(flag)=[]; 
        cLon(flag)=[]; % removes ship track poins bevore current position                                                                                             
       end
    end

mask= P1(1,:)==0 & P1(2,:)==0;

P1(:,mask)=[];
P2(:,mask)=[];
PP2(:,mask)=[];


end

function [pp1,pp2]=GetDirVec(P1,P2)
     pp= P2-P1;  
     pp_mag = sqrt(pp(1)^2+pp(2)^2); % compute vector lenght
     pp1= pp./pp_mag;                % devide direction vector by vector length
     pp2= flipud(pp1).* [1;-1];  % defines direction vector perpendicular to track length
end

function [x,y]=kreisdraw(r,dx,dy)
    werte=linspace(0,2,200).*pi; % node points for the circle
    x=r*cos(werte)+dx;
    y=r*sin(werte)+dy;
end

