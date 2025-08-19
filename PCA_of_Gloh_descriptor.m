function [s,matrix_descriptor] = PCA_of_Gloh_descriptor(descriptor, angle_bin)
%UNTITLED2 ���������ڶ�Gloh��������������PCA�ֽ⣬������������136ά�ҽǶȲ�Ϊ8��
%   �˴���ʾ��ϸ˵��
len_descriptor = length(descriptor);
if mod(len_descriptor, angle_bin) ~= 0
    error('�������ȱ���Ϊ�ǶȲֵı�����');
end

short_des_len = (len_descriptor-angle_bin)/4;
matrix_descriptor = zeros(4,short_des_len-1);
% ����Գƾ���
matrix_descriptor(1,:) = [descriptor(9*angle_bin-angle_bin/2+1:9*angle_bin),descriptor(angle_bin+1:5*angle_bin-angle_bin/2-1)];
matrix_descriptor(2,:) = [descriptor(5*angle_bin-angle_bin/2+1:9*angle_bin-angle_bin/2-1)];
matrix_descriptor(3,:) = [descriptor(17*angle_bin-angle_bin/2+1:17*angle_bin),descriptor(9*angle_bin+1:13*angle_bin-angle_bin/2-1)];
matrix_descriptor(4,:) = [descriptor(13*angle_bin-angle_bin/2+1:17*angle_bin-angle_bin/2-1)];
% ��ת
matrix_descriptor(2,:) = flip(matrix_descriptor(2,:));
matrix_descriptor(4,:) = flip(matrix_descriptor(4,:));
% �����ɷ�
[~,S,~] = svd(matrix_descriptor);
s = diag(S);
norms = norm(s);
s = s/norms;
end

