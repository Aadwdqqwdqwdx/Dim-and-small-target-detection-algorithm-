% function [img, weight_map] = aggregate_patches(img, patches, weight_map, patch_positions, patch_size)
%     % 聚合块到图像 - 增强版本
%     % 输入:
%     %   img - 基础图像矩阵
%     %   patches - 细胞数组，包含要聚合的图像块
%     %   weight_map - 权重图，记录每个像素被聚合的次数
%     %   patch_positions - 每个块在原始图像中的位置 [x, y] 坐标
%     %   patch_size - 图像块的尺寸
%     %
%     % 输出:
%     %   img - 聚合后的图像
%     %   weight_map - 更新后的权重图
% 
%     % 确保patch_positions与patches数量一致
%     if length(patches) ~= size(patch_positions, 1)
%         error('块数量与位置信息不匹配');
%     end
% 
%     % 遍历所有块
%     for i = 1:length(patches)
%         % 获取当前块的位置
%         x_pos = patch_positions(i, 1);
%         y_pos = patch_positions(i, 2);
% 
%         % 确保位置不超出图像边界
%         if x_pos < 1 || y_pos < 1 || ...
%            (x_pos + patch_size - 1) > size(img, 1) || ...
%            (y_pos + patch_size - 1) > size(img, 2)
%             continue; % 跳过超出边界的块
%         end
% 
%         % 将块累加到图像的对应位置
%         img(x_pos:x_pos+patch_size-1, y_pos:y_pos+patch_size-1) = ...
%             img(x_pos:x_pos+patch_size-1, y_pos:y_pos+patch_size-1) + patches{i};
% 
%         % 更新权重图
%         weight_map(x_pos:x_pos+patch_size-1, y_pos:y_pos+patch_size-1) = ...
%             weight_map(x_pos:x_pos+patch_size-1, y_pos:y_pos+patch_size-1) + 1;
%     end
% end
function [img, weight_map] = aggregate_patches(img, patches, weight_map, patch_positions, patch_size)
    % 聚合块到图像 - 增强版本
    % 输入:
    %   img - 基础图像矩阵
    %   patches - 细胞数组，包含要聚合的图像块
    %   weight_map - 权重图，记录每个像素被聚合的次数
    %   patch_positions - 每个块在原始图像中的位置 [x, y] 坐标
    %   patch_size - 图像块的尺寸
    %
    % 输出:
    %   img - 聚合后的图像
    %   weight_map - 更新后的权重图
    
    % 确保patch_positions与patches数量一致
    if length(patches) ~= size(patch_positions, 1)
        error('块数量与位置信息不匹配');
    end
    
    % 遍历所有块
    for i = 1:length(patches)
        % 获取当前块的位置
        x_pos = patch_positions(i, 1);
        y_pos = patch_positions(i, 2);
        
        % 确保位置不超出图像边界
        if x_pos < 1 || y_pos < 1 || ...
           (x_pos + patch_size - 1) > size(img, 1) || ...
           (y_pos + patch_size - 1) > size(img, 2)
            continue; % 跳过超出边界的块
        end
        
        % 将块累加到图像的对应位置
        img(x_pos:x_pos+patch_size-1, y_pos:y_pos+patch_size-1) = ...
            img(x_pos:x_pos+patch_size-1, y_pos:y_pos+patch_size-1) + patches{i};
        
        % 更新权重图
        weight_map(x_pos:x_pos+patch_size-1, y_pos:y_pos+patch_size-1) = ...
            weight_map(x_pos:x_pos+patch_size-1, y_pos:y_pos+patch_size-1) + 1;
    end
end