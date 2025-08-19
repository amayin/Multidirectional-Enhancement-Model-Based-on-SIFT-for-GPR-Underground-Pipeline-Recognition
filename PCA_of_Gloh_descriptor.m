function [s,matrix_descriptor] = PCA_of_Gloh_descriptor(descriptor, angle_bin)
%UNTITLED2 本函数用于对Gloh特征描述符进行PCA分解，描述符必须是136维且角度仓为8，
%   此处显示详细说明
len_descriptor = length(descriptor);
if mod(len_descriptor, angle_bin) ~= 0
    error('向量长度必须为角度仓的倍数！');
end

short_des_len = (len_descriptor-angle_bin)/4;
matrix_descriptor = zeros(4,short_des_len-1);
% 构造对称矩阵
matrix_descriptor(1,:) = [descriptor(9*angle_bin-angle_bin/2+1:9*angle_bin),descriptor(angle_bin+1:5*angle_bin-angle_bin/2-1)];
matrix_descriptor(2,:) = [descriptor(5*angle_bin-angle_bin/2+1:9*angle_bin-angle_bin/2-1)];
matrix_descriptor(3,:) = [descriptor(17*angle_bin-angle_bin/2+1:17*angle_bin),descriptor(9*angle_bin+1:13*angle_bin-angle_bin/2-1)];
matrix_descriptor(4,:) = [descriptor(13*angle_bin-angle_bin/2+1:17*angle_bin-angle_bin/2-1)];
% 翻转
matrix_descriptor(2,:) = flip(matrix_descriptor(2,:));
matrix_descriptor(4,:) = flip(matrix_descriptor(4,:));
% 求主成分
[~,S,~] = svd(matrix_descriptor);
s = diag(S);
norms = norm(s);
s = s/norms;
end

