clear;clc;
close all;
input_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\��¡ʦ�ַ������ݳ���˵��\simulation\ground_truth_txt3';
txt_list = readmatrix('D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\��YOLO�Ա�\ȫ˫���߶����¼.csv');
all_txt_list = dir(fullfile(input_path,'*.txt'));
output_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\��¡ʦ�ַ������ݳ���˵��\simulation\�º곩ɸѡ����ͼ��\groud_truth_txt';% ɸѡͼ�����·��

for i = 1:size(txt_list,1)
   label = num2str(txt_list(i));
   txt_name = [label,'.txt'];
   read_path = [input_path,'\',txt_name];
   write_path = [output_path,'\',txt_name];
   copyfile(read_path,output_path)
end