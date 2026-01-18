% 辅助函数：计算结构张量权重
function W = compute_structure_weights(patches, target_size)
    % 初始化权重矩阵
    patch_size = size(patches{1});
    W_single = zeros(patch_size);
    
    % 对每个块计算结构张量并累加
    for i = 1:length(patches)
        patch = patches{i};
        [lambdaA, lambdaB] = structure_tensor_lambda(patch, 3);
        
        % 计算角点强度
        % cornerStrength1 = ((lambdaA .* lambdaB) ./ (lambdaA + lambdaB + eps));
        % cornerStrength2 = 1 ./ (lambdaA.^2 - lambdaB.^2 + eps) + 0.005;
        % cornerStrength = cornerStrength1 .* cornerStrength2;
        cornerStrength =(lambdaA./(lambdaB+10^(-6)).*exp((-(lambdaA+lambdaB)))./10);
        
        % 累加权重
        W_single = W_single + cornerStrength;
    end
    
    % 平均权重并归一化
    W_single = W_single / length(patches);
    W_single = mat2gray(W_single);
    
    % 将权重扩展到与目标矩阵相同的大小
    W = repmat(W_single(:), 1, target_size(2));
end