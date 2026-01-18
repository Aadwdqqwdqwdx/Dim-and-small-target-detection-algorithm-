function [corner_strength, enhanced_brightness] = enhanced_corner_strength(I, patch_size, brightness_boost)
% 增强版角点强度函数，专门用于提升目标亮度
% 输入:
%   I - 输入图像
%   patch_size - 块大小
%   brightness_boost - 亮度提升系数 (1.0-3.0)
% 输出:
%   corner_strength - 角点强度图
%   enhanced_brightness - 亮度增强后的图像

    if nargin < 3
        brightness_boost = 1.8; % 默认亮度提升系数
    end
    
    % 转换为double类型
    I = im2double(I);
    
    % 第一步：计算结构张量特征值
    G = fspecial('gaussian', [patch_size patch_size], 1.5);
    u = imfilter(I, G, 'symmetric');
    [Gx, Gy] = gradient(u);
    
    K = fspecial('gaussian', [patch_size patch_size], 2);
    J_11 = imfilter(Gx.^2, K, 'symmetric');
    J_12 = imfilter(Gx.*Gy, K, 'symmetric');
    J_22 = imfilter(Gy.^2, K, 'symmetric');
    
    % 计算特征值
    sqrt_delta = sqrt((J_11 - J_22).^2 + 4*J_12.^2);
    lambdaA = 0.5*(J_11 + J_22 + sqrt_delta);
    lambdaB = 0.5*(J_11 + J_22 - sqrt_delta);
    
    % 第二步：多特征融合的角点强度计算
    % 1. 基于特征值的角点响应
    corner_response1 = (lambdaA .* lambdaB) ./ (lambdaA + lambdaB + eps);
    
    % 2. 改进的Harris角点响应
    k = 0.04;
    det_M = J_11 .* J_22 - J_12.^2;
    trace_M = J_11 + J_22;
    corner_response2 = det_M - k * trace_M.^2;
    
    % 3. 梯度幅值响应
    gradient_magnitude = sqrt(Gx.^2 + Gy.^2);
    
    % 4. 局部对比度增强
    local_contrast = stdfilt(I, true(3));
    
    % 第三步：多特征融合
    % 归一化各个特征
    corner_response1_norm = mat2gray(corner_response1);
    corner_response2_norm = mat2gray(corner_response2);
    gradient_norm = mat2gray(gradient_magnitude);
    contrast_norm = mat2gray(local_contrast);
    
    % 特征权重分配（可根据需要调整）
    w1 = 0.4; % 角点响应1权重
    w2 = 0.3; % 角点响应2权重
    w3 = 0.2; % 梯度权重
    w4 = 0.1; % 对比度权重
    
    % 融合角点强度
    corner_strength = w1 * corner_response1_norm + ...
                     w2 * corner_response2_norm + ...
                     w3 * gradient_norm + ...
                     w4 * contrast_norm;
    
    % 应用非线性增强
    corner_strength = corner_strength.^0.7; % 伽马校正增强低值区域
    
    % 第四步：亮度提升处理
    enhanced_brightness = enhance_target_brightness(I, corner_strength, brightness_boost);
end

function enhanced_img = enhance_target_brightness(I, corner_strength, boost_factor)
% 专门针对目标区域进行亮度提升
    
    % 创建目标区域掩模（角点强度高的区域）
    target_mask = corner_strength > 0.3;
    
    % 对掩模进行形态学操作，填充空洞
    se = strel('disk', 2);
    target_mask = imclose(target_mask, se);
    target_mask = imfill(target_mask, 'holes');
    
    % 计算自适应亮度提升
    base_intensity = mean(I(target_mask));
    if base_intensity < 0.3
        local_boost = 1.5 * boost_factor;
    else
        local_boost = boost_factor;
    end
    
    % 应用亮度提升
    enhanced_img = I;
    
    % 方法1：线性提升目标区域
    target_region = I .* target_mask;
    enhanced_target = target_region * local_boost;
    enhanced_target = min(enhanced_target, 1);
    
    % 方法2：使用自适应直方图均衡化局部增强
    enhanced_target_adaptive = adapthisteq(target_region, 'ClipLimit', 0.02, 'NumTiles', [8 8]);
    
    % 结合两种增强方法
    alpha = 0.6; % 线性增强权重
    combined_target = alpha * enhanced_target + (1-alpha) * enhanced_target_adaptive;
    
    % 将增强后的目标区域融合回原图像
    background_region = I .* (~target_mask);
    enhanced_img = combined_target + background_region;
    
    % 全局对比度调整
    enhanced_img = imadjust(enhanced_img, stretchlim(enhanced_img, [0.01 0.99]), []);
end