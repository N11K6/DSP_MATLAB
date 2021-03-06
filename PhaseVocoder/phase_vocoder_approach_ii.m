%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1. Program info
% Program details: Submission for MAFTDSP Project I: Phase Vocoder
% 
% This is the code for a phase vocoder. This basic version follows the
% instructions step by step in making a functional vocoder that runs
% reasonably fast.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2. Preamble, variable declaration
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
N=2048;%window size
HA=N/4;%analysis hop size
Q=0.7;%time-stretch factor
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 3. Synthesis hop & trunctuation to integer
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HS=floor(Q*HA);
Q=HS/HA;%exact amount of stretch/compression
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 4. Hann window
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
w=0.5*(1-cos(2*pi*(0:N-1)/(N)));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 5. Reading the .wav file
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[x,SR]=audioread('INPUT_FILE.wav');
xs=length(x);
NF=ceil(xs/HA);%number of frames necessary to cover entire vector
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Zero padding
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%power of 2 nearest (and higher than) to the length of signal
dx=2^ceil(log2(xs))-xs;%this may well be over N though
x_pad=[x;zeros(dx,1)];%zero padded signal
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 6. X and Y matrices
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
X = zeros(N,NF);
for l=1:NF
        X(:,l)=x_pad((l-1)*HA+1*(1:N),1).*w';
end
Y=X;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 7. DFT Matrix
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
XF=fft(X);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 8. Magnitude and Phase Matrices
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
XFM=abs(XF);
XFP=angle(XF);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 9. Output Synthesis Phase Matrix
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
YFP=zeros(N,NF);
YFP(:,1)=XFP(:,1);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 10. Phase Manipulations
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% a. Phase vector
v=2*pi*HA*(0:N/2)'/N;
v((N/2+2):N,1)=v(2:N/2,1)-v(N/2+1,1);%arranging the rest anti-symmetrically
% b. Phase differences
D=zeros(N,NF);
for l=2:NF
    D(:,l)=XFP(:,l)-XFP(:,l-1)-v(:,1);%c. Phase increment
        DR=real(exp(1i*D(:,l)));%d. Converting to
        DI=imag(exp(1i*D(:,l)));%   values in
        D(:,l)=atan2(DI,DR);%       the range (-pi,pi)
    D(:,l)=Q*(D(:,l)+v(:,1));%e. Phase rescaling
    YFP(:,l)=YFP(:,l-1)+D(:,l);%f. Phase differences to absolute phase
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 11. Polar to Cartesian
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for l=1:NF
        YF(:,l)=real(XFM(:,l).*exp(1i*YFP(:,l)))+1i*imag(XFM(:,l).*exp(1i*YFP(:,l)));
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 12. Resetting Matrix Y
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Y=ifft(YF);
% A way to check the imaginary/real ratio of Y's elements:
fun=@(A,B) imag(A)/real(B);
IR=mean2(bsxfun(fun,Y,Y))% the smaller IR is, the better
% Due to machine error, Y is not zero, but it is small enough so that the
% real part of our end signal is of desirable quality.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 13. Vector y, ready to play processed signal
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
y=zeros(HS*NF+N,1);%have to make y big enough for the first loop below
for l=1:NF
        y((l-1)*HS+1*(1:N),1)=y((l-1)*HS+1*(1:N),1)+Y(:,l).*w';%Overlap adding frames
end
