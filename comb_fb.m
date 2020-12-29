%___Feedback Comb Filter______
%
%________________________________
%
% This script reads from a .wav file, converts it to a mono signal, and
% produces a modified signal according to the feedback comb filter
% process. Magnitide spectra of both input and output are displayed in
% graphs.
%
% 1.a) Reading from a sample .wav
[x,Fs]=audioread('INPUT_FILE.wav');
% b) Conversion of stereo signal to mono
[N,S]=size(x);
if S==2
    x=0.5.*(x(:,1)+x(:,2));
end

% 2. Variable declaration
y=x; % memory allocation
M=1070; % delay in number of samples
g=0.9; % dampening factor, recommended values less than 1

% 3. Main filtering process
for n = (M+1):N
    y(n,1)=y(n,1)-g*x(n-M,1);
end
% 4. DFTS of input(mono) and output signals
X=fft(x);
Y=fft(y);

% 5. Graphs
% a) Stem plot of the magnitude spectrum of X, up to Fs/2 (Nyquist freq.)
subplot(2,2,1)
stem(abs(X), '.', 'r')
axis([0 0.5*Fs 0 max(abs(X))]);
ylabel('Input signal Magnitude');
xlabel('Frequency (Hz)');
% b) Stem plot of the magnitude spectrum of Y, up to Fs/2 (Nyquist freq.)
subplot(2,2,2)
stem(abs(Y), '.')
axis([0 0.5*Fs 0 max(abs(Y))]);
ylabel('Output signal Magnitude');
xlabel('Frequency (Hz)');
% c) Stem plot of the magnitude spectrum of X, up to 2000 Hz
subplot(2,2,3)
stem(abs(X), '.', 'r')
axis([0 2000 0 max(abs(X))]);
ylabel('Input signal Magnitude');
xlabel('Frequency (Hz)');
% c) Stem plot of the magnitude spectrum of Y, up to 2000 Hz
subplot(2,2,4)
stem(abs(Y), '.')
axis([0 2000 0 max(abs(Y))]);
ylabel('Output signal Magnitude');
xlabel('Frequency (Hz)');

suptitle('Feedback Comb Filter Magnitude Spectra')
