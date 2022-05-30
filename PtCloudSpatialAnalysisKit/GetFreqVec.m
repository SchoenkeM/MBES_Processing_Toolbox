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