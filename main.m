% 单文件处理算法
clear;
clc;
close all;

% 本程序需要时刻注意的地方：参数定义区域，读取文件类型区域，手动选取标签区域

%% Define the constants used
out_file_path = 'E:\PyCharmCommunity\SIFT_SVM\GenerateCylinder_new\testDataset6\out_data4\';% out文件路径
mat_file_path = 'D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\training_data1\';% mat文件路径
output_path = 'D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\descriptors\target_real\';
GSSI_path = 'D:\硕士文件\gprMAX相关\实测数据\桂林部分实验数据整理\桂林部分实验数据整理\';
GSSI_name = 'PROJ2__001.DZT';
lte_path = 'D:\硕士文件\gprMAX相关\实测数据\lte实验数据整合';
DAT_path = 'E:\Reflexw\REFLEX64Bit\ROHDATA\________.DAT';
file_prefix = 'xmbdata_';% 文件开头
sigma=1.6;%最底层高斯金字塔的尺度
dog_center_layer=5;%定义了DOG金字塔每组中间层数，默认是3
is_double_size=false;%expand image or not
change_form='affine';%change mode,'perspective','affine','similarity'

    %% 读取文件
    % out仿真文件
%     fileName = strcat(file_prefix,num2str(outid));
%     fileName = strcat(fileName,'_merged.out');
%     filePath = strcat(out_file_path,fileName);
%     B_scan_image = readB_scan_simlation_data(filePath);

    % 读取ite文件
%     [TrackInterval,dt,B_scan_image,file_name] = readB_scan();
%     file_parts = split(file_name,'.');
%     file_label = file_parts{1};

   % 读取融合mat文件
%     filepath = 'D:\硕士文件\gprMAX相关\实测数据\2023年12月数据\fusion_of_different_freqency\Fusion.mat';
%     data = load(filepath);
%     B_scan_image = data.B;  

    % 读取GSSI文件
    full_GSSI_path = strcat(GSSI_path,GSSI_name);
    [TrackInterval,dt,B_scan_image] = main_gssi(full_GSSI_path);
    TrackInterval = TrackInterval*0.01;% 由于返回的是cm，因此乘0.01
    time = (0:size(B_scan_image,1)-1)*dt;
    track = (1:size(B_scan_image,2))*TrackInterval; 
    file_parts = split(GSSI_name,'.');
    file_label = file_parts{1};

%     % 读取dat文件
%     fid = fopen(DAT_path,'r');       %打开数据文件
%     B_scan_image = fscanf(fid,'%g');                 %读取文件数据
%     file_label = '________';
    % 画图
    figure
    imagesc(B_scan_image);
    colormap('gray');
    xlabel('Trace(m)');ylabel('Time(ns)');
    set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');
    
    %% 预处理

%     % 均值对消
%     for i = 1:size(B_scan_image,1)
%         B_scan_image(i,:) = B_scan_image(i,:)-mean(B_scan_image(i,:));
%     end
%     % 画图
%     figure
%     imagesc(B_scan_image);
%     colormap('gray');
%     xlabel('Trace(m)');ylabel('Time(ns)');
%     set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');

    % 归一化
    B_scan_image_normalize = (B_scan_image-min(min(B_scan_image)))/(max(max(B_scan_image))-min(min(B_scan_image)));
    %% 生成特征描述向量
    t1=clock;%Start time

    %% The number of groups in Gauss Pyramid
    nOctaves_1=num_octaves(B_scan_image_normalize,is_double_size);

    %% Pyramid first layer image
    B_scan_image_normalize=create_initial_image(B_scan_image_normalize,is_double_size,sigma);

    %%  Gauss Pyramid of Reference image
    tic;
    [gaussian_pyramid_1,gaussian_gradient_1,gaussian_angle_1]=...
    build_gaussian_pyramid(B_scan_image_normalize,nOctaves_1,dog_center_layer,sigma);                                                      
    disp(['参考图像创建Gauss Pyramid花费时间是：',num2str(toc),'s']);

    %% DOG Pyramid of Reference image
    tic;
    dog_pyramid_1=build_dog_pyramid(gaussian_pyramid_1,nOctaves_1,dog_center_layer);
    disp(['参考图像创建DOG Pyramid花费时间是：',num2str(toc),'s']);