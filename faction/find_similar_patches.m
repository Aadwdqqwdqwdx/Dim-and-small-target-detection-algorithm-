function [similar_patches, patch_positions] = find_similar_patches_weighted(img, ref_patch, x_ref, y_ref, patch_size, nSimilar, alpha)
    % 计算参考块的方差
    ref_variance = var(ref_patch(:));
    
    % 定义搜索窗口大小（针对256×256图像优化）
    search_win = 20;
    
    % 计算搜索窗口边界
    x_min = max(1, x_ref - search_win);
    x_max = min(size(img,1)-patch_size+1, x_ref + search_win);
    y_min = max(1, y_ref - search_win);
    y_max = min(size(img,2)-patch_size+1, y_ref + search_win);
    
    % 初始化
    distances = [];
    patches = {};
    positions = []; % 存储每个块的位置
    
    % 遍历搜索窗口内的所有块
    for x = x_min:x_max
        for y = y_min:y_max
            % 提取当前块
            current_patch = img(x:x+patch_size-1, y:y+patch_size-1);
            
            % 计算当前块的方差
            current_variance = var(current_patch(:));
            
            % 计算与参考块的欧氏距离
            pixel_dist = norm(ref_patch(:) - current_patch(:));
            
            % 计算方差差异
            var_dist = abs(ref_variance - current_variance);
            
            % 组合距离（加权和）
            combined_dist = (1-alpha)*pixel_dist + alpha*var_dist;
            
            % 保存距离、块和位置
            distances = [distances, combined_dist];
            patches = [patches, current_patch];
            positions = [positions; [x, y]];
        end
    end
    
    % 如果没有找到任何块，返回参考块本身
    if isempty(distances)
        similar_patches = {ref_patch};
        patch_positions = [x_ref, y_ref];
        return;
    end
    
    % 按距离排序并选择最相似的nSimilar个块
    [~, idx] = sort(distances);
    selected_idx = idx(1:min(nSimilar, length(idx)));
    
    similar_patches = patches(selected_idx);
    patch_positions = positions(selected_idx, :);
end