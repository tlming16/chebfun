function varargout = subsref(F, ref)
%SUBSREF   CHEBFUN3V subsref.
%   F(X, Y, Z) returns the values of the CHEBFUN3V object F evaluated on the
%   array (X, Y, Z).
%
%   F(k) returns the first component of the chebfun3v object F if k=1, the
%   second if k=2, and the third if k=3.
%
%   F(G) where G is a CHEBFUN3V returns the CHEBFUN3V representing the
%   composition F(G).  If G is a CHEBFUN2V, then F(G) is a CHEBFUN2V.
%
%   F(X, Y, Z) where X, Y, Z are CHEBFUN3 objects is a CHEBFUN3V representing
%   the composition.  If X, Y, Z are CHEBFUN2 objects, F(X, Y, Z) is a
%   CHEBFUN2V.
%
%   F.PROP returns the property PROP of F as defined by GET(F,'PROP').
%   Throws an error.

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

% check for empty CHEBFUN3V object.
if ( isempty(F) )
    varargout = {[]};
    return
end

indx = ref(1).subs;

switch ( ref(1).type )
    case '.'
        if ( numel(ref) == 1 )
            % This is a get call to get a property.
            varargout = {get(F, indx)};
        else
            % Probably F.components{1} or ...
            t2 = ref(2).type;
            if ( strcmp(t2,'.') )
                out = get(F, indx, ref(2).subs{:});
            else
                out = get(F, indx);
                out = out(ref(2).subs{:});
            end
            if ( numel(ref) > 2 )
                varargout = {subsref(out, ref(3:end))};
            else
                varargout = {out};
            end
        end
        
    case '()'
        if ( length(indx) > 1 )
            x = indx{1}; % Where to evaluate?
            y = indx{2};
            z = indx{3};
            % If x,y,z are Chebfun2 or Chebfun3, call compose; else feval.
            if ( isa(x, 'chebfun2') && isa(y, 'chebfun2') && isa(z, 'chebfun2') )
                out = compose([x; y; z], F);
            elseif ( isa(x, 'chebfun3') && isa(y, 'chebfun3') && isa(z, 'chebfun3') )
                out = compose([x; y; z], F);
            else
                out = feval(F, x, y, z);
            end
            varargout = {out};
            
        elseif ( isa(indx{1}, 'chebfun2v') || isa(indx{1}, 'chebfun3v') )
            % Composition F(CHEBFUN2V) or F(CHEBFUN3V):
            out = compose(indx{1}, F);
            varargout = {out};
            
        else
            if ( isa(indx{1}, 'double') )
                if all( indx{1} == 1  )
                    varargout = F.components(1);
                elseif ( all(indx{1} == 2) )
                    varargout = F.components(2);
                elseif ( all(indx{1} == 3) && ~isempty(F.components(3)) )
                    varargout = F.components(3);
                else
                    error('CHEBFUN:CHEBFUN3V:subsref:index', ...
                        'CHEBFUN3V only contains two/three components');
                end
            end
        end
        
    otherwise
        error('CHEBFUN:CHEBFUN3V:subsref:unexpectedType', ...
            ['??? Unexpected index.type of ' indx(1).type]);
        
end

% Recurse down? E.g. for "F(1).core" where F is a CHEBFUN3V object.
if ( numel(ref) > 1 )
    ref(1) = [];
    varargout = { subsref( varargout{ : }, ref ) };
end

end