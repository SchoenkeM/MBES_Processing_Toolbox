function action = CheckIfDataIsAlongPolyline(S,Config)

   action=[];
    PolylineDir= Config.Tile.CenterLine;     
    if isfile(PolylineDir)
        [cLat,cLon]= ImportPolyLine(PolylineDir);
    else
        fprintf(['\n\t\t-> Unable to find or open file containing the ',...
            'tile center line from: %s\n'],PolylineDir)
        fprintf('\t\t-> Gridding process aborted\n')
        action = ~isempty(action);
        return; 

    end 
    
% import lat from rawdata struct
    x = S.raw.x; 
    y = S.raw.y; % import lon from rawdata struct


% compoutes boundary limits of current survey profile
    k = convhull(x,y);
    xvec= x(k); yvec= y(k);
   
% Checks which ship track positions are located within current MBES profile   
   flag = inpolygon(cLat,cLon,xvec,yvec);    
   cLat=cLat(flag); 
   
   action = ~isempty(cLat);
   
   if action == 0
       txt=sprintf('\n\t- No MBES position detected along the polyline:');
       Verbose(txt,' ','[Analyis aborted]')          
   end

end