clear;clc;
close all;
input_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\��¡ʦ�ַ������ݳ���˵��\simulation\������_labelimg\data_png';
img_list = readmatrix('D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\��YOLO�Ա�\�������ݶԱ�\��ȫ˫���߶����¼.csv');
all_img_list = dir(fullfile(input_path,'*.png'));
output_path = 'D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\��YOLO�Ա�\�������ݶԱ�\���Լ�\test_image_png';% ɸѡͼ�����·��

for i = 1:size(img_list,1)
   label = num2str(img_list(i));
   png_name = [label,'.png'];
   read_path = [input_path,'\',png_name];
   write_path = [output_path,'\',png_name];
   copyfile(read_path,output_path)
end