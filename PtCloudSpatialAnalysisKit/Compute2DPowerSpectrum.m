function [S]= Compute2DPowerSpectrum(S) 

% Required Input
global Config


 TaperType = Config.TaperMethod;
GridMethod = Config.GridMethod;
       res = Config.GridResolution;
 tileSizeX = Config.GridLimitsX;
 tileSizeY = Config.GridLimitsY;
 
%% 
% Parameter which are only depending on the settings and are
% consistent for all tiles
 dimMax = length(0:res:tileSizeX);   
    np2 = 2.^nextpow2(dimMax);
    
     sx = (1/(res)); %sampling rate
     sy = (1/(res)); %sampling rate
    
    fqx = GetFreqVec(np2,sx); 
    fqy = GetFreqVec(np2,sy); 

    S.Spectral.fx   = fqx;  % store wave vector matrix 
    S.Spectral.fy   = fqy;  % store wave vector matrix 
    
    switch TaperType
        case 'tukey'
            taperFunc=@(n,m) tukeywin(n,0.2)*tukeywin(m,0.2)';
        case 'hann'
            taperFunc=@(n,m) hann(n)*hann(m)';
        case 'hannRad'
            taperFunc=@(n,m) ApplyHannWindow(n,m,res);
        case 'welch' % Welch window
             taperFunc=@(n,m) (1 - (((0:n-1)-((n-1)/2))/((n+1)/2)).^2)'*...
           (1 - (((0:m-1)-((m-1)/2))/((m+1)/2)).^2); 
        case 'kaiser'
             taperFunc=@(n,m) kaiser(n,10)*kaiser(m,10)';
        case 'bartlett'     
            taperFunc=@(n,m) bartlett(n) * bartlett(m)';
        otherwise 
            taperFunc=@(n,m) ones(n,m);          
    end


%%    
printLine
fprintf('\nCompution 2D Power Spectrum in process...\n') 


DispProgress = round(linspace(1,size(S.grid.tiles,2),15)); 
counter = 1; 

for i = 1:size(S.grid.tiles,2)
% for one cycle ~ Elapsed time is 0.046020seconds.

tic
%% Reads data from struct  
   angle= S.grid.tiles(i).rotAngle;
   x= S.grid.tiles(i).x;
   y= S.grid.tiles(i).y;
   z= S.grid.tiles(i).z;
   
%% Rotates tile that the x and y sides match with the axis of a Cartesian
% coordinate system
   [x,y] = rotGlobal2LocalRCS(x,y,[],angle);
   x=x-min(x); % removes offset
   y=y-min(y);  % removes offset
   
%% Conversion from single to double required for gridding
   x=double(x); y=double(y); z=double(z);
   
%% Grid the tile required for fft (~ Elapsed time is 0.015171 seconds)
% The gridding depends on the Surface size. The padding with zeros is done
% in the fft after applying the taper. 
   xx = 0:res:min([max(x(:)) tileSizeX]);
   yy = 0:res:min([max(y(:)) tileSizeY]);

  warning('off') % Warning results form averaging multiple values 

   [XX,YY] = meshgrid(xx,yy);
    Z = griddata(x,y,z,XX,YY,GridMethod); 
  
  warning('on','all') 
% try to remove duplicates befor gridding!
%   Warning: Duplicate data points have been detected and removed - corresponding values have been averaged. 
% > In griddata>useScatteredInterp (line 181)
% In griddata (line 120)
% In Compute2DPowerSpectrum (line 84)
% In Pt_Spatial_Processing (line 5) 
%% taper Surfae to reduce edge effects depend on the individual surface 
% size
   [n,m] = size(Z);  % original Block size in X, Y
     win = taperFunc(n,m);
      Z  = Z.*win;   % apply taper to surface S
      Z  = Z  - mean(Z(:)); % remove mean if not zero mean   
      
%%
    A=res*m*res*n; % Area in m^2 to norm spectrum by reals pixel size. 
    % No matter how many intervalls are added in the frequency domain, by
    % padding with 0 at the edges, to increase resolution in the 
    % frequency domain the Area remains still the same.       
      
%% Compute Power spectrum of surface Z
    W = abs(fftshift(fft2(Z,np2,np2))); % Get Amplitude spectrum and ensures that spectrum is equal size
    CD = A./(m*n)^2.*(W.^2); % area in m^2 times power spectra in m^2
    CD(fqx==0,fqy==0) = 0;     % remove the mean 
    S.Spectral.PowerSpec = CD;  % store amplitude spectrum 
    
 toc   
   if i == DispProgress(counter) % When performance issues are fixed
      counter = counter+1; 
      fprintf('|');  
   end  
   
end
fprintf('\t[done]')

end


function [freq] = GetFreqVec(N,fs)
% Computes the frequency vector for a FFT function, based on:
% [freq] = GetFreqVec(N,fs)
% With: 
% N: Number of Samples
% fs: sample frequency 
%

if mod(N,2)>0
     N_2=(N+1)/2;
else
     N_2=N/2+1;
end

n=1:N;
freq = (n-N_2)/N *fs;


end