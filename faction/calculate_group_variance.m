
function group_variance = calculate_group_variance(patches)
    % 计算块组的平均方差
    variances = zeros(1, length(patches));
    for i = 1:length(patches)
        patch = patches{i};
        variances(i) = var(patch(:));
    end
    group_variance = mean(variances);
end