% -----------------------------------------------------------------------%
% 4F Correlator Matlab Simulation
% 

clear;
close all;
clc;

%% 创建像素阵列
len = 512; % 像素阵列的长度（像素数）
cen = len/2 + 1; % 像素阵列的中心位置（像素坐标）
dx = 5.0e-6;    % 像素间距，单位为米(m)  
df = 1/(len*dx);   % 空间频率域的采样间隔，单位为1/m（周期/米）
%% 创建输入对象
%photo_source = imread('poles2.jpg'); % 读取图片文件作为输入对象（被注释）
%object_photo = photo_source;

object = imread('ImB.jpg'); % 读取图片文件ImA.jpg作为输入对象
bin_object = rgb2gray(object); % 将输入对象转换为灰度图像
xaxis = ((-len/2):(len/2-1))*dx; % 定义图像的x轴坐标（单位为米）
yaxis = -xaxis; % 定义图像的y轴坐标（单位为米）

%% 创建滤波器
fxaxis = ((-len/2):(len/2-1))*df; % 空间频率域的x轴坐标（单位为1/m）
fyaxis = -fxaxis; % 空间频率域的y轴坐标（单位为1/m）
[FX,FY] = meshgrid(fxaxis,fyaxis);  % 生成二维网格，表示每个点的fx和fy位置
freq_rad = sqrt(FX.^2 + FY.^2); % 计算每个点的频率半径
maxfreq = (len/2-1)*df; % 最大频率值

cutoff_freq1 = 0.1*maxfreq; % 第一个截止频率（10%的最大频率）
filter1 = double(freq_rad <= cutoff_freq1); % 创建针孔滤波器（频率半径小于截止频率的区域为1，其余为0）

cutoff_freq2 = 0.12*maxfreq; % 第二个截止频率（12%的最大频率）
filter2 = double(freq_rad >= cutoff_freq2); % 创建高频滤波器（频率半径大于截止频率的区域为1，其余为0）

cutoff_freq3 = 0.2*maxfreq; % 第三个截止频率（20%的最大频率）
filter3 = double(freq_rad <= cutoff_freq3); % 创建低频滤波器（频率半径小于截止频率的区域为1，其余为0）

filter4 = filter2.*filter3; % 创建第3个菲涅尔区滤波器（结合高频和低频滤波器）

%% 创建水平单缝光阑
h_single_slit = zeros(len,len); % 初始化水平单缝光阑为全零矩阵
h_halfwidth   = 80;   % 单缝的半宽度（像素）
h_halfheight  = 12;    % 单缝的半高度（像素）
h_single_slit((cen-h_halfheight):(cen+h_halfheight),(cen-h_halfwidth):(cen+h_halfwidth)) = ...
                                          ones(2*h_halfheight+1,2*h_halfwidth+1); % 在中心位置创建水平单缝                 

%% 创建垂直单缝光阑
v_single_slit = zeros(len,len); % 初始化垂直单缝光阑为全零矩阵
v_halfwidth   = 12;   % 单缝的半宽度（像素）
v_halfheight  = 80;    % 单缝的半高度（像素）
v_single_slit((cen-v_halfheight):(cen+v_halfheight),(cen-v_halfwidth):(cen+v_halfwidth)) = ...
                                          ones(2*v_halfheight+1,2*v_halfwidth+1); % 在中心位置创建垂直单缝
                                      
%% 创建垂直双缝光阑
v_double_slit = zeros(len,len); % 初始化垂直双缝光阑为全零矩阵
v_halfwidth   = 12;   % 单缝的半宽度（像素）
v_halfheight  = 80;    % 单缝的半高度（像素）
v_spacing     = 60;   % 双缝的间距（像素）
v_double_slit((cen-v_halfheight):(cen+v_halfheight),...
    ((cen-v_spacing/2)-v_halfwidth):((cen-v_spacing/2)+v_halfwidth)) = ...
                                          ones(2*v_halfheight+1,2*v_halfwidth+1); % 创建第一个垂直缝
