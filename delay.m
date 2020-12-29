%___Delay______
%
%________________________________
%
%This script is based on simple delay line filters like the comb filter. It
%provides a delay/echo effect. Adjustable parameters are delay time m0,
%number of repeats R, and fadeout factor F. The output is a mono signal
%with a stretched "tail end" compared to the input, which depends on the
%above parameters.
% 1. a) Reading from sample .wav
[x,Fs]=audioread('INPUT_FILE.wav');
% b) Conversion to Mono
[N,S]=size(x);
if S==2
    x=0.5.*(x(:,1)+x(:,2));
end
% 2. a) Variable declaration
m0=0.1; % delay time in seconds
M0=round(m0*Fs); % delay time in samples
R=1; %Number of repeats
r=1:R; %repeat vector - arranges the [n]s of repeated samples in a column
F=1; %Fadeout factor - determines the how fast the amplitude of repeated 
       %samples decreases with each repeat.
g=F./r; %fade vector -aranges F values in a vector to be applied to the 
        %repeated samples
% b) Extending the length of x to fit the delayed samples
x=[x;zeros(R*M0,1)];
% Memory allocation for y
y=x;
% 3. Main Loop
for n=1:length(x)
    for q=1:R
        if n-M0*r(1,q)>=1%making sure the indices are positive
            y(n,1)=y(n,1)+g(q)*x(n-M0*r(q),1);%adding the delayed samples
        end
    end
end
%Type soundsc(y,Fs) to hear the modified signal.

%Below is an earlier, much more basic delay effect. It only provides a
%single repeat ("Slapback Echo") for given delay time m0 and a g value up 
%to 1. It goes well with Rockabilly.
% for n = (2*M0+1):N
%     y(n,1)=x(n,1)+g*x(n-M0,1);
% end