function f = highpassfilter(sze, cutoff, n)
% HIGHPASSFILTER  - Constructs a high-pass butterworth filter.
%
% usage: f = highpassfilter(sze, cutoff, n)
% 
% where: sze    is a two element vector specifying the size of filter 
%               to construct.
%        cutoff is the cutoff frequency of the filter 0 - 0.5
%        n      is the order of the filter, the higher n is the sharper
%               the transition is. (n must be an integer >= 1).
%
% The frequency origin of the returned filter is at the corners.
%
% See also: LOWPASSFILTER, HIGHBOOSTFILTER, BANDPASSFILTER
%

% Peter Kovesi   pk@cs.uwa.edu.au
% Department of Computer Science & Software Engineering
% The University of Western Australia
%
% October 1999

    if cutoff < 0 | cutoff > 0.5
	error('cutoff frequency must be between 0 and 0.5');
    end

    if rem(n,1) ~= 0 | n < 1
	error('n must be an integer >= 1');
    end
    
    f = 1.0 - lowpassfilter(sze, cutoff, n);