v_double_slit((cen-v_halfheight):(cen+v_halfheight),...
    ((cen+v_spacing/2)-v_halfwidth):((cen+v_spacing/2)+v_halfwidth)) = ...
                                          ones(2*v_halfheight+1,2*v_halfwidth+1); % 创建第二个垂直缝

%% 创建水平双缝光阑
h_double_slit = zeros(len,len); % 初始化水平双缝光阑为全零矩阵
h_halfwidth   = 80;   % 单缝的半宽度（像素）
h_halfheight  = 12;    % 单缝的半高度（像素）
h_spacing     = 60;   % 双缝的间距（像素）
h_double_slit(((cen-h_spacing/2)-h_halfheight):((cen-h_spacing/2)+h_halfheight),...
    (cen-h_halfwidth):(cen+h_halfwidth)) = ...
                                          ones(2*h_halfheight+1,2*h_halfwidth+1); % 创建第一个水平缝
h_double_slit(((cen+h_spacing/2)-h_halfheight):((cen+h_spacing/2)+h_halfheight),...
    (cen-h_halfwidth):(cen+h_halfwidth)) = ...
                                          ones(2*h_halfheight+1,2*h_halfwidth+1); % 创建第二个水平缝

%% 对输入对象进行傅里叶变换
ftobj           = fftshift(fft2(fftshift(object(:,:,3)))); % 对输入对象的蓝色通道进行傅里叶变换并中心化
ft_single_slit  = fftshift(fft2(fftshift(h_single_slit))); % 对水平单缝光阑进行傅里叶变换并中心化
ft_double_slit  = fftshift(fft2(fftshift(h_double_slit))); % 对水平双缝光阑进行傅里叶变换并中心化

%% 滤波器实现
ftimg1 = ftobj.*filter1; % 将针孔滤波器应用于输入对象的傅里叶变换结果
ftimg2 = ftobj.*filter2; % 将高频滤波器应用于输入对象的傅里叶变换结果
ftimg4 = ftobj.*filter4; % 将第3个菲涅尔区滤波器应用于输入对象的傅里叶变换结果

ftimg_h_single_slit = ftobj.*h_single_slit; % 将水平单缝光阑应用于输入对象的傅里叶变换结果
ftimg_h_double_slit = ftobj.*h_double_slit; % 将水平双缝光阑应用于输入对象的傅里叶变换结果

ftimg_v_single_slit = ftobj.*v_single_slit; % 将垂直单缝光阑应用于输入对象的傅里叶变换结果
ftimg_v_double_slit = ftobj.*v_double_slit; % 将垂直双缝光阑应用于输入对象的傅里叶变换结果
%==========================================================
%% 计算滤波后的逆傅里叶变换
img1 = abs(fftshift(ifft2(fftshift(ftimg1)))); % 计算针孔滤波后的逆傅里叶变换并取绝对值
img4 = abs(fftshift(ifft2(fftshift(ftimg4)))); % 计算第3个菲涅尔区滤波后的逆傅里叶变换并取绝对值

img1_h_single_slit = abs(fftshift(ifft2(fftshift(ftimg_h_single_slit)))); % 计算水平单缝光阑后的逆傅里叶变换并取绝对值
img2_h_double_slit = abs(fftshift(ifft2(fftshift(ftimg_h_double_slit)))); % 计算水平双缝光阑后的逆傅里叶变换并取绝对值

img3_v_single_slit = abs(fftshift(ifft2(fftshift(ftimg_v_single_slit)))); % 计算垂直单缝光阑后的逆傅里叶变换并取绝对值
img4_v_double_slit = abs(fftshift(ifft2(fftshift(ftimg_v_double_slit)))); % 计算垂直双缝光阑后的逆傅里叶变换并取绝对值


%% 绘制针孔和第3个菲涅尔区的结果
figure('NumberTitle', 'off', 'Name', 'Pinhole and 3rd Fresnel zone'); % 创建一个新的图形窗口
set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]); % 设置图形窗口的大小
colormap('parula'); % 设置颜色映射

