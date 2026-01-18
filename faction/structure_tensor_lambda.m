function [lambdaA, lambdaB] = structure_tensor_lambda(I, sz)
%这里使用了一个高斯核 G 对输入图像 img 进行平滑处理，以减少噪声的影响
G = fspecial('gaussian', [sz sz], 2); % Gaussian kernel
%生成一个大小为 [sz sz] 的高斯核，标准差为 2
u = imfilter(I, G, 'symmetric');
%imfilter 函数将高斯核应用于图像，'symmetric' 表示在边界处使用对称填充。
[Gx, Gy] = gradient(u);%使用 gradient 函数计算平滑后图像 u 的梯度 Gx 和 Gy，分别表示图像在水平和垂直方向上的梯度。
%这里再次使用高斯核 K 对梯度分量进行加权平均，得到结构张量的各个分量 J_11、J_12、J_21 和 J_22。这些分量分别表示梯度在水平和垂直方向上的平方和交叉乘积的加权平均。
K = fspecial('gaussian', [sz sz], 9); % Gaussian kernel
J_11 = imfilter(Gx.^2, K, 'symmetric'); 
J_12 = imfilter(Gx.*Gy, K, 'symmetric');
J_21 = J_12;
J_22 = imfilter(Gy.^2, K, 'symmetric');   
%通过求解结构张量的特征方程，计算出两个特征值 lambda_1 和 lambda_2。lambda_1 和 lambda_2 分别表示图像局部结构的主方向和次方向的强度
sqrt_delta = sqrt((J_11 - J_22).^2 + 4*J_12.^2);
lambdaA = 0.5*(J_11 + J_22 + sqrt_delta);
lambdaB = 0.5*(J_11 + J_22 - sqrt_delta);
