function  S = FilterByDetectionWindow (S,Config)	
% Flaged sounding of a ping which lie outside the set detection window 
% above or below a refernece hight. The referece height can be set to 
% the movining average (if computed) or alternative the median or mean of a 
% ping. 
%
% Version 0.1
                    
if strcmp(Config.FilterByDetectionWindow,'true') 
    
    
       txt= sprintf('\t- Filtering data points outside detection range in process: ');               
       varin =  ' ';   
       varunit = [];       
       Verbose(txt,varin,varunit) 
       
     % read parameter from Stuct
       detectionRange = Config.DetectionRange;
       ref_H = Config.ReferenceHeight ;
       z=S.raw.z;
       ping = S.raw.ping;
       
      % predefine variables  
       z_ref=nan(size(z)); % blank vectors for possible outliers
       PingRange = unique(ping); % Get vector from min to max ping.
       N = length(PingRange);  % number of pings in Profile
           
       switch ref_H
           case 'MovAverage'
               if strcmpi(Config.ComputeMovAverageFromPings,'true')
                    z_ref= S.processed.z_average;
               else
                   fprint('\n\t -> Moving average computation is required to use MovAverage as input option');  
                   fprint('\n\t -> FilterByDetectionWindow failed');
                   return;
               end
           case 'median'
                    for n = 1:N % loop over all pings
                        idx = PingRange(n)==ping; % columns containing the current ping
                        z_ref(idx) =  nanmedian(z(idx));        
                    end
               
           case 'mean'
                    for n = 1:N % loop over all pings
                        idx = PingRange(n)==ping; % columns containing the current ping
                        z_ref(idx) =  nanmean(z(idx));        
                    end
           otherwise
               fprint('\n\t -> Unrecognized input type for refence height: %s',ref_H);
               fprint('\n\t -> FilterByDetectionWindow failed');
               return; 
       end
      
     % substract the reference height from the elevation values
       z_filt= z-z_ref; 
       
     % flag values outside detection window or nan values
       flag = z_filt> max(detectionRange) | z_filt<min(detectionRange)| ...
           isnan(z_filt);
       
       % plot3(S.raw.x,S.raw.y,S.raw.z,'.k');
       % hold on 
       % plot3(S.raw.x(flag),S.raw.y(flag),S.raw.z(flag),'or');  
       
     % writes results to struct   
       S.Outlier.FilterByDetectionWindow =  flag;  
       S = UpdateOutlier(S);

       fprintf('[done]') 
       QualityCheck(flag)
else
    
       flag=zeros(size(S.raw.z))==1;
       S.Outlier.FilterByDetectionWindow =  flag;  
       S = UpdateOutlier(S);
    
end
 
end