subplot(2,4,1); % 创建子图
imagesc(xaxis,yaxis,filter1);axis('image'); % 显示针孔滤波器
xlabel('x, m');ylabel('y, m'); % 设置坐标轴标签
title('Pinhole'); % 设置标题

subplot(2,4,2); % 创建子图
imagesc(fxaxis,fyaxis,img1);axis('image'); % 显示针孔滤波后的图像
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % 设置坐标轴标签
colorbar('EastOutside'); % 添加颜色条
title('Pinhole - Image plane'); % 设置标题

subplot(2,4,3); % 创建子图
mesh(fxaxis,fyaxis,img1); % 绘制针孔滤波后的强度分布（三维网格图）
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % 设置坐标轴标签
title('Intensity values'); % 设置标题

subplot(2,4,4); % 创建子图
plot(xaxis,bin_object(cen,:));hold on;grid on; % 绘制原始对象的中心切片
plot(xaxis,img1(cen,:),'r'); % 绘制滤波后图像的中心切片
legend('object','image');xlabel('x, m');ylabel('Intensity'); % 添加图例和坐标轴标签
title('Slice through centers of object and image'); % 设置标题

subplot(2,4,5); % 创建子图
imagesc(xaxis,yaxis,filter4);axis('image'); % 显示第3个菲涅尔区滤波器
xlabel('x, m');ylabel('y, m'); % 设置坐标轴标签
title('3rd Fresnel zone'); % 设置标题

subplot(2,4,6); % 创建子图
imagesc(fxaxis,fyaxis,img4);axis('image'); % 显示第3个菲涅尔区滤波后的图像
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % 设置坐标轴标签
colorbar('EastOutside'); % 添加颜色条
title('3F zone - Image plane'); % 设置标题

subplot(2,4,7); % 创建子图
mesh(fxaxis,fyaxis,img4); % 绘制第3个菲涅尔区滤波后的强度分布（三维网格图）
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % 设置坐标轴标签
title('Intensity values'); % 设置标题

subplot(2,4,8); % 创建子图
plot(xaxis,bin_object(cen,:));hold on;grid on; % 绘制原始对象的中心切片
plot(xaxis,img4(cen,:),'r'); % 绘制滤波后图像的中心切片
legend('object','image');xlabel('x, m');ylabel('Intensity'); % 添加图例和坐标轴标签
title('Slice through centers of object and image'); % 设置标题

%% 绘制水平单缝和双缝的结果
figure('NumberTitle', 'off', 'Name', 'Horizontal Single and Double slits'); % 创建一个新的图形窗口
set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]); % 设置图形窗口的大小
colormap('parula'); % 设置颜色映射

subplot(2,4,1); % 创建子图
imagesc(xaxis,yaxis,h_single_slit);axis('image'); % 显示水平单缝光阑
xlabel('x, m');ylabel('y, m'); % 设置坐标轴标签
title('h_single_slit'); % 设置标题

subplot(2,4,2); % 创建子图
imagesc(fxaxis,fyaxis,img1_h_single_slit);axis('image'); % 显示水平单缝光阑后的图像
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % 设置坐标轴标签
colorbar('EastOutside'); % 添加颜色条
title('img1_single_lit'); % 设置标题

subplot(2,4,3); % 创建子图
mesh(fxaxis,fyaxis,img1_h_single_slit); % 绘制水平单缝光阑后的强度分布（三维网格图）
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % 设置坐标轴标签
title('Intensity values'); % 设置标题

subplot(2,4,4); % 创建子图
plot(xaxis,bin_object(cen,:));hold on;grid on; % 绘制原始对象的中心切片
plot(xaxis,img1_h_single_slit(cen,:),'r'); % 绘制水平单缝光阑后图像的中心切片
legend('object','image');xlabel('x, m');ylabel('Intensity'); % 添加图例和坐标轴标签
title('Slice through centers of object and image'); % 设置标题

subplot(2,4,5); % 创建子图
imagesc(xaxis,yaxis,h_double_slit);axis('image'); % 显示水平双缝光阑
xlabel('x, m');ylabel('y, m'); % 设置坐标轴标签
title('h_double_slit'); % 设置标题

