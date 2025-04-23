% -----------------------------------------------------------------------%
% 4F Correlator Matlab Simulation
% 

clear;
close all;
clc;

%% Create pixel array
len = 512; % Length of pixel array (number of pixels)
cen = len/2 + 1; % Center position of pixel array (pixel coordinates)
dx = 5.0e-6;    % Pixel spacing in meters (m)  
df = 1/(len*dx);   % Spatial frequency domain sampling interval in 1/m (cycles/meter)
%% Create input object
%photo_source = imread('poles2.jpg'); % Read image file as input object (commented)
%object_photo = photo_source;

object = imread('ImB.jpg'); % Read image file ImA.jpg as input object
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

cutoff_freq2 = 0.12*maxfreq; % Second cutoff frequency (12% of maximum frequency)
filter2 = double(freq_rad >= cutoff_freq2); % Create high-frequency filter (1 for regions with frequency radius greater than cutoff frequency, 0 otherwise)

cutoff_freq3 = 0.2*maxfreq; % Third cutoff frequency (20% of maximum frequency)
filter3 = double(freq_rad <= cutoff_freq3); % Create low-frequency filter (1 for regions with frequency radius less than cutoff frequency, 0 otherwise)

filter4 = filter2.*filter3; % Create 3rd Fresnel zone filter (combining high and low frequency filters)

%% Create horizontal single slit aperture
h_single_slit = zeros(len,len); % Initialize horizontal single slit aperture as zero matrix
h_halfwidth   = 80;   % Half-width of single slit (pixels)
h_halfheight  = 12;    % Half-height of single slit (pixels)
h_single_slit((cen-h_halfheight):(cen+h_halfheight),(cen-h_halfwidth):(cen+h_halfwidth)) = ...
                                          ones(2*h_halfheight+1,2*h_halfwidth+1); % Create horizontal single slit at center position                 

%% Create vertical single slit aperture
v_single_slit = zeros(len,len); % Initialize vertical single slit aperture as zero matrix
v_halfwidth   = 12;   % Half-width of single slit (pixels)
v_halfheight  = 80;    % Half-height of single slit (pixels)
v_single_slit((cen-v_halfheight):(cen+v_halfheight),(cen-v_halfwidth):(cen+v_halfwidth)) = ...
                                          ones(2*v_halfheight+1,2*v_halfwidth+1); % Create vertical single slit at center position
                                      
%% Create vertical double slit aperture
v_double_slit = zeros(len,len); % Initialize vertical double slit aperture as zero matrix
v_halfwidth   = 12;   % Half-width of single slit (pixels)
v_halfheight  = 80;    % Half-height of single slit (pixels)
v_spacing     = 60;   % Spacing between double slits (pixels)
v_double_slit((cen-v_halfheight):(cen+v_halfheight),...
    ((cen-v_spacing/2)-v_halfwidth):((cen-v_spacing/2)+v_halfwidth)) = ...
                                          ones(2*v_halfheight+1,2*v_halfwidth+1); % Create first vertical slit
v_double_slit((cen-v_halfheight):(cen+v_halfheight),...
    ((cen+v_spacing/2)-v_halfwidth):((cen+v_spacing/2)+v_halfwidth)) = ...
                                          ones(2*v_halfheight+1,2*v_halfwidth+1); % Create second vertical slit

%% Create horizontal double slit aperture
h_double_slit = zeros(len,len); % Initialize horizontal double slit aperture as zero matrix
h_halfwidth   = 80;   % Half-width of single slit (pixels)
h_halfheight  = 12;    % Half-height of single slit (pixels)
h_spacing     = 60;   % Spacing between double slits (pixels)
h_double_slit(((cen-h_spacing/2)-h_halfheight):((cen-h_spacing/2)+h_halfheight),...
    (cen-h_halfwidth):(cen+h_halfwidth)) = ...
                                          ones(2*h_halfheight+1,2*h_halfwidth+1); % Create first horizontal slit
