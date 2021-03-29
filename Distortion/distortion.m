function y = distortion(x,G,Qp,Qn,Dp,Dn,r1,r2)

%This function applies distortion to a mono audio signal. The algorithm
%used separates the positive and negative parts of the input and applies
%vacuum tube distortion under different parameters for part. For equal
%settings in both parts, the result should be the same as the simple vacuum
%tube distortion function.

%Error Check:______________________________________________________________
if isvector(x)==0
    error('Please use a mono signal.')
end
if G<1
    error('Pre-gain must not be a negative number')
end
if abs(Qp)>G
    disp('Warning: Q has been selected greater than G')
end
if abs(Qn)>G
    disp('Warning: Q has been selected greater than G')
end
if Dp<0
    error('Distortion amount must not be a negative number.')
end
if Dn<0
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
%__________________________________________________________________________
%Apply pre-gain
x=G.*(x/max(abs(x)));
%OVERSAMPLING______________________________________________________________
x_over=interp(x,8);
%Positive part of signal___________________________________________________
x_p=0.5*(sign(x_over).*x_over+x_over);
%For Q=0
if Qp==0
     y_p=x_p./(1-exp(-Dp.*x_p))-1/Dp;
     disp('Warning: Qp has been selected as zero.')
else
%Applying Distortion:
    PLUS=Qp/(1-exp(Dp*Qp));
    EQUALQX=1/Dp+Qp/(1-exp(Dp*Qp));
    logiQ=logical(rem(x_p,Qp));
    x_Q=x_p-Qp;
    y_0=-(logiQ-1)*EQUALQX;
    y_1=(logiQ.*x_Q)./(1-exp(-Dp.*(logiQ.*x_p-Qp)))+PLUS;
    y_p = y_0+y_1;
end
%Negative part of signal___________________________________________________
x_n=x_over-x_p;
if Qn==0
     y_n=x_n./(1-exp(-Dn.*x_n))-1/Dn;
     disp('Warning: Qn has been selected as zero.')
else
%Applying Distortion
    PLUS=Qn/(1-exp(Dn*Qn));
    EQUALQX=1/Dn+Qn/(1-exp(Dn*Qn));
    logiQ=logical(rem(x_n,Qn));
    x_Q=x_n-Qn;
    y_0=-(logiQ-1)*EQUALQX;
    y_1=(logiQ.*x_Q)./(1-exp(-Dn.*(logiQ.*x_n-Qn)))+PLUS;
    y_n = y_0+y_1;
end
y_over=y_n+y_p;
%DOWNSAMPLING______________________________________________________________
y=decimate(y_over,8);
%Applying filters
B=[1;-2;1];
A=[1;-2*r1;r1^2];
y=filter(B,A,y);
b=1-r2;
a=[1;-r2];
y=filter(b,a,y);
%Normalization
y=y/max(abs(y));
end
