function [denoised_group, residual_group] = wnnm_denoise(similar_patches, c_value, lambda, max_iter, beta, tol, gama,img)
    % 将块组转换为矩阵
    patches = similar_patches;
    group_matrix = zeros(numel(patches{1}), length(patches));
    for i = 1:length(patches)
        group_matrix(:, i) = patches{i}(:);
    end
    
    % 初始化变量
    delta = 1;
    L = zeros(size(group_matrix));
    S = zeros(size(group_matrix));
    N = zeros(size(group_matrix));
    Y1 = zeros(size(group_matrix));
    Y2 = zeros(size(group_matrix));
    Y3 = zeros(size(group_matrix));
    
    converged = false;
    iter = 0;
    group_matrix_norm = norm(group_matrix, 'fro');
    
    % 为每个块计算结构张量权重
    W = compute_structure_weights(patches, size(group_matrix));
    
    % 迭代优化
    while ~converged && iter < max_iter
        iter = iter + 1;
        
        % 保存上一次迭代结果
        L_prev = L;
        S_prev = S;
        
        % 更新低秩部分L（通过加权奇异值阈值）
        [U, Sigma, V] = svd(group_matrix - S - N + Y3/beta, 'econ');
        sigma = diag(Sigma);
        weights = c_value * sqrt(size(group_matrix, 2)) ./ (sigma + eps);
        sigma_hat = max(0, sigma - weights);
        L = U * diag(sigma_hat) * V';
        
        % 更新稀疏部分S（使用结构张量加权的软阈值）
        T = group_matrix - L - N + Y3/beta;
        
        % 应用结构权重调整阈值
        adjusted_lambda = lambda ./ (W + eps);
        %S = sign(T) .* max(0, abs(T) - adjusted_lambda/beta);
        S =T;%不用结构张量
        
        % 更新噪声投影N
        residual = group_matrix - L - S + Y3/beta;
        proj_scale = delta / (norm(residual, 'fro') + eps);
        N = min(proj_scale, 1) * residual;
        
        % 更新拉格朗日乘子
        Y1 = Y1 + gama * beta * (L - (group_matrix - S - N));
        Y2 = Y2 + gama * beta * (S - (group_matrix - L - N));
        Y3 = Y3 + gama * beta * (group_matrix - L - S - N);
        
        % 收敛判断
        primal_residual = norm([L - L_prev; S - S_prev], 'fro');
        stopping_measure = primal_residual / group_matrix_norm;
        
        if stopping_measure < tol
            converged = true;
        end
        
        % % 可选：输出迭代信息
        % if mod(iter, 10) == 0
        %     fprintf('迭代 %d, 误差: %.6f\n', iter, stopping_measure);
        % end
    end
    
    % 提取去噪后的块组和残差
    denoised_group = cell(1, size(L, 2));
    residual_group = cell(1, size(L, 2));
    
    for i = 1:size(L, 2)
        denoised_patch = reshape(L(:, i), size(patches{1}));
        residual_patch = reshape(S(:, i), size(patches{1}));
        
        denoised_group{i} = denoised_patch;
        residual_group{i} = residual_patch;
    end
end