h_double_slit(((cen+h_spacing/2)-h_halfheight):((cen+h_spacing/2)+h_halfheight),...
    (cen-h_halfwidth):(cen+h_halfwidth)) = ...
                                          ones(2*h_halfheight+1,2*h_halfwidth+1); % Create second horizontal slit

%% Perform Fourier transform on input object
ftobj           = fftshift(fft2(fftshift(object(:,:,3)))); % Perform Fourier transform on blue channel of input object and center it
ft_single_slit  = fftshift(fft2(fftshift(h_single_slit))); % Perform Fourier transform on horizontal single slit aperture and center it
ft_double_slit  = fftshift(fft2(fftshift(h_double_slit))); % Perform Fourier transform on horizontal double slit aperture and center it

%% Implement filters
ftimg1 = ftobj.*filter1; % Apply pinhole filter to Fourier transform result of input object
ftimg2 = ftobj.*filter2; % Apply high-frequency filter to Fourier transform result of input object
ftimg4 = ftobj.*filter4; % Apply 3rd Fresnel zone filter to Fourier transform result of input object

ftimg_h_single_slit = ftobj.*h_single_slit; % Apply horizontal single slit aperture to Fourier transform result of input object
ftimg_h_double_slit = ftobj.*h_double_slit; % Apply horizontal double slit aperture to Fourier transform result of input object

ftimg_v_single_slit = ftobj.*v_single_slit; % Apply vertical single slit aperture to Fourier transform result of input object
ftimg_v_double_slit = ftobj.*v_double_slit; % Apply vertical double slit aperture to Fourier transform result of input object
%==========================================================
%% Calculate inverse Fourier transform after filtering
img1 = abs(fftshift(ifft2(fftshift(ftimg1)))); % Calculate inverse Fourier transform after pinhole filtering and take absolute value
img4 = abs(fftshift(ifft2(fftshift(ftimg4)))); % Calculate inverse Fourier transform after 3rd Fresnel zone filtering and take absolute value

img1_h_single_slit = abs(fftshift(ifft2(fftshift(ftimg_h_single_slit)))); % Calculate inverse Fourier transform after horizontal single slit aperture and take absolute value
img2_h_double_slit = abs(fftshift(ifft2(fftshift(ftimg_h_double_slit)))); % Calculate inverse Fourier transform after horizontal double slit aperture and take absolute value

img3_v_single_slit = abs(fftshift(ifft2(fftshift(ftimg_v_single_slit)))); % Calculate inverse Fourier transform after vertical single slit aperture and take absolute value
img4_v_double_slit = abs(fftshift(ifft2(fftshift(ftimg_v_double_slit)))); % Calculate inverse Fourier transform after vertical double slit aperture and take absolute value


%% Plot results for pinhole and 3rd Fresnel zone
figure('NumberTitle', 'off', 'Name', 'Pinhole and 3rd Fresnel zone'); % Create new figure window
set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]); % Set figure window size
colormap('parula'); % Set color map

subplot(2,4,1); % Create subplot
imagesc(xaxis,yaxis,filter1);axis('image'); % Display pinhole filter
xlabel('x, m');ylabel('y, m'); % Set axis labels
title('Pinhole'); % Set title

subplot(2,4,2); % Create subplot
imagesc(fxaxis,fyaxis,img1);axis('image'); % Display image after pinhole filtering
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('Pinhole - Image plane'); % Set title

subplot(2,4,3); % Create subplot
mesh(fxaxis,fyaxis,img1); % Plot intensity distribution after pinhole filtering (3D mesh plot)
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(2,4,4); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img1(cen,:),'r'); % Plot center slice of filtered image
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title

subplot(2,4,5); % Create subplot
imagesc(xaxis,yaxis,filter4);axis('image'); % Display 3rd Fresnel zone filter
xlabel('x, m');ylabel('y, m'); % Set axis labels
title('3rd Fresnel zone'); % Set title

subplot(2,4,6); % Create subplot
imagesc(fxaxis,fyaxis,img4);axis('image'); % Display image after 3rd Fresnel zone filtering
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('3F zone - Image plane'); % Set title

