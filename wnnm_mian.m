clc; clear all; close all;
addpath('common');

% 设置源文件夹和目标文件夹
sourcefilefolder = 'images/';
aimfilefolder = 'results/';
aimfilefolder1 = 'results/';

% 读取文件夹中的所有BMP图像
dirOutput = dir(fullfile(sourcefilefolder, '*.bmp'));
fileNames = {dirOutput.name};
num_images = numel(fileNames);

 % 针对256×256图像优化的参数
  patch_size = 3;          
  step = 4;
  nSimilar = 10;
  c_max = 0.05;
  c_min = 0.01;
  lambda = 0.001;
  max_iter = 5;
  beta = 0.01;             
  gama = 1.0;
  tol = 1e-4;               
  V_low = 0.0001;           
  V_high = 0.005;
  alpha = 0.5; 

for cur = 1:num_images
    fprintf('处理图像 %d/%d: %s\n', cur, num_images, fileNames{cur});
    
    % 读取图像
    img = imread([sourcefilefolder, '\', fileNames{cur}]); 
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = im2double(img);
    
    % 确保图像大小为256×256
    if any(size(img) ~= [256, 256])
        img = imresize(img, [256, 256]);
        fprintf('调整图像大小到256×256\n');
    end
    
    [rows, cols] = size(img);

    % 初始化输出矩阵和权重图
    denoised_img = zeros(rows, cols);
    residual_img = zeros(rows, cols);
    weight_map_denoised = zeros(rows, cols);
    weight_map_residual = zeros(rows, cols);

    % 获取所有可能参考块的位置
    x_pos = 1:step:rows-patch_size+1;
    y_pos = 1:step:cols-patch_size+1;
    total_patches = length(x_pos) * length(y_pos);

    % 为每个参考块寻找相似块并处理
    fprintf('处理进度: ');
    progress = 0;
    
    for i = 1:length(x_pos)
        for j = 1:length(y_pos)
            % 当前参考块位置
            x_ref = x_pos(i);
            y_ref = y_pos(j);
            
            % 更新进度显示
            current_progress = floor(((i-1)*length(y_pos)+j) / total_patches * 100);
            if current_progress > progress
                progress = current_progress;
                if mod(progress, 10) == 0
                    fprintf('%d%% ', progress);
                end
            end
            
            % 提取参考块
            ref_patch = img(x_ref:x_ref+patch_size-1, y_ref:y_ref+patch_size-1);
            
            % 在搜索窗口内寻找相似块（使用加权方法）
            [similar_patches, patch_positions] = find_similar_patches(...
                img, ref_patch, x_ref, y_ref, patch_size, nSimilar, alpha);
            
            % 计算相似块组的平均局部方差
            group_variance = calculate_group_variance(similar_patches);
            
            % 根据方差计算自适应c值
            c_value = adaptive_c_value(group_variance, V_low, V_high, c_max, c_min);
            
            % 对相似块组应用WNNM
            [denoised_group, residual_group] = wnnm_denoise(similar_patches, c_value, lambda, max_iter, beta, tol, gama);
            
            % 聚合处理后的块到输出图像（使用新的聚合函数）
            [denoised_img, weight_map_denoised] = aggregate_patches(...
                denoised_img, denoised_group, weight_map_denoised, patch_positions, patch_size);
            
            [residual_img, weight_map_residual] = aggregate_patches(...
                residual_img, residual_group, weight_map_residual, patch_positions, patch_size);
        end
    end
    fprintf('\n');
    
    % 归一化输出图像
    denoised_img = denoised_img ./ weight_map_denoised;
    residual_img = residual_img ./ weight_map_residual;
    
    % 处理可能的NaN和Inf值
    denoised_img(isnan(denoised_img)) = 0;
    residual_img(isnan(residual_img)) = 0;
    denoised_img(isinf(denoised_img)) = 0;
    residual_img(isinf(residual_img)) = 0;
    
    % 确保数据在[0,1]范围内
    denoised_img = max(0, min(1, denoised_img));
    residual_img = max(0, min(1, residual_img));
    
    % 保存图像
    imwrite(residual_img, [aimfilefolder '\' fileNames{cur}]);
    imwrite(denoised_img, [aimfilefolder1 '\' fileNames{cur}]);
   
    fprintf('已完成图像 %d/%d\n', cur, num_images);
end
fprintf('所有图像处理完成!\n');