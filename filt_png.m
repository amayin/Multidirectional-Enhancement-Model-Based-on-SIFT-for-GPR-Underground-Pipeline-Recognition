clear;clc;
close all;
input_path = 'D:\硕士文件\gprMAX相关\实测数据\聪隆师兄仿真数据场景说明\simulation\顶点标记_labelimg\data_png';
img_list = readmatrix('D:\硕士文件\SIFT提取\实验结果\与YOLO对比\仿真数据对比\非全双曲线顶点记录.csv');
all_img_list = dir(fullfile(input_path,'*.png'));
output_path = 'D:\硕士文件\SIFT提取\实验结果\与YOLO对比\仿真数据对比\测试集\test_image_png';% 筛选图像输出路径

for i = 1:size(img_list,1)
   label = num2str(img_list(i));
   png_name = [label,'.png'];
   read_path = [input_path,'\',png_name];
   write_path = [output_path,'\',png_name];
   copyfile(read_path,output_path)
end