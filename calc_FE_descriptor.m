% ���庯���������������
function [descriptor]=calc_FE_descriptor(gradient, angle, x, y, scale, main_angle, d, n, FS_vector)
% gradient: �ݶȷ���ֵ
% angle: �ݶȷ���ֵ
% x, y: �ؼ��������
% scale: �߶�
% main_angle: �ؼ����������
% d: ����������İ뾶��
% n: �ǶȲֵ�����

% ������ת��������Һ�����
cos_t = cos(-main_angle/180*pi);
sin_t = sin(-main_angle/180*pi);

% ��ȡ�ݶȾ���Ĵ�С
[M, N] = size(gradient);
% ������Ч�İ뾶
radius = round(min(12*scale, min(M, N)/3));

% �������������Ӽ��������߽�
radius_x_left = x - radius;
radius_x_right = x + radius;
radius_y_up = y - radius;
radius_y_down = y + radius;

% ��ֹ��������ͼ��߽�
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

% �������ĵ������ƫ��
center_x = x - radius_x_left + 1;
center_y = y - radius_y_up + 1;

% ��ȡ�����Ӽ��������ڵ��ݶȺͽǶ��Ӿ���
sub_gradient = gradient(radius_y_up:radius_y_down, radius_x_left:radius_x_right);
sub_angle = angle(radius_y_up:radius_y_down, radius_x_left:radius_x_right);
% �����ǶȾ����ֵ��ʹ�������������
sub_angle = round((sub_angle - main_angle) * n / 360);
sub_angle(sub_angle <= 0) = sub_angle(sub_angle <= 0) + n;
sub_angle(sub_angle == 0) = n;

% ������������
X = -(x - radius_x_left):1:(radius_x_right - x);
Y = -(y - radius_y_up):1:(radius_y_down - y);
[XX, YY] = meshgrid(X, Y);
% ������ת�������
c_rot = XX * cos_t - YY * sin_t;
r_rot = XX * sin_t + YY * cos_t;

% ʹ�ö���-������ת������ȡ�ǶȺͷ���
log_angle = atan2(r_rot, c_rot); % �Ƕ�
log_angle = log_angle / pi * 180; % ������ת��Ϊ�Ƕ�
log_angle(log_angle < 0) = log_angle(log_angle < 0) + 360; % �����Ƕȷ�Χ��0-360��
log_amplitude = log2(sqrt(c_rot.^2 + r_rot.^2)); % ��ؼ���֮��ľ��룬ʹ�ö����߶�

% �ԽǶȽ�����ɢ��
log_angle = round(log_angle * d / 360);
log_angle(log_angle <= 0) = log_angle(log_angle <= 0) + d;
log_angle(log_angle > d) = log_angle(log_angle > d) - d;

% ��������ɢ������������
r1 = log2(radius * 0.73 * 0.25);
r2 = log2(radius * 0.73);
log_amplitude(log_amplitude <= r1) = 1;
log_amplitude(log_amplitude > r1 & log_amplitude <= r2) = 2;
log_amplitude(log_amplitude > r2) = 3;

% ��ʼ��ֱ��ͼ
temp_hist = zeros(1, (2 * d + 1) * n);
[row, col] = size(log_angle);
for i = 1:row
    for j = 1:col
        if (((i - center_y)^2 + (j - center_x)^2) <= radius^2) % �����Ƿ��ڶ���İ뾶��
            angle_bin = log_angle(i, j);
            amplitude_bin = log_amplitude(i, j);
            bin_vertical = sub_angle(i, j);
            Mag = sub_gradient(i, j); % �ݶȷ�ֵ

            % ���ݷ��ȺͽǶȷ��䵽��Ӧ��ֱ��ͼ��
            if (amplitude_bin == 1)
                temp_hist(bin_vertical) = temp_hist(bin_vertical) + Mag * FS_vector(1,bin_vertical);
            else
                temp_hist(((amplitude_bin - 2) * d + angle_bin) * n + bin_vertical) = ...
                    temp_hist(((amplitude_bin - 2) * d + angle_bin) * n + bin_vertical) + Mag * FS_vector(1,bin_vertical);
            end
        end
    end
end

% ��һ��ֱ��ͼ���������ֵ
temp_hist = temp_hist / sqrt(temp_hist * temp_hist');
temp_hist(temp_hist > 0.2) = 0.2;
temp_hist = temp_hist / sqrt(temp_hist * temp_hist');
descriptor = temp_hist; % ���յ�����������

end