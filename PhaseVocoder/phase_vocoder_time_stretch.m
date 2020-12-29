%% PROGRAM INFO
% This is a script for a phase vocoder, to be used as a time stretching
% algorithm for audio signals while preserving the original pitch. 

% In addition to the standard algorithm, this script also performs rigid
% phase locking to improve the quality of the stretched audio, through the
% algorithm sugested by J Laroche and M Dolson, in "Improved  Phase  
% Vocoder Time-Scale Modification  of  Audio", 1999.
% Parts of this script have been based on code written by the
% user ederwander and shared on the stackexchange forums.
% (https://dsp.stackexchange.com/questions/40101/audio-time-stretching-without-pitch-shifting)

% The full script requires the Signal Processing Toolbox for MATLAB.
% In order to run the script without the Toolbox, use the manually defined
% window function and comment out the phase locking section. This will
% perform the time stretching using the standard phase vocoder algorithm.

clear; close; clc; % CLEAR WORKSPACE
%% LOAD AUDIO SAMPLE_______________________________________________________
[x,Fs]=audioread('INPUT_FILE.wav'); % Change the string to the name of the file
%% TIME STRETCH FACTOR ____________________________________________________
Q=2; % >1 for time stretching, <1 for shrinking
%% MAIN PARAMETERS_________________________________________________________
N=2048; % Window length in samples
window=hann(N); % Hann window, function in Signal Processing Toolbox
% w=0.5*(1-cos(2*pi*(0:N-1)/(N))); % manual Hann window function
HS=N/4; % Synthesis hop size
HA=floor(HS/Q); % Analysis hop size
%% INITIALISATION OF VARIABLES ETC_________________________________________
l_x=length(x); % length of input signal
N_frames = floor((l_x-N)/HA); % No. of frames used
y=zeros((N_frames-1)*HS+N,1); % Initialisation of output vector
two_pi=2*pi; % 2pi for convenience
v = (0:N-1)*two_pi*HA/N; % Phase vector
first_frame=1; % Boolean to differentiate the first frame
ind_x=1; % index for input
ind_y=1; % index for output
%% MAIN LOOP_______________________________________________________________
for ii=1:N_frames
    if first_frame==1 % Phase for the first frame is kept
        x_frame=x(1:N).*window;
        X=fft(fftshift(x_frame),N);
        Mag=abs(X);
        Pha=angle(X);
        PhaSy=Pha;
        first_frame=0;
        Z = 1;
    else % Subsequent frames require phase modification
        x_frame = x(ind_x:ind_x+N-1).*window; % current frame
        X=fft(fftshift(x_frame),N);  % FFT
        Mag=abs(X); % magnitude
        Pha=angle(X); % phases
        Pha_difference = Pha-Pha_previous-v.'; % unwrapped phase
        Pha_circle = Pha_difference-two_pi*round(Pha_difference/two_pi); % conversion within (-pi,pi)
        freq = (v+Pha_circle')/HA; % phase rescaling
        PhaSy = Phasy_previous+HS*freq'; % Phase synthesis
        
        % PHASE LOCKING ____________________________________________________
        % This sub-section performs rigid phase locking to the phase of bins
        % where peaks are located as per [Laroche & Dolson, 1999] which
        % improves upon the quality of the stretched audio.
        % The findpeaks function requires the Signal Processing Toolbox.
        % The implementation of the rigid phase locking can be ingored by
        % commenting this section.
        [pks,locs] = findpeaks(Mag); % Locate peaks
        for n=1:N % loop through all channels
            [val, ind]=min(abs(n-locs)); % Identify nearest peak channel
            PhaSy(n) = PhaSy(locs(ind))+Pha(n)-Pha(locs(ind)); % Phase Synth
        end
        % end of phase locking loop________________________________________
        
        theta = PhaSy-Pha;
        Z = exp(1i*theta); % polar to cartesian
    end
    Y = Z.*X; % Resynthesis
    y_frame = fftshift(real(ifft(Y,N))).*window; % Inverse FFT
    y(ind_y:ind_y+N-1) = y(ind_y:ind_y+N-1)+y_frame; % Overlapp and add
    
    % update variables for next iteration:_________________________________
    Pha_previous = Pha;
    Phasy_previous = PhaSy;
    ind_x = ind_x+HA;
    ind_y = ind_y+HS;
end
%% Play stretched audio____________________________________________________
% soundsc(y,Fs); 
% Uncomment to play audio when script is executed, otherwise type
% "soundsc(y,Fs)" in the Command Window to listen to stretched audio.
