% 定义函数和输入输出参数
function [descriptor]=calc_FE_descriptor(gradient, angle, x, y, scale, main_angle, d, n, FS_vector)
% gradient: 梯度幅度值
% angle: 梯度方向值
% x, y: 关键点的坐标
% scale: 尺度
% main_angle: 关键点的主方向
% d: 对数极坐标的半径仓
% n: 角度仓的数量

% 计算旋转矩阵的余弦和正弦
cos_t = cos(-main_angle/180*pi);
sin_t = sin(-main_angle/180*pi);

% 获取梯度矩阵的大小
[M, N] = size(gradient);
% 计算有效的半径
radius = round(min(12*scale, min(M, N)/3));

% 计算用于描述子计算的区域边界
radius_x_left = x - radius;
radius_x_right = x + radius;
radius_y_up = y - radius;
radius_y_down = y + radius;

% 防止索引超出图像边界
if(radius_x_left <= 0)
    radius_x_left = 1;
end
if(radius_x_right > N)
    radius_x_right = N;
end
if(radius_y_up <= 0)
    radius_y_up = 1;
end
if(radius_y_down > M)
    radius_y_down = M;
end

% 计算中心点的坐标偏移
center_x = x - radius_x_left + 1;
center_y = y - radius_y_up + 1;

% 提取描述子计算区域内的梯度和角度子矩阵
sub_gradient = gradient(radius_y_up:radius_y_down, radius_x_left:radius_x_right);
sub_angle = angle(radius_y_up:radius_y_down, radius_x_left:radius_x_right);
% 调整角度矩阵的值，使其相对于主方向
sub_angle = round((sub_angle - main_angle) * n / 360);
sub_angle(sub_angle <= 0) = sub_angle(sub_angle <= 0) + n;
sub_angle(sub_angle == 0) = n;

% 计算坐标网格
X = -(x - radius_x_left):1:(radius_x_right - x);
Y = -(y - radius_y_up):1:(radius_y_down - y);
[XX, YY] = meshgrid(X, Y);
% 计算旋转后的坐标
c_rot = XX * cos_t - YY * sin_t;
r_rot = XX * sin_t + YY * cos_t;

% 使用对数-极坐标转换来获取角度和幅度
log_angle = atan2(r_rot, c_rot); % 角度
log_angle = log_angle / pi * 180; % 将弧度转换为角度
log_angle(log_angle < 0) = log_angle(log_angle < 0) + 360; % 调整角度范围到0-360度
log_amplitude = log2(sqrt(c_rot.^2 + r_rot.^2)); % 与关键点之间的距离，使用对数尺度

% 对角度进行离散化
log_angle = round(log_angle * d / 360);
log_angle(log_angle <= 0) = log_angle(log_angle <= 0) + d;
log_angle(log_angle > d) = log_angle(log_angle > d) - d;

% 将幅度离散化到三个仓中
r1 = log2(radius * 0.73 * 0.25);
r2 = log2(radius * 0.73);
log_amplitude(log_amplitude <= r1) = 1;
log_amplitude(log_amplitude > r1 & log_amplitude <= r2) = 2;
log_amplitude(log_amplitude > r2) = 3;

% 初始化直方图
temp_hist = zeros(1, (2 * d + 1) * n);
[row, col] = size(log_angle);
for i = 1:row
    for j = 1:col
        if (((i - center_y)^2 + (j - center_x)^2) <= radius^2) % 检查点是否在定义的半径内
            angle_bin = log_angle(i, j);
            amplitude_bin = log_amplitude(i, j);
            bin_vertical = sub_angle(i, j);
            Mag = sub_gradient(i, j); % 梯度幅值

            % 根据幅度和角度分配到相应的直方图仓
            if (amplitude_bin == 1)
                temp_hist(bin_vertical) = temp_hist(bin_vertical) + Mag * FS_vector(1,bin_vertical);
            else
                temp_hist(((amplitude_bin - 2) * d + angle_bin) * n + bin_vertical) = ...
                    temp_hist(((amplitude_bin - 2) * d + angle_bin) * n + bin_vertical) + Mag * FS_vector(1,bin_vertical);
            end
        end
    end
end

% 归一化直方图，限制最大值
temp_hist = temp_hist / sqrt(temp_hist * temp_hist');
temp_hist(temp_hist > 0.2) = 0.2;
temp_hist = temp_hist / sqrt(temp_hist * temp_hist');
descriptor = temp_hist; % 最终的描述子向量

end