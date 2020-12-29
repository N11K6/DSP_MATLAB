%___Stereo Flanger______
%
%________________________________
%
%This script performs the flanging operation on an input signal x, and
%outputs a stereo signal y, consisting of two flanging coefficients with
%phase difference pi/2.
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
f0=0.4; %flange freq.
m0=0.003; %flange depth (delay time in seconds)
M0=round(m0*Fs); %flange depth in samples
Q=10; %no. of points in interp. interval
D=10; %interp. polynomial order
g=1; %flange strength
%Defining variable delays M1 and M2
n=1:N;
M1=M0*(1+sin(2*pi*f0*n/Fs))';
M2=M0*(1+cos(2*pi*f0*n/Fs))';
%Defining values for alpha
alpha=(-0.5):1/Q:(0.5-(1/Q));

% 3. Filtering process
% a) Memory allocation
y=zeros(N,2);
y1=x;
y2=x;
% Calling interptab function to create interpolation table
Pmatrix=interptab(D,Q);
P=zeros(Q,2);
% Main loop
for n = (2*M0+1):N %starting late to avoid negative indices
    % b) Defining intervals for each M
    Mf1=floor(n-M1(n));
    Mc1=ceil(n-M1(n));
    alphaM1=Mc1-M1(n)+0.5;
    [val1,ind1]=min(abs(alpha(1:Q)-alphaM1));
    Mf2=floor(n-M2(n));
    Mc2=ceil(n-M2(n));
    alphaM2=Mc2-M2(n)+0.5;
    [val2,ind2]=min(abs(alpha(1:Q)-alphaM2));
    %ind1, ind2 provide the alpha closest to the respective alphaM

    % c) Construction of Polynomials for each case, stored in a two column
    %matrix.
for l=1:Q
    for k=1:floor(D/2) %values above alphaM
        P(l,1)=x(Mc1+k-1)*Pmatrix(k,l);
        P(l,2)=x(Mc2+k-1)*Pmatrix(k,l);
        
    end
    for k=1:ceil(D/2) %values below alphaM
        if Mf2 >= k %The cos-terms appear to give negative index values for
                    %early samples. To avoid starting the loop too late, I
                    %have inserted this if condition.
        P(l,1)=x(Mf1-k+1)*Pmatrix(k,l);
        P(l,2)=x(Mf2-k+1)*Pmatrix(k,l);
        end
    end
end
% d) Adding the interpolated values to the signal coefficients, and
% composing the stereo signal y.
y1(n)=(x(n)+g*P(ind1,1));%If divided by g, we can have deeper effect
y2(n)=(x(n)+g*P(ind2,2));%for g>1, at normal volume
y(n,1)=y1(n);
y(n,2)=y2(n);
end
%type soundsc(y,Fs) to listen to the result

% This is the non-interpolated version for comparison
%  for n = (2*M0+1):N
%      y1(n,1)=x(n,1)+g*x(n-floor(M1(n)),1);
%      y2(n,1)=x(n,1)+g*x(n-floor(M2(n)),1);
%      y(n,1)=y1(n);
%      y(n,2)=y2(n);
%  end