subplot(2,4,6); % 创建子图
imagesc(fxaxis,fyaxis,img2_h_double_slit);axis('image'); % 显示水平双缝光阑后的图像
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % 设置坐标轴标签
colorbar('EastOutside'); % 添加颜色条
title('3F zone - Image plane'); % 设置标题

subplot(2,4,7); % 创建子图
mesh(fxaxis,fyaxis,img2_h_double_slit); % 绘制水平双缝光阑后的强度分布（三维网格图）
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % 设置坐标轴标签
title('Intensity values'); % 设置标题

subplot(2,4,8); % 创建子图
plot(xaxis,bin_object(cen,:));hold on;grid on; % 绘制原始对象的中心切片
plot(xaxis,img2_h_double_slit(cen,:),'r'); % 绘制水平双缝光阑后图像的中心切片
legend('object','image');xlabel('x, m');ylabel('Intensity'); % 添加图例和坐标轴标签
title('Slice through centers of object and image'); % 设置标题

%% 绘制垂直单缝和双缝的结果
figure('NumberTitle', 'off', 'Name', 'Vertical Single and Double slits'); % 创建一个新的图形窗口
set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]); % 设置图形窗口的大小
colormap('parula'); % 设置颜色映射

subplot(2,4,1); % 创建子图
imagesc(xaxis,yaxis,v_single_slit);axis('image'); % 显示垂直单缝光阑
xlabel('x, m');ylabel('y, m'); % 设置坐标轴标签
title('v single slit'); % 设置标题

subplot(2,4,2); % 创建子图
imagesc(fxaxis,fyaxis,img3_v_single_slit);axis('image'); % 显示垂直单缝光阑后的图像
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % 设置坐标轴标签
colorbar('EastOutside'); % 添加颜色条
title('img3 v single slit'); % 设置标题

subplot(2,4,3); % 创建子图
mesh(fxaxis,fyaxis,img3_v_single_slit); % 绘制垂直单缝光阑后的强度分布（三维网格图）
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % 设置坐标轴标签
title('Intensity values'); % 设置标题

subplot(2,4,4); % 创建子图
plot(xaxis,bin_object(cen,:));hold on;grid on; % 绘制原始对象的中心切片
plot(xaxis,img3_v_single_slit(cen,:),'r'); % 绘制垂直单缝光阑后图像的中心切片
legend('object','image');xlabel('x, m');ylabel('Intensity'); % 添加图例和坐标轴标签
title('Slice through centers of object and image'); % 设置标题

subplot(2,4,5); % 创建子图
imagesc(xaxis,yaxis,v_double_slit);axis('image'); % 显示垂直双缝光阑
xlabel('x, m');ylabel('y, m'); % 设置坐标轴标签
title('v double slit'); % 设置标题

subplot(2,4,6); % 创建子图
imagesc(fxaxis,fyaxis,img4_v_double_slit);axis('image'); % 显示垂直双缝光阑后的图像
xlabel('fx, cycles/m');ylabel('fy, cycles/m'); % 设置坐标轴标签
colorbar('EastOutside'); % 添加颜色条
title('v double slit'); % 设置标题

subplot(2,4,7); % 创建子图
mesh(fxaxis,fyaxis,img4_v_double_slit); % 绘制垂直双缝光阑后的强度分布（三维网格图）
xlabel('fx, cycles/m');ylabel('fy, cycles/m');zlabel('Intensity'); % 设置坐标轴标签
title('Intensity values'); % 设置标题

subplot(2,4,8); % 创建子图
plot(xaxis,bin_object(cen,:));hold on;grid on; % 绘制原始对象的中心切片
plot(xaxis,img4_v_double_slit(cen,:),'r'); % 绘制垂直双缝光阑后图像的中心切片
legend('object','image');xlabel('x, m');ylabel('Intensity'); % 添加图例和坐标轴标签
title('Slice through centers of object and image'); % 设置标题

