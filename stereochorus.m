%___Stereo Chorus______
%
%________________________________
%
%This script performs provides a stereo chorus effect, based on the stereo
%flanging process. It creates two monophonic flanging signals with a small
%frequency difference and sends each to a channel of the main final signal.
%Parameters are flange depth M0, flange frequencies f1 and f2, flange
%strength g,
%and also polynomial order D and number of reference points Q, to be
%used for the interpolation process.
%
%It is perhaps useful to keep in mind that, in order to make the chorus
%effect discernible from a flanger, longer delay times are needed.
% 1. a) Reading from sample .wav
[x,FS]=audioread('INPUT_FILE.wav');
% b) Conversion to Mono
[N,S]=size(x);
if S==2
    x=0.5.*(x(:,1)+x(:,2));
end
% 2. Variable declaration
f1=0.2; %flanging frequency 1
f2=0.4; %flanging frequency 2
m0=0.01; %flange depth (delay time in seconds)
M0=round(m0*FS); %flange depth (delay time in samples)
g=1; %flange strength
Q=10; %no. of points in interp. interval
D=10; %interp. polynomial order
%Defining variable delays M1 and M2
n=1:N;
M1=M0*(1+sin(2*pi*f1*n/FS))';
M2=M0*(1+sin(2*pi*f2*n/FS))';
%Defining values for alpha
alpha=(-0.5):1/Q:(0.5-(1/Q));
% 3. Filtering Process
% a) Memory allocation
y=zeros(N,2);
y(:,1)=x;
y(:,2)=x;
Pmatrix=interptab(D,Q);
P=zeros(Q,2);
% Main Loop
for n = (2*M0+1):N
    % b) defining intervals for each M
    Mf1=floor(n-M1(n));
    Mc1=ceil(n-M1(n));
    alphaM1=Mc1-M1(n)+0.5;
    [val1,ind1]=min(abs(alpha(1:Q)-alphaM1));
    Mf2=floor(n-M2(n));
    Mc2=ceil(n-M2(n));
    alphaM2=Mc2-M2(n)+0.5;
    [val2,ind2]=min(abs(alpha(1:Q)-alphaM2));
    % ind1, ind2 provide alpha closest to each alphaM
    % c) Construction of Polynomials, arranged in Qx2 matrix
for l=1:Q
    for k=1:floor(D/2)
        P(l,1)=x(Mc1+k-1)*Pmatrix(k,l);
        P(l,2)=x(Mc2+k-1)*Pmatrix(k,l);
    end
    for k=1:ceil(D/2)
        P(l,1)=x(Mf1-k+1)*Pmatrix(k,l);
        P(l,2)=x(Mf2-k+1)*Pmatrix(k,l);
    end
end
%Adding the interpolated values to the signal
y(n,1)=x(n)+g*P(ind1,1);
y(n,2)=x(n)+g*P(ind2,2);
end
%Type soundsc(y,Fs) to hear resulting signal.

%Using the same exact process, one can layer many "flanged" signals of
%different frequency and add them up to a stereo or mono signal, in order
%to create a more intricate chorus effect.