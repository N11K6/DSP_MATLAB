function [ P ] = interptab( N, Q )
%   Lagrange Interpolation Table Constructor
%
%   This function creates a table (actually a matrix in Matlab terms, since
%   tables in such a script have different properties) which contains the
%   elements required to construct an Nth order Lagrange polynomial.


% Note that in order to properly define the elements of P, Q needs to be 
% equal or lesser than N, otherwise we will be seeking values of n beyond
% its given range. For Q lesser than N, we do get a result, however the
% interpolation will be best performed for N=Q.
if N+1<=Q
    fprintf(1,'\nERROR\nN cannot be lesser than Q\n');
    P=NaN;
else
% This process below allows us to give non-even values to the order N. In
% such a case, instead of having an equal number of elements before and
% after the value being examined, we have one additional "past" element.
    if floor(N/2)==ceil(N/2);
    n=-(N-1)/2:(N-1)/2;
    else
    n=-N/2:N/2-1;
    end
% For memory allocation purposes:
P=ones(N,Q);    
% Defining the range and number of values alpha can take.
q=-(Q/2)/Q:1/Q:((Q-1)/2)/Q;
% Loop constructing the matrix
    for l=1:Q
        for k=1:N
            if k~=l % If condition avoids division by zero
            P(k,l)=P(k,l).*(q(l)-n(k))/(n(l)-n(k));
            end
        end
    end

end
% The output of this function is the NxQ matrix P.
end
