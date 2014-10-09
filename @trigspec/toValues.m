function fx = toValues(disc, f, flag)
%TOVALUES   Convert a CHEBFUN to its TRIGSPEC discretization.
%   C = TOVALUES(DISC, F) converts the smooth chebfun F to coefficients C for
%   use by a TRIGSPEC discretization DISC.
%
%   C = TOVALUES(DISC, F, 1) converts the (perhaps piecewise smooth) chebfun F
%   to coefficients C for use by a TRIGSPEC discretization DISC.

% Copyright 2014 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

if ( isnumeric(f) )
    fx = f;
    return
end

dim = disc.dimension;
c = trigcoeffs(f.funs{1}, dim);

if ( nargin < 3 || ~flag )
    S = eye(disc.dimension);
    fx = S*c;
else
    fx = c;
end

end
