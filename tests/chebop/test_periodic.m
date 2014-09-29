function pass = test_periodic(pref)
% Test 'periodic' syntax for linear ODEs.

if ( nargin == 0 )
    pref = cheboppref();
end
tol = 1e-8;

%% A simple ODE:

% Chebop:
N = chebop(@(u) diff(u, 2) - u);

% Periodic RHS:
rhs = chebfun(@(x) sin(pi*x));

% Apply periodic BCs manually:
N.bc = @(u) [u(-1) - u(1) ; feval(diff(u),-1) - feval(diff(u), 1)];
u = mldivide(N, rhs, pref);

% Apply via 'periodic':
N.bc = 'periodic';
v = mldivide(N, rhs, pref);

% Compare results:
err(1) = norm(u - v);

%% A periodic piecewise system:

d = [-pi, 0, pi];
A = chebop(d);
A.op = @(x, u, v) [u-diff(v) ; diff(u,2)+v];
x = chebfun('x',d);
f = [chebfun(0, d) ; cos(x)];
A.bc = 'periodic';
uv = mldivide(A, f, pref);

trueSoln = [cos(x+3*pi/4)/sqrt(2) ; cos(x+pi/4)/sqrt(2)];
err(2) = norm(uv - trueSoln);

%% Eigenvalue problem:

d = [-pi, 0, pi];
A = chebop(d);
A.op = @(x, u, v) [u-diff(v) ; diff(u,2)+v];
A.bc = 'periodic';
B = chebop(d);
B.op = @(x, u, v) [v + u ; diff(v)];

[V, D] = eigs(A, B, 5, 0, pref);
e = diag(D);

% Sort the eigenvalues to ensure things will work on all machines. Eigs() does
% not appear to return the eigenvalues in a consistent way for different
% machines. We expect five pair of eigenvalues to appear, check whether they are
% all there
% `sort(x)` sorts complex values by abs() and then by angle(). In order have
% consistent sorting, we move all the eigenvalues up into the first quadrant
% before sorting them.
[ignored, idx] = sort(real(e));
e = e(idx);

e12 = e(1:2);
e35 = e(3:5);
[ignored, idx] = sort(imag(e12));
e12 = e12(idx);
[ignored, idx] = sort(imag(e35));
e35 = e35(idx);

e = [e12; e35];

