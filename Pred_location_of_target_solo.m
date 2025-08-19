% ���������㷨
clear;
clc;
close all;

% ��������Ҫʱ��ע��ĵط����������������ֶ�ѡȡ��ǩ���򣬱���·��

%% Define the constants used
file_path = 'F:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\Multidirectional Enhancement Model Based on SIFT for GPR Underground Pipeline Recognition_latex\������\PROJ2__004\';% SVMԤ������ȡ
photo_path = 'F:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\Multidirectional Enhancement Model Based on SIFT for GPR Underground Pipeline Recognition_latex\save_image\';
begin = 1;% �ļ���ʼ��ȡ��
en = 1;% �ļ�������ȡ��
des_type='FE-GLOH-like';%Type of descriptor,it can be 'GLOH-like','SIFT','FE-GLOH-like'
interpola = "off"; %�Ƿ�������ţ�"on"�ǣ�"off"��
inter_m = 4; %���ű���
mode = "DZT";

for outid = begin:en
%% ��ȡ�ļ�
    if strcmp(mode,"out")
    % out�����ļ�
    [TrackInterval,dt,B_scan_image,outfile_name] = read_outdata();
    file_parts = split(DZTfile_name,'.');
    file_label = file_parts{1};

    elseif strcmp(mode,"lte")
    % ��ȡlte�ļ�
    [TrackInterval,dt,B_scan_image,ltefile_name] = readB_scan();
    file_parts = split(ltefile_name,'.');
    file_label = file_parts{1};

    elseif strcmp(mode,"DZT")
    % ��ȡGSSI��˾��DZT�ļ�
    [TrackInterval,dt,B_scan_image,DZTfile_name] = main_gssi();
    TrackInterval = TrackInterval*0.01;% ���ڷ��ص���cm����˳�0.01
    time = (0:size(B_scan_image,1)-1)*dt;
    track = (1:size(B_scan_image,2))*TrackInterval; 
    file_parts = split(DZTfile_name,'.');
    file_label = file_parts{1};
    
    elseif strcmp(mode,"png")
    % ��ȡpng�ļ�
    [png_name, png_path] = uigetfile('*.png', 'Select gprMax image to analyse', 'MultiSelect', 'on');
    file_parts = split(png_name,'.');
    file_label = file_parts{1};
    png_full_path = strcat(png_path,'/',png_name);
    B_scan_png = imread(png_full_path);
    B_scan_image = im2double(B_scan_png(:,:,1));
    end

%     % ��ֵ����
%     for i = 1:size(B_scan_image,1)
%         B_scan_image(i,:) = B_scan_image(i,:)-mean(B_scan_image(i,:));
%     end
%     % ��ͼ
%     figure
%     imagesc(B_scan_image);
%     colormap('gray');
%     xlabel('Trace(m)');ylabel('Time(ns)');
%     set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');

    % ����
    if interpola == "on"
        B_scan_image = imresize(B_scan_image,inter_m);
    end

    % ��һ��
    B_scan_image = (B_scan_image-min(min(B_scan_image)))/(max(max(B_scan_image))-min(min(B_scan_image)));
    
    %% ��ȡ����
    pred_result_path = [file_path,'pred_',des_type,'.csv'];
    key_point_array_path = [file_path,'keypoint_',des_type,'\','keypoint_1.mat'];
    loc_path = [file_path,'loc_',des_type,'\','loc_1.csv'];
    pred_result=csvread(pred_result_path);
    key_point_array=load(key_point_array_path);
    key_point_array_1 = key_point_array.key_point_array_1;
    locs=csvread(loc_path);
    key_point_num = size(key_point_array_1,2);
    locs_1 = locs(2:key_point_num+1,:);
    
    %% test the accurancy of SVM(after the test in python)
    show_target_loc(B_scan_image,locs_1,pred_result);
    
    %% ���ºϲ�,��ʾ����ʶ����
    show_detect_target(B_scan_image,key_point_array_1,pred_result,'pred',photo_path);
end