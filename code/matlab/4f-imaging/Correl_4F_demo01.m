% -----------------------------------------------------------------------%
% 4F Correlator Matlab Simulation
% -----------------------------------------------------------------------%

clear;
close all;
clc;

%% Create pixel array
len = 512; % Length of pixel array (number of pixels)
cen = len/2 + 1; % Center position of pixel array (pixel coordinates)
dx = 5.0e-6;    % Pixel spacing in meters (m)  
df = 1/(len*dx);   % Spatial frequency domain sampling interval in 1/m (cycles/meter)
%% Create input object
object = imread('ImA.jpg'); % Read image file ImA.jpg as input object
bin_object = rgb2gray(object); % Convert input object to grayscale image
xaxis = ((-len/2):(len/2-1))*dx; % Define x-axis coordinates of image (in meters)
yaxis = -xaxis; % Define y-axis coordinates of image (in meters)

%% Create filters
fxaxis = ((-len/2):(len/2-1))*df; % x-axis coordinates in spatial frequency domain (in 1/m)
fyaxis = -fxaxis; % y-axis coordinates in spatial frequency domain (in 1/m)
[FX,FY] = meshgrid(fxaxis,fyaxis);  % Generate 2D grid representing fx and fy positions for each point
freq_rad = sqrt(FX.^2 + FY.^2); % Calculate frequency radius for each point
maxfreq = (len/2-1)*df; % Maximum frequency value

cutoff_freq1 = 0.1*maxfreq; % First cutoff frequency (10% of maximum frequency)
filter1 = double(freq_rad <= cutoff_freq1); % Create pinhole filter (1 for regions with frequency radius less than cutoff frequency, 0 otherwise)

cutoff_freq2 = 0.3*maxfreq; % Second cutoff frequency (12% of maximum frequency)
filter2 = double(freq_rad >= cutoff_freq2); % Create high-frequency filter (1 for regions with frequency radius greater than cutoff frequency, 0 otherwise)

cutoff_freq3 = 0.4*maxfreq; % Third cutoff frequency (20% of maximum frequency)
filter3 = double(freq_rad <= cutoff_freq3); % Create low-frequency filter (1 for regions with frequency radius less than cutoff frequency, 0 otherwise)

filter4 = filter2.*filter3; % Create 3rd Fresnel zone filter (combining high and low frequency filters)

%% Perform Fourier transform on input object
ftobj = fftshift(fft2(fftshift(object(:,:,3)))); % Perform Fourier transform on blue channel of input object and center it

%% Implement filters
ftimg1 = ftobj.*filter1; % Apply pinhole filter to Fourier transform result of input object
ftimg2 = ftobj.*filter2; % Apply high-frequency filter to Fourier transform result of input object
ftimg4 = ftobj.*filter4; % Apply 3rd Fresnel zone filter to Fourier transform result of input object

%% Calculate inverse Fourier transform after filtering
img1 = abs(fftshift(ifft2(fftshift(ftimg1)))); % Calculate inverse Fourier transform after pinhole filtering and take absolute value
img2 = abs(fftshift(ifft2(fftshift(ftimg2)))); % Calculate inverse Fourier transform after pinhole filtering and take absolute value
img4 = abs(fftshift(ifft2(fftshift(ftimg4)))); % Calculate inverse Fourier transform after 3rd Fresnel zone filtering and take absolute value

%% Plot results for pinhole and 3rd Fresnel zone
figure('NumberTitle', 'off', 'Name', 'Pinhole and 3rd Fresnel zone'); % Create new figure window
set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]); % Set figure window size
colormap('parula'); % Set color map

subplot(3,4,1); % Create subplot
imagesc(fxaxis,fyaxis,filter1);axis('image'); % Display pinhole filter
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
title('Pinhole'); % Set title

subplot(3,4,2); % Create subplot
imagesc(xaxis,yaxis,img1);axis('image'); % Display image after pinhole filtering
xlabel('x, m');ylabel('y, m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('Pinhole - Image plane'); % Set title

subplot(3,4,3); % Create subplot
mesh(xaxis,yaxis,img1); % Plot intensity distribution after pinhole filtering (3D mesh plot)
xlabel('x, m');ylabel('y, m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(3,4,4); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img1(cen,:),'r'); % Plot center slice of filtered image
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title

subplot(3,4,5); % Create subplot
imagesc(fxaxis,fyaxis,filter2);axis('image'); % Display pinhole filter
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
title('High filter'); % Set title

subplot(3,4,6); % Create subplot
imagesc(xaxis,yaxis,img2);axis('image'); % Display image after pinhole filtering
xlabel('x, m');ylabel('y, m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('High filter - Image plane'); % Set title

subplot(3,4,7); % Create subplot
mesh(xaxis,yaxis,img2); % Plot intensity distribution after pinhole filtering (3D mesh plot)
xlabel('x, m');ylabel('y, m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(3,4,8); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img2(cen,:),'r'); % Plot center slice of filtered image
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title

subplot(3,4,9); % Create subplot
imagesc(fxaxis,fyaxis,filter4);axis('image'); % Display 3rd Fresnel zone filter
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
title('3rd Fresnel zone'); % Set title

subplot(3,4,10); % Create subplot
imagesc(xaxis,yaxis,img4);axis('image'); % Display image after 3rd Fresnel zone filtering
xlabel('x, m');ylabel('y, m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('3F zone - Image plane'); % Set title

subplot(3,4,11); % Create subplot
mesh(xaxis,yaxis,img4); % Plot intensity distribution after 3rd Fresnel zone filtering (3D mesh plot)
xlabel('x, m');ylabel('y, m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(3,4,12); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img4(cen,:),'r'); % Plot center slice of filtered image
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title