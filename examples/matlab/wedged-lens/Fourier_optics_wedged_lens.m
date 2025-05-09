close all;
clear;
clc;

% Load the image
img = imread('uDBO_target.jpg');

% Convert to grayscale if it's a color image
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Convert to double for processing
img_double = im2double(img);

% Perform 2D Fourier Transform
F = fft2(img_double);

% Shift zero frequency to center
F_shifted = fftshift(F);

% Calculate magnitude spectrum
magnitude_spectrum = log(1 + abs(F_shifted));

% Create mask to block quadrants 1, 2, and 3
[M, N] = size(img);
mask = zeros(M, N);
halfM = floor(M/2);
halfN = floor(N/2);

% Keep only 4th quadrant (bottom-right)
mask(halfM+1:end, halfN+1:end) = 1;

% Apply mask to Fourier transform
F_filtered = F_shifted .* mask;

% Calculate magnitude spectrum of filtered Fourier transform
magnitude_spectrum_filtered = log(1 + abs(F_filtered));

% Perform inverse Fourier transform
img_filtered = real(ifft2(ifftshift(F_filtered)));

% Display results
figure(1);
subplot(1,2,1);
% Method 1: Specify range directly in imagesc
imagesc(magnitude_spectrum, [0, max(magnitude_spectrum(:))]);
colormap('parula');
colorbar;
axis('image');
title('Original Fourier Transform');

subplot(1,2,2);
imagesc(img);
colormap('parula');
% Method 2: Use caxis to set range
caxis([0, 1]);  % For normalized image data
colorbar;
axis('image');
title('Original Image');

figure(2);
subplot(1,2,1);
% Method 1: Specify range directly in imagesc
imagesc(magnitude_spectrum_filtered, [0, max(magnitude_spectrum_filtered(:))]);
colormap('parula');
colorbar;
axis('image');
title('Filtered Fourier Transform (1&2&3 blocked)');

subplot(1,2,2);
imagesc(img_filtered);
colormap('parula');
% Method 2: Use caxis to set range
caxis([min(img_filtered(:)), max(img_filtered(:))]);
colorbar;
axis('image');
title('Filtered Image');

% Save the results
% imwrite(magnitude_spectrum, 'fourier_transform_result.jpg');
% imwrite(img_filtered, 'filtered_image.jpg'); 