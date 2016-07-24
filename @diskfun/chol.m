function varargout = chol(varargin)
%CHOL    Cholesky factorization of a DISKFUN. 
%
% R = CHOL( F ), if F is a nonnegative definite DISKFUN (in polar coords)
% then this returns an upper triangular quasimatrix so that R'*R is a
% decomposition of F. If F is not nonnegative definite then an error is thrown.
%
% L = CHOL(F, 'lower'), if F is a nonnegative definite DISKFUN then thi
% produces a lower triangular quasimatrix so that L*L' is a decomposition of F.
% If F is not nonnegative definite then an error is thrown. 
% 
% [R, p] = CHOL( F ), with two outputs never throwns an error message. If F i
% nonnegative definite then p is 0 and R is the same as above. If F is 
% symmetric but negative definite or semidefinite then p is a positive 
% integer such that R has p columns and R'*R is a rank p nonnegative definite 
% DISKFUN that approximates F. 
% This is particular useful when F is nonnegative definite, but rounding error
% have perturbed it to be semidefinite. 
%
% [L, p] = CHOL(F, 'lower') same as above but the first argument is lower 
% triangular. 
%
% For more information about the factorization: 
% A. Townsend and L. N. Trefethen, Continuous analogues of matrix
% factorizations, Proc. Royal Soc. A., 2015. 
%
% See also DISKFUN/LU, and DISKFUN/QR. 

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

[varargout{1:nargout}] = chol@separableApprox(varargin{:});

end
