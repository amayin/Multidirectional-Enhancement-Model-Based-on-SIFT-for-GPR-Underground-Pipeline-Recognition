function [repeat_flag] = find_repeat_point(target_area,true_point_array,i,true_n,repeat_flag)
%���������ܣ�������i���ؼ����ʾͬһ��Ŀ��Ĺؼ��㣬��Ƿ�Χ������[i+1:true_n]
% repeat_flag:�ظ���ǣ����ùؼ����������ؼ����ʾ����ͬһ��Ŀ�꣬��ùؼ���Ĵ˱��Ϊ1��һ��Ŀ�������һ�����ظ��ؼ���
% target_area:����ɨ��ؼ����ж�Ϊ�ظ��ķ�Χ�������ؼ���֮��Ĺؼ������ڸ÷�Χ�ڣ���֮��Ĺؼ�����Ϊ�ظ�
% i:����ɨ��Ĺؼ������
% true_n:������Ŀ���ϵĹؼ�������
% true_point_array:һ���ṹ����������Ŀ���ϵĹؼ������꣬�������ߴ����Ϣ
x_left = target_area(i).x_left;
x_right = target_area(i).x_right;
y_up = target_area(i).y_up;
y_down = target_area(i).y_down;
for j = i+1:true_n
    if repeat_flag(j,1) == 1
        continue
    end
    if true_point_array(j).x>x_left && true_point_array(j).x<x_right &&...
            true_point_array(j).y>y_up && true_point_array(j).y<y_down % ���õ�λ�ڱ���ɨ���ķ�Χ֮��
        repeat_flag(j,1) = 1;
    end
end

