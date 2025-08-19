clear;clc;
close all;
input_path = 'D:\硕士文件\gprMAX相关\实测数据\聪隆师兄仿真数据场景说明\simulation\ground_truth_txt3';
txt_list = readmatrix('D:\硕士文件\SIFT提取\实验结果\与YOLO对比\全双曲线顶点记录.csv');
all_txt_list = dir(fullfile(input_path,'*.txt'));
output_path = 'D:\硕士文件\gprMAX相关\实测数据\聪隆师兄仿真数据场景说明\simulation\陈宏畅筛选出的图像\groud_truth_txt';% 筛选图像输出路径

for i = 1:size(txt_list,1)
   label = num2str(txt_list(i));
   txt_name = [label,'.txt'];
   read_path = [input_path,'\',txt_name];
   write_path = [output_path,'\',txt_name];
   copyfile(read_path,output_path)
end