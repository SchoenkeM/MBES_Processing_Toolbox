function immagphase(X)
  figure
  subplot(2,2,[1:2])
  imagesc(X)
  title 'Image'
  axis equal
  axis tight
  
  X= fftshift(fft2(X));
  
  A = abs(X);
  if min(min(A)) == 0
    Y = mat2gray(log(A + 1e-7));
   else
    Y = mat2gray(log(A));
  end
  subplot(2,2,3)
  subimage([-1 1],[-1 1],Y)
  title 'Magnitude'
  subplot(2,2,4)
  Y = mat2gray(angle(X));
  subimage([-1 1],[-1 1],Y)
  title 'Phase'
  
