function img_out = post_process(img_in, filter_sigma)
    % 轻微高斯滤波以减少块效应
    img_out = imgaussfilt(img_in, filter_sigma);
end