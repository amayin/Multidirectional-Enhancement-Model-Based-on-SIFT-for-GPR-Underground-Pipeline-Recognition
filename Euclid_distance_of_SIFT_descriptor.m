function [E,matrix_descriptor] = Euclid_distance_of_SIFT_descriptor(descriptor, angle_bin)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
alpha = 3; % ��������ŷ�Ͼ���Ȩ�صĲ���
beta = 0.3;
len_descriptor = length(descriptor);
if mod(len_descriptor, angle_bin) ~= 0
    error('�������ȱ���Ϊ�ǶȲֵı�����');
end

short_des_len = len_descriptor/8;
matrix_descriptor = zeros(8,short_des_len);
% ����Գƾ���
matrix_descriptor(1,:) = descriptor(1:2*angle_bin);
matrix_descriptor(2,:) = [descriptor(3*angle_bin),descriptor(2*angle_bin+1:3*angle_bin-1),descriptor(4*angle_bin),descriptor(3*angle_bin+1:4*angle_bin-1)];
matrix_descriptor(3,:) = descriptor(4*angle_bin+1:6*angle_bin);
matrix_descriptor(4,:) = [descriptor(7*angle_bin),descriptor(6*angle_bin+1:7*angle_bin-1),descriptor(8*angle_bin),descriptor(7*angle_bin+1:8*angle_bin-1)];
matrix_descriptor(5,:) = descriptor(8*angle_bin+1:10*angle_bin);
matrix_descriptor(6,:) = [descriptor(11*angle_bin),descriptor(10*angle_bin+1:11*angle_bin-1),descriptor(12*angle_bin),descriptor(11*angle_bin+1:12*angle_bin-1)];
matrix_descriptor(7,:) = descriptor(12*angle_bin+1:14*angle_bin);
matrix_descriptor(8,:) = [descriptor(15*angle_bin),descriptor(14*angle_bin+1:15*angle_bin-1),descriptor(16*angle_bin),descriptor(15*angle_bin+1:16*angle_bin-1)];
% ��ת
matrix_descriptor(2,:) = flip(matrix_descriptor(2,:));
matrix_descriptor(4,:) = flip(matrix_descriptor(4,:));
matrix_descriptor(6,:) = flip(matrix_descriptor(6,:));
matrix_descriptor(8,:) = flip(matrix_descriptor(8,:));
% ��ŷ�Ͼ���
E1=norm(matrix_descriptor(2,:)-matrix_descriptor(1,:));
E2=norm(matrix_descriptor(4,:)-matrix_descriptor(3,:));
E3=norm(matrix_descriptor(6,:)-matrix_descriptor(5,:));
E4=norm(matrix_descriptor(8,:)-matrix_descriptor(7,:));
E=E1/3+E2+E3+E4/3;
end