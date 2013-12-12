function f = mtimes(f, c)
%*   Multiplication of DELTAFUN objects.
%   F*C or C*F multiplies a DELTAFUN F by a scalar or matrix C.
% 
%   [TODO]: Does the following make senes:
%   If F is an array-valued SINGFUN and C is a matrix of appropriate dimension,
%   then the natural matrix multiplication is performed.
%
% See also TIMES.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

if ( isempty(f) || isempty(c) )     % DELTAFUN * [] = []
    f = []; 
    return
    
elseif ( ~isa(f, 'DELTAFUN') )       % First input is not a DELTAFUN
    % DOUBLE*SINGFUN requires that the double is scalar.
    if ( numel(f) > 1 )
        error('CHEBFUN:DELTAFUN:mtimes:size', ...
              'Inner matrix dimensions must agree.');
    end
    
    % C must be a DELTAFUN and F a scalar double. Call MTIMES again.
    f = mtimes(c, f);
    return
    
elseif ( isa(c, 'double') )         % DELTAFUN * double  
    % Multiply c with the smooth part:
    f.smoothPart = f.smoothPart * c;    
    
elseif ( isa(c, 'singfun') )        % DELTAFUN * DELTAFUN  
    error('CHEBFUN:SINGFUN:mtimes:singfunMtimesSingfun', ...
          'Use .* to multiply SINGFUN objects.');
    
else                                % DELTAFUN * ???
    error('CHEBFUN:SINGFUN:mtimes:singfunMtimesUnknown', ...
          'mtimes does not know how to multiply a SINGFUN and a %s.', class(c));
end

end
