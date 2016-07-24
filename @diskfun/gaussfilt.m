function g = gaussfilt(f, sig)
%GAUSSFILT   Gaussian filtering on the disk.
%   G = GAUSSFILT(F) applies a low-pass filter to F. This is based on 
%   Gaussian filtering.  
% 
%   G = GAUSSFILT(F, SIG) applies a low-pass filter to F with parameter SIG. 
%   This smooths F on the length scale of SIG, where SIG is measured in
%   radians at the equator on the unit disk. The default is SIG=pi/180,
%   which corresponds to filtering at a spatial scale of 1 degree.
%   
%   The filter is equivalent to running the diffusion equation on the unit 
%   disk to time t=0.5*SIG^2 with a diffusion coefficent set to 1 and
%   the initial condition being F. 

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

if ( nargin < 2 ) 
    sig = pi/180; 
end
dt = 0.5*sig^2;

% Find the length of f.
[n, m] = length(f); 

% Smoothing consists of solving the heat equation on the disk, which is
% equivalent to applying a low-pass Gaussian filter.  To discretize the
% equation we use backward Euler:
% u^{n+1} = u^{n} + dt*L*u^{n+1}.
% which results in a Helmholtz equation with "wave-number" K = i*sqrt(1/dt)
%            L*u^{n+1) + K*u^{n+1} = -1/dt*u^{n}
% We only do one step of backward Euler to smooth the solution, with 
% u^{0} = f.

% Helmholtz parameter for the heat equation.
K = sqrt(1/dt)*1i;

% Filter f.
g = diskfun.helmholtz(-1/dt*f, K, m, n);

end 
