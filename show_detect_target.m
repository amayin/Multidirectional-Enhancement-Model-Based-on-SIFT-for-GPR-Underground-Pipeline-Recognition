function [true_point_array,repeat_flag] = show_detect_target(B_scan_image,key_point_array,pred_result,pred_label,photo_path)
%本函数功能为：标记重复的关键点，每一个目标仅保留一个关键点
% B_scan_image:原图像
% key_point_array:所有关键点的信息
% pred_label:分类器预测的结果

[image_row,image_col] = size(B_scan_image);
points_n = size(key_point_array,2); 
if points_n ~= size(pred_result,1)
    error('关键点数量和预测值数量需要一致！')
end
true_n = 0; % 记录目标关键点的个数
true_point_array=struct('x',{},'y',{},'octaves',{},'layer',{},...
     'xi',{},'size',{},'angle',{},'gradient',{});
% 目标关键点集合
for i = 1:points_n
    if (pred_result(i,1) == 1)
        true_n = true_n+1;
        true_point_array(true_n) = key_point_array(i);
    end
end

% 目标关键点判定为重合的区域
target_area=struct('x_left',{},'x_right',{},'y_left',{},'y_right',{});
for i = 1:true_n
    scale = true_point_array(i).size;
    x_radius = 0.5*scale;
    y_radius = 6*scale;
    x_left = true_point_array(i).x-2*x_radius;
    x_right = true_point_array(i).x+2*x_radius;
    y_up = true_point_array(i).y-2*y_radius;
    y_down = true_point_array(i).y+2*y_radius;
    if x_left<0
        x_left = 0;
    elseif x_right>image_col
        x_right = image_col;
    elseif y_up<0
        y_up = 0;
    elseif y_down>image_row
        y_down = image_row;
    end
    target_area(i).x_left = x_left;
    target_area(i).x_right = x_right;
    target_area(i).y_up = y_up;
    target_area(i).y_down = y_down;
end

% 去掉交叠关键点
repeat_flag = zeros(true_n,1);
for i = 1:true_n
    repeat_flag = find_repeat_point(target_area,true_point_array,i,true_n,repeat_flag);
end

% 画图
h=figure;
imagesc(B_scan_image);colormap('gray');hold on;

for i = 1:true_n
    if repeat_flag(i,1) ~= 1
        nrp_x = true_point_array(i).x;
        nrp_y = true_point_array(i).y;
        width = 2*scale;
        higth = 3*scale;
        draw_x = round(max(nrp_x-width/2,0));
        draw_y = round(max(nrp_y-higth/2,0));
        rectangle('Position', [draw_x, draw_y, width, higth], 'EdgeColor', 'b', 'LineWidth', 1);
    end
end
file_name = strcat(photo_path,pred_label,'.png');
saveas(h,file_name);
hold off;

end

