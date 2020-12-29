%___Flanger (Mono)______
%
%________________________________
%
%This script performs the flanging operation on an input signal x.
%Parameters are flange depth M0, flange frequency f0, flange strength g,
%and also polynomial order D and number of reference points Q, to be
%used for the interpolation process.
% 1. a) Reading from sample .wav
[x,Fs]=audioread('INPUT_FILE.wav');
% b) conversion to mono signal
[N,S]=size(x);
if S==2
    x=0.5.*(x(:,1)+x(:,2));
end
% 2. Declaration of variables
f0=0.7; %flanging frequency
m0=0.003; %flange depth -since we are dealing with a time delay related
         %parameter, m0 corresponds to delay in seconds. Typical Flanger
         %values are 1ms to 5ms.
M0=round(m0*Fs); %flange depth in samples
g=1; %flange strength
Q=10; %number of points in each interpolation interval
D=10; %order of the interpolating polynomial
% Defining variable delay M[n]
n=1:N;
M=M0*(1+sin(2*pi*f0*n/Fs))'; %ordered as a column for convenience
% Defining alpha values
alpha=(-0.5):1/Q:(0.5-(1/Q));

% 3. Flanging process
% a) Memory allocation
y=x;
% Calling the interptab function to create the necessary table.
Pmatrix=interptab(D,Q);
% Memory allocation for the polynomials
P=zeros(Q,1);
% Start of main loop
for n = 2*M0+1:N %starting from 2*M0+1 avoids negative indices
                 %M(n) ranges from zero t0 2*M0. An alternative would have
                 %been the use of if conditions, however after testing
                 %those, they proved to take up too many resources and time
                 %for no audible difference.
    
    % b) Defining the intervals for the interpolation of each value, as
    %    demonstrated in the video tutorial.
    Mf=floor(n-M(n));
    Mc=ceil(n-M(n));
    alphaM=Mc-M(n)+0.5;
    [val,ind]=min(abs(alpha(1:Q)-alphaM));
    %ind gives the element of alpha closest to alphaM
    
    % c) Constructing the polynomials P(alpha)
    for l=1:Q
        for k=1:floor(D/2) %For Values above alphaM
        P(l,1)=x(Mc+k-1)*Pmatrix(k,l);
        end
        for k=1:ceil(D/2) %For Values below alphaM
        P(l,1)=x(Mf-k+1)*Pmatrix(k,l);
        end
    end
    %Note that the way the above loops are defined, for odd D, we get one
    %extra reference point below alphaM, to make a total of D points.
% d) Finally adding the interpolated value to the signal.
y(n)=(x(n)+g*P(ind));%This part, if normalised by 1/g, can handle values
                     % of g>1 and provide a more intense effect without
                     % boosting up the volume.
end
%type soundsc(y,Fs) to hear the modified signal


%This code below provides a crude flanger, with no interpolation, for
%comparison purposes.
%  for n = (2*M0+1):N
%      y(n,1)=x(n,1)+g*x(n-floor(M(n)),1);
%  end