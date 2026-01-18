function c_value = adaptive_c_value(group_variance, V_low, V_high, c_max, c_min)
    % 根据块组方差自适应计算c值
    if group_variance < V_low
        c_value = c_max; % 平坦区域使用较大的c值，更强去噪
    elseif group_variance > V_high
        c_value = c_min; % 纹理区域使用较小的c值，保留细节
    else
        % 线性插值
        c_value = c_max - (c_max - c_min) * (group_variance - V_low) / (V_high - V_low);
    end
end