% -----------------------------------------------------------------------%
% Generate a periodic square pattern and perform Fourier transform
% -----------------------------------------------------------------------%

clear;
close all;
clc;

% Image size: 1000x1000 pixels representing 2 μm × 2 μm
% Lattice period: 100 nm
% Circle radius: 20 nm

% Parameters
pixel_size = 2e-6/1000; % 2μm/1000 pixels = 2nm per pixel
period = 100e-9; % 100nm period
radius = 20e-9; % 20nm radius
image_size = 1000; % 1000x1000 pixels

df = 1/(pixel_size*image_size); % Spatial frequency domain sampling interval in 1/m (cycles/meter)

xaxis = ((-image_size/2):(image_size/2-1))*pixel_size;
yaxis = -xaxis;

fxaxis = ((-image_size/2):(image_size/2-1))*df; % x-axis coordinates in spatial frequency domain (in 1/m)
fyaxis = -fxaxis;

% Create coordinate matrices
[x, y] = meshgrid(1:image_size, 1:image_size);
x = (x - image_size/2) * pixel_size;
y = (y - image_size/2) * pixel_size;

% Create the periodic pattern
pattern = zeros(image_size, image_size);
unit_num = 20;
for i = -unit_num:unit_num
    for j = -unit_num:unit_num
        % Calculate center of each circle
        center_x = i * period;
        center_y = j * period;
        
        % Create circle
        circle = ((x - center_x).^2 + (y - center_y).^2) <= radius^2;
        pattern = pattern | circle;
    end
end

% Display the original pattern
subplot(1,2,1);
imagesc(xaxis,yaxis,pattern); axis('image');
title('Original Pattern (Square Lattice)');
xlabel('X size (m)'); ylabel('Y size (m)');
colorbar('EastOutside'); 

% Perform Fourier transform
fft_pattern = fftshift(fft2(pattern));
fft_magnitude = abs(fft_pattern);

% Display the Fourier transform
subplot(1,2,2);
% imagesc(fxaxis,fyaxis,log(fft_magnitude+0.1)); axis('image');
imagesc(fxaxis,fyaxis,fft_magnitude); axis('image');
% Define plot range for Fourier transform (in cycles/meter)
plot_range = 5e7; % 5e7 cycles/meter, adjust this value as needed
% Set the display range for x and y axes
xlim([-plot_range plot_range]);
ylim([-plot_range plot_range]);
clim([0, 1e5]);  
title('Fourier Transform');
xlabel('Spatial Frequency (cycles/m)'); ylabel('Spatial Frequency (cycles/m)');
colorbar('EastOutside'); 