subplot(2,4,7); % Create subplot
mesh(fxaxis,fyaxis,img4); % Plot intensity distribution after 3rd Fresnel zone filtering (3D mesh plot)
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(2,4,8); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img4(cen,:),'r'); % Plot center slice of filtered image
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title

%% Plot results for horizontal single and double slits
figure('NumberTitle', 'off', 'Name', 'Horizontal Single and Double slits'); % Create new figure window
set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]); % Set figure window size
colormap('parula'); % Set color map

subplot(2,4,1); % Create subplot
imagesc(xaxis,yaxis,h_single_slit);axis('image'); % Display horizontal single slit aperture
xlabel('x, m');ylabel('y, m'); % Set axis labels
title('h_single_slit'); % Set title

subplot(2,4,2); % Create subplot
imagesc(fxaxis,fyaxis,img1_h_single_slit);axis('image'); % Display image after horizontal single slit aperture
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('img1_single_lit'); % Set title

subplot(2,4,3); % Create subplot
mesh(fxaxis,fyaxis,img1_h_single_slit); % Plot intensity distribution after horizontal single slit aperture (3D mesh plot)
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(2,4,4); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img1_h_single_slit(cen,:),'r'); % Plot center slice of image after horizontal single slit aperture
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title

subplot(2,4,5); % Create subplot
imagesc(xaxis,yaxis,h_double_slit);axis('image'); % Display horizontal double slit aperture
xlabel('x, m');ylabel('y, m'); % Set axis labels
title('h_double_slit'); % Set title

subplot(2,4,6); % Create subplot
imagesc(fxaxis,fyaxis,img2_h_double_slit);axis('image'); % Display image after horizontal double slit aperture
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('3F zone - Image plane'); % Set title

subplot(2,4,7); % Create subplot
mesh(fxaxis,fyaxis,img2_h_double_slit); % Plot intensity distribution after horizontal double slit aperture (3D mesh plot)
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(2,4,8); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img2_h_double_slit(cen,:),'r'); % Plot center slice of image after horizontal double slit aperture
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title

%% Plot results for vertical single and double slits
figure('NumberTitle', 'off', 'Name', 'Vertical Single and Double slits'); % Create new figure window
set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]); % Set figure window size
colormap('parula'); % Set color map

subplot(2,4,1); % Create subplot
imagesc(xaxis,yaxis,v_single_slit);axis('image'); % Display vertical single slit aperture
xlabel('x, m');ylabel('y, m'); % Set axis labels
title('v single slit'); % Set title

subplot(2,4,2); % Create subplot
imagesc(fxaxis,fyaxis,img3_v_single_slit);axis('image'); % Display image after vertical single slit aperture
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('img3 v single slit'); % Set title

subplot(2,4,3); % Create subplot
mesh(fxaxis,fyaxis,img3_v_single_slit); % Plot intensity distribution after vertical single slit aperture (3D mesh plot)
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(2,4,4); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img3_v_single_slit(cen,:),'r'); % Plot center slice of image after vertical single slit aperture
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title

subplot(2,4,5); % Create subplot
imagesc(xaxis,yaxis,v_double_slit);axis('image'); % Display vertical double slit aperture
xlabel('x, m');ylabel('y, m'); % Set axis labels
title('v double slit'); % Set title

subplot(2,4,6); % Create subplot
imagesc(fxaxis,fyaxis,img4_v_double_slit);axis('image'); % Display image after vertical double slit aperture
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % Set axis labels
colorbar('EastOutside'); % Add color bar
title('v double slit'); % Set title

subplot(2,4,7); % Create subplot
mesh(fxaxis,fyaxis,img4_v_double_slit); % Plot intensity distribution after vertical double slit aperture (3D mesh plot)
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % Set axis labels
title('Intensity values'); % Set title

subplot(2,4,8); % Create subplot
plot(xaxis,bin_object(cen,:));hold on;grid on; % Plot center slice of original object
plot(xaxis,img4_v_double_slit(cen,:),'r'); % Plot center slice of image after vertical double slit aperture
legend('object','image');xlabel('x, m');ylabel('Intensity'); % Add legend and axis labels
title('Slice through centers of object and image'); % Set title
