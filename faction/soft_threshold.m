% 软阈值函数
function y = soft_threshold(x, lambda)
    y = sign(x) .* max(0, abs(x) - lambda);
end