err(3) = norm(real(e) - [0 0 1 1 1].', inf) + ...
    norm(imag(e) - [-1 1 -1 0 1].', inf);
err(4) = norm(V{1}(pi) - V{1}(pi), inf) + norm(V{2}(pi) - V{2}(pi), inf);


%% Test the FOURCOLLOC class. FIRST ORDER AND CONSTANT COEFFICIENTS: 
%  u' + u = cos(x), on [0 2*pi].

% Set domain, operator L, and rhs f.
dom = [0 2*pi];
L = chebop(@(u) diff(u) + u, dom);
f = chebfun(@(x) cos(x), dom);

% Solve with FOURIER technology.
L.bc = 'periodic';
u = L \ f;

% Compare with exact solution.
exact = chebfun(@(x) 1/2*cos(x) + 1/2*sin(x), dom, 'periodic');
err(5) = norm(u - exact, inf);

%% Test the FOURCOLLOC class. FIRST ORDER AND VARIABLES COEFFICIENTS: 
%  u' + (1+cos(x))u = cos(2x), on [-2*pi 2*pi].

% Set domain, c, and rhs f.
dom = [-2*pi 2*pi];
f = chebfun(@(x) cos(2*x), dom);

% Set chebop L. We construct the variable coefficient inside the chebop.
L = chebop(@(x, u) diff(u) + (1 + cos(x)).*u, dom); 
L.bc = 'periodic';

% Solve with FOURIER technology.
u = L \ f;

err(6) = norm(L*u - f);
err(7) = abs(u(dom(1)) - u(dom(2)));

%% Test the FOURCOLLOC class. SECOND ORDER AND CONSTANT COEFFICIENTS: 
%  u'' + 10u' + 5u = cos(x), on [-2*pi 2*pi].

% Set domain, constants coefficients a and b, operator L,
% and rhs f.
dom = [-2*pi 2*pi];
a = 10;
b = 5;
L = chebop(@(u) diff(u, 2) + a*diff(u) + b*u, dom); 
L.bc = 'periodic';
f = chebfun(@(x) cos(x), dom);

% Solve with FOURIER technology.
u = L \ f;

% Compare with exact solution.
exact = chebfun(@(x) 1/29*cos(x) + 5/58*sin(x), dom, 'periodic');
err(8) = norm(u - exact, inf);

%% Test the FOURCOLLOC class. SECOND ORDER AND VARIABLE COEFFICIENTS: 
%  (2+cos(4x))u'' + sin(cos(2x))u' + exp(cos(x))u = cos(x), on [-pi pi].

% Set domain, variable coefficients a, b and c, and rhs f.
dom = [-pi pi];
a = chebfun(@(x) 2 + cos(4*x), dom);
b = chebfun(@(x) sin(cos(2*x)), dom, 'periodic');
c = chebfun(@(x) exp(cos(x)), dom);
f = chebfun(@(x) cos(x), dom);

% Set chebop. The variale coefficients have been constructed outside the
% chebop, some with 'periodic', some without it.
L = chebop(@(u) a.*diff(u, 2) + b.*diff(u) + c.*u, dom);
L.bc = 'periodic';

% Solve with FOURIER technology.
u = L \ f;

err(9) = norm(L*u - f);
err(10) = abs(u(dom(1)) - u(dom(2)));
err(11) = abs(feval(diff(u), dom(1)) - feval(diff(u), dom(2)));

%% Test the FOURCOLLOC class. THIRD ORDER AND VARIABLE COEFFICIENTS: 
%  (2+cos(x))u''' + sin(cos(2x))u'' + exp(cos(x))u' + sin(x)u = cos(x),
%  on [-pi pi].

% Set domain, variable coefficients a, b, c and d, and rhs f.
dom = [-pi pi];
a = chebfun(@(x) 2 + cos(x), dom);
b = chebfun(@(x) sin(cos(2*x)), dom);
c = chebfun(@(x) exp(cos(x)), dom);
d = chebfun(@(x) sin(x), dom);
f = chebfun(@(x) cos(x), dom);

% Set chebop.
L = chebop(@(u) a.*diff(u, 3) + b.*diff(u, 2) + c.*diff(u) + d.*u, dom);
L.bc = 'periodic';

% Solve with FOURIER technology.
u = L \ f;

err(12) = norm(L*u - f);
err(13) = abs(u(dom(1)) - u(dom(2)));
err(14) = abs(feval(diff(u), dom(1)) - feval(diff(u), dom(2)));
err(15) = abs(feval(diff(u, 2), dom(1)) - feval(diff(u, 2), dom(2)));

%% Test the FOURCOLLOC class. FOURTH ORDER AND VARIABLE COEFFICIENTS: 
%  (2+cos(x))u'''' + sin(cos(2x))u''' + exp(cos(x))u'' + ... 
%  sin(x)u' + sin(2*x)u = cos(10*x), on [-pi pi].

% Set domain, variable coefficients aa, bb, cc, dd and ee, and rhs f.
dom = [-pi pi];
a = chebfun(@(x) 2 + cos(x), dom);
b = chebfun(@(x) sin(cos(2*x)), dom);
c = chebfun(@(x) exp(cos(x)), dom);
d = chebfun(@(x) sin(x), dom);
e = chebfun(@(x) sin(2*x), dom);
f = chebfun(@(x) cos(10*x), dom);

% Set chebop.
L = chebop(@(u) a.*diff(u, 4) + b.*diff(u, 3) + c.*diff(u, 2) + ...
    d.*diff(u) + e.*u, dom);
L.bc = 'periodic';

% Solve with FOURIER technology.
u = L \ f;

err(16) = norm(L*u - f);
err(17) = abs(u(dom(1)) - u(dom(2)));
err(18) = abs(feval(diff(u), dom(1)) - feval(diff(u), dom(2)));
err(19) = abs(feval(diff(u, 2), dom(1)) - feval(diff(u, 2), dom(2)));
err(20) = abs(feval(diff(u, 3), dom(1)) - feval(diff(u, 3), dom(2)));

%%
pass = err < tol;

end
