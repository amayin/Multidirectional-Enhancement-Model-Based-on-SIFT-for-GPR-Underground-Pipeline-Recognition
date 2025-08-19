function [E,matrix_descriptor] = Euclid_distance_of_Gloh_descriptor(descriptor, angle_bin)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
alpha = 3; % 调整两对欧氏距离权重的参数
beta = 0.3;
len_descriptor = length(descriptor);
if mod(len_descriptor, angle_bin) ~= 0
    error('向量长度必须为角度仓的倍数！');
end

short_des_len = (len_descriptor-angle_bin)/4;
matrix_descriptor = zeros(4,short_des_len-2);
% 构造对称矩阵
matrix_descriptor(1,:) = [descriptor(9*angle_bin-angle_bin/2+1:9*angle_bin-1),descriptor(angle_bin+1:5*angle_bin-angle_bin/2-1)];
matrix_descriptor(2,:) = [descriptor(5*angle_bin-angle_bin/2+1:5*angle_bin-1),descriptor(6*angle_bin),descriptor(5*angle_bin+1:6*angle_bin-1),descriptor(7*angle_bin),descriptor(6*angle_bin+1:7*angle_bin-1),descriptor(8*angle_bin),descriptor(7*angle_bin+1:8*angle_bin-1),descriptor(8*angle_bin+1:9*angle_bin-angle_bin/2-1)];
matrix_descriptor(3,:) = [descriptor(17*angle_bin-angle_bin/2+1:17*angle_bin-1),descriptor(9*angle_bin+1:13*angle_bin-angle_bin/2-1)];
matrix_descriptor(4,:) = [descriptor(13*angle_bin-angle_bin/2+1:13*angle_bin-1),descriptor(14*angle_bin),descriptor(13*angle_bin+1:14*angle_bin-1),descriptor(15*angle_bin),descriptor(14*angle_bin+1:15*angle_bin-1),descriptor(16*angle_bin),descriptor(15*angle_bin+1:16*angle_bin-1),descriptor(16*angle_bin+1:17*angle_bin-angle_bin/2-1)];

% 翻转
matrix_descriptor(2,:) = flip(matrix_descriptor(2,:));
matrix_descriptor(4,:) = flip(matrix_descriptor(4,:));
% 求欧氏距离
E1=norm(matrix_descriptor(2,:)-matrix_descriptor(1,:));
E2=norm(matrix_descriptor(4,:)-matrix_descriptor(3,:));
E = alpha*E1+beta*E2;
end

