function y = vacuumtube(x,G,Q,D,r1,r2)

% This function applies distortion to a given audio signal by modelling the
% effects from a vacuum tube. Input parameters are the signal vector x,
% pre-gain G, "work point" Q, amount of distortion D, and pole positions r1
% and r2 for the two filters used.


%Error Check:
if isvector(x)==0
    error('Please use a mono signal.')
end
if G<1
    error('Pre-gain must not be a negative number')
end
if abs(Q)>G
    disp('Warning: Q has been selected greater than G')
end
if D<0
    error('Distortion amount must not be a negative number.')
end
if r1>1
    error('Pole Positions must be within [0,1]')
elseif r1<0
    error('Pole Positions must be within [0,1]')
end
if r2>1
    error('Pole Positions must be within [0,1]')
elseif r2<0
    error('Pole Positions must be within [0,1]')
end

%Applying pre-gain
x=G.*(x/max(abs(x)));
%OVERSAMPLING______________________________________________________________
x_over=interp(x,8);
%For Q=0
if Q==0
     y_over=(x_over./(1-exp(-D.*x_over)))-1/D;
     disp('Warning: Q has been selected as zero.')
     %DOWNSAMPLING_________________________________________________________
     y=downsample(y_over,8);
else
%Applying distortion:
    %Constant values:
    PLUS=Q/(1-exp(D*Q));
    EQUALQX=1/D+Q/(1-exp(D*Q));
    %Logical indexing:
    logiQ=logical(rem(x_over,Q));
    x_Q=x_over-Q;
    %Case of Q=x
    y_0=-(logiQ-1)*EQUALQX;
    %Rest of the signal
    y_1=(logiQ.*x_Q)./(1-exp(-D.*(logiQ.*x_over-Q)))+PLUS;
    %Total signal
    y_over = y_0+y_1;
%DOWNSAMPLING__________________________________________________________
    y=decimate(y_over,8);
%Applying filters
    B=[1;-2;1];
    A=[1;-2*r1;r1^2];
    y=filter(B,A,y);
    b=1-r2;
    a=[1;-r2];
    y=filter(b,a,y);
end
%Normalization
y=y/max(abs(y));
end
