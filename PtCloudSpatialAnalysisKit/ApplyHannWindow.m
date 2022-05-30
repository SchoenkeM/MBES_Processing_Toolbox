function [win]=ApplyHannWindow(N,M,res)
% based on Quantitative characerization of surface topography using
% spectral analysis, Tevis JAcobs, Till Junge, Lars Pastewka 

   Lx = res*N; % Frame Size /pereodicity
   Ly = res*M; % Frame Size /pereodicity

    x = 0:res:(Lx-res);
    y = 0:res:(Ly-res);
[x,y] = meshgrid(x, y);

    X = x-(Lx/2);
    Y = y-(Ly/2);
     
    Z = X.^2+Y.^2;
    
   
    Lmin = min([Lx,Ly]);
    Kret = (Lmin/2)^2;

  Hann = ((3*pi)/8 - 2/pi)^-0.5 .* (1+cos(((2.*pi.*sqrt(Z))./ min([Lx,Ly]))));
  Hann(Z>=Kret)=0; 
    
  win=Hann;

end