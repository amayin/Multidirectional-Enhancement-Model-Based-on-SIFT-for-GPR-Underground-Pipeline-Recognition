% ���ļ������㷨
clear;
clc;
close all;

% ��������Ҫʱ��ע��ĵط��������������򣬶�ȡ�ļ����������ֶ�ѡȡ��ǩ����

%% Define the constants used
out_file_path = 'E:\PyCharmCommunity\SIFT_SVM\GenerateCylinder_new\testDataset6\out_data4\';% out�ļ�·��
mat_file_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\SIFT_extract_in_GPR\training_data1\';% mat�ļ�·��
output_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\SIFT_extract_in_GPR\descriptors\target_real\';
GSSI_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\���ֲ���ʵ����������\���ֲ���ʵ����������\';
GSSI_name = 'PROJ2__001.DZT';
lte_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\lteʵ����������';
DAT_path = 'E:\Reflexw\REFLEX64Bit\ROHDATA\________.DAT';
file_prefix = 'xmbdata_';% �ļ���ͷ
sigma=1.6;%��ײ��˹�������ĳ߶�
dog_center_layer=5;%������DOG������ÿ���м������Ĭ����3
is_double_size=false;%expand image or not
change_form='affine';%change mode,'perspective','affine','similarity'

    %% ��ȡ�ļ�
    % out�����ļ�
%     fileName = strcat(file_prefix,num2str(outid));
%     fileName = strcat(fileName,'_merged.out');
%     filePath = strcat(out_file_path,fileName);
%     B_scan_image = readB_scan_simlation_data(filePath);

    % ��ȡite�ļ�
%     [TrackInterval,dt,B_scan_image,file_name] = readB_scan();
%     file_parts = split(file_name,'.');
%     file_label = file_parts{1};

   % ��ȡ�ں�mat�ļ�
%     filepath = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\2023��12������\fusion_of_different_freqency\Fusion.mat';
%     data = load(filepath);
%     B_scan_image = data.B;  

    % ��ȡGSSI�ļ�
    full_GSSI_path = strcat(GSSI_path,GSSI_name);
    [TrackInterval,dt,B_scan_image] = main_gssi(full_GSSI_path);
    TrackInterval = TrackInterval*0.01;% ���ڷ��ص���cm����˳�0.01
    time = (0:size(B_scan_image,1)-1)*dt;
    track = (1:size(B_scan_image,2))*TrackInterval; 
    file_parts = split(GSSI_name,'.');
    file_label = file_parts{1};

%     % ��ȡdat�ļ�
%     fid = fopen(DAT_path,'r');       %�������ļ�
%     B_scan_image = fscanf(fid,'%g');                 %��ȡ�ļ�����
%     file_label = '________';
    % ��ͼ
    figure
    imagesc(B_scan_image);
    colormap('gray');
    xlabel('Trace(m)');ylabel('Time(ns)');
    set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');
    
    %% Ԥ����

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

    % ��һ��
    B_scan_image_normalize = (B_scan_image-min(min(B_scan_image)))/(max(max(B_scan_image))-min(min(B_scan_image)));
    %% ����������������
    t1=clock;%Start time

    %% The number of groups in Gauss Pyramid
    nOctaves_1=num_octaves(B_scan_image_normalize,is_double_size);

    %% Pyramid first layer image
    B_scan_image_normalize=create_initial_image(B_scan_image_normalize,is_double_size,sigma);

    %%  Gauss Pyramid of Reference image
    tic;
    [gaussian_pyramid_1,gaussian_gradient_1,gaussian_angle_1]=...
    build_gaussian_pyramid(B_scan_image_normalize,nOctaves_1,dog_center_layer,sigma);                                                      
    disp(['�ο�ͼ�񴴽�Gauss Pyramid����ʱ���ǣ�',num2str(toc),'s']);

    %% DOG Pyramid of Reference image
    tic;
    dog_pyramid_1=build_dog_pyramid(gaussian_pyramid_1,nOctaves_1,dog_center_layer);
    disp(['�ο�ͼ�񴴽�DOG Pyramid����ʱ���ǣ�',num2str(toc),'s']);