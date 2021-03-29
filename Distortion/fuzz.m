function y = fuzz (x,G)

% This function implements fuzz distortion on a given mono signal. Input
% parameters are the signal vector x and the amount of distortion G. In
% addition to the output, the function produces plots for the dry,
% distorted, and distorted without oversampling signals, as well as their
% respective DFTs.

%Error Check:
if isvector(x)==0
    error('Please use a mono signal.')
end
if G<0
    error('Distortion amount must not be a negative number.')
end

%Setting initial amount of Gain
x_g=G.*(x/max(abs(x)));
%OVERSAMPLING______________________________________________________________
x_over=interp(x_g,8);
%Sign vector
x_01=sign(x_over);
%Applying the fuzz distortion
y_over=x_01-x_01.*exp(-x_01.*x_over);
%DOWNSAMPLING______________________________________________________________
y=decimate(y_over,8);

%Same Process as above without oversampling, for use in plots_____________
x01=sign(x_g);
z=x01-x01.*exp(-x01.*x_g);%________________________________________________

%Normalization
y=y/max(abs(y));
z=z/max(abs(z));

%Plots_____________________________________________________________________
subplot(3,2,1)
plot(x,'k')
title('Input Signal')
xlabel('Time in samples')
ylabel('Amplitude')
subplot(3,2,3)
plot(z,'r')
title('Distorted without oversampling')
xlabel('Time in samples')
ylabel('Amplitude')
subplot(3,2,5)
plot(y,'b')
title('Distorted with oversampling')
xlabel('Time in samples')
ylabel('Amplitude')
subplot(3,2,2)
bar((fftshift(x)),'k')
title('DFT of Input')
axis tight
subplot(3,2,4)
bar((fftshift(z)),'r')
title('DFT of Distorted*')
axis tight
subplot(3,2,6)
bar((fftshift(y)),'b')
title('DFT of Distorted')
axis tight
%LABEL AXES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
end
