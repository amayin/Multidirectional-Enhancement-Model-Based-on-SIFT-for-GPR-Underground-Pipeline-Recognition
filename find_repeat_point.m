function [repeat_flag] = find_repeat_point(target_area,true_point_array,i,true_n,repeat_flag)
%本函数功能：标记与第i个关键点表示同一个目标的关键点，标记范围仅包括[i+1:true_n]
% repeat_flag:重复标记，若该关键点与其他关键点表示的是同一个目标，则该关键点的此标记为1，一个目标仅保留一个非重复关键点
% target_area:本轮扫描关键点判定为重复的范围，若本关键点之后的关键点落在该范围内，则之后的关键点标记为重复
% i:本轮扫描的关键点序号
% true_n:所有在目标上的关键点数量
% true_point_array:一个结构，包含了在目标上的关键点坐标，层数，尺寸等信息
x_left = target_area(i).x_left;
x_right = target_area(i).x_right;
y_up = target_area(i).y_up;
y_down = target_area(i).y_down;
for j = i+1:true_n
    if repeat_flag(j,1) == 1
        continue
    end
    if true_point_array(j).x>x_left && true_point_array(j).x<x_right &&...
            true_point_array(j).y>y_up && true_point_array(j).y<y_down % 若该点位于本轮扫描点的范围之内
        repeat_flag(j,1) = 1;
    end
end

