% 批量处理算法
clear;
clc;
close all;

% 本程序需要时刻注意的地方：参数定义区域，手动选取标签区域，保存路径

%% Define the constants used
root_path = 'D:\硕士文件\SIFT提取\实验结果\抗噪声性能对比\分数无抖动描述符\';% SVM预测结果读取out_file_path = 'E:\PyCharmCommunity\SIFT_SVM\GenerateCylinder_new\testDataset6\out_data4\';% out文件路径
mat_file_path = 'D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\training_data1\';% mat文件路径
lte_path = 'D:\硕士文件\gprMAX相关\实测数据\lte实验数据整合';
DZT_path = 'D:\硕士文件\gprMAX相关\实测数据\桂林部分实验数据整理\桂林部分实验数据整理';
png_path = 'D:\硕士文件\SIFT提取\实验结果\与YOLO对比\仿真数据对比\测试集\test_image_png';
file_mode = "DZT"; %三种文件格式：“lte”，“DZT”，“jpg” 
PCA_path = 'D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\descriptors\target_real\PCA_model.csv';
photo_path = 'D:\硕士文件\SIFT提取\实验结果\扩充训练集之后的实验结果\整合DZT识别结果_RootSIFT\';% 识别图像的输出路径
file_prefix = 'xmbdata_';% 文件开头
begin = 1;% 文件开始读取点
en = 1;% 文件结束读取点
rownum = 128;% 调整后的行尺寸
colnum = 128;% 调整后的列尺寸
sigma=1.6;%最底层高斯金字塔的尺度
dog_center_layer=5;%定义了DOG金字塔每组中间层数，默认是3
contrast_threshold_1=0.03;%Contrast threshold 原版给的是0.03
edge_threshold=10;%Edge threshold
is_double_size=false;%expand image or not
change_form='affine';%change mode,'perspective','affine','similarity'
is_sift_or_log='FE-GLOH-like';%Type of descriptor,it can be 'GLOH-like','SIFT','FE-GLOH-like','RootSIFT','PCA-SIFT'
LOG_POLAR_DESCR_WIDTH=8;
LOG_POLAR_HIST_BINS=8;
SIFT_DESCR_WIDTH=4;   %SIFT特征提取区域，默认4×4区域
SIFT_HIST_BINS=8;     %SIFT特征方向，默认8方向
T_angle=3;    % 距离垂直距离的偏移角度阈值，abs()<T_angle认定为垂直
FS_vector=[16,8,16,1,16,8,16,1]; % 每个角度的特征增强系数，最后一个值是关键点主方向增强系数
Min_dim = 128; % PCA-SIFT才用到，降维后的维度
edge_detect = "on"; % 是否去除边缘效应，on表示去除边缘效应
angleverse = "on"; % 是否暴力翻转主方向角度
contrast = [10,0.1]; % 当关键点数量大于第一个数时，开启去除低幅度点模式，阈值为第二个数

datafiles = dir(fullfile(root_path));

if file_mode == "lte"
    photofiles = dir(fullfile(lte_path, '*.lte'));
elseif file_mode == "DZT"
    photofiles = dir(fullfile(DZT_path, '*.DZT'));
elseif file_mode == "png"
    photofiles = dir(fullfile(png_path, '*.png'));
end
en = size(datafiles,1)-2;

for outid = begin:en
    close all;
    dir_name = datafiles(outid+2).name;
    pred_label_path = strcat(root_path,dir_name,'\pred_',is_sift_or_log,'.csv');
%% 读取文件
    % out仿真文件
    if file_mode == "out"
    fileName = strcat(file_prefix,num2str(outid));
    fileName = strcat(fileName,'_merged.out');
    filePath = strcat(out_file_path,fileName);
    B_scan_image = readB_scan_simlation_data(filePath);
    % 读取某一文件夹下与pred对应的lte文件
    elseif file_mode == "lte"
    lte_name = strcat(dir_name,'.lte');
    [TrackInterval,dt,B_scan_image] = read_multi_B_scan(lte_path,lte_name);
    % 读取mat文件
    elseif file_mode == "mat"
%     files = dir(fullfile(mat_file_path, '*.mat')); % 直接搜索.mat文件
    photofiles = 'training_data_';
    filename = strcat(photofiles,num2str(outid),'.mat');
    filepath = strcat(mat_file_path,filename);
    data = load(filepath);
    B_scan_image = data.Cutimg;   
   % 读取融合mat文件
%     filepath = 'D:\硕士文件\gprMAX相关\实测数据\2023年12月数据\fusion_of_different_freqency\Fusion.mat';
%     data = load(filepath);
%     B_scan_image = data.B;    
    elseif file_mode == "png"
    % 读取某一文件夹下所有的png文件
    file_name = photofiles(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    png_full_path = strcat(png_path,'/',file_name);
    B_scan_png = imread(png_full_path);
    B_scan_image = im2double(B_scan_png(:,:,1));
    % 读取GSSI文件
    elseif file_mode == "DZT"
    
    DZT_name = strcat(dir_name,'.DZT');
    DZT_full_path = strcat(DZT_path,'/',DZT_name);
    [TrackInterval,dt,B_scan_image] = main_gssi(DZT_full_path);
    TrackInterval = TrackInterval*0.01;% 由于返回的是cm，因此乘0.01
    time = (0:size(B_scan_image,1)-1)*dt;
    track = (1:size(B_scan_image,2))*TrackInterval; 
    end

    % 归一化
    B_scan_image = (B_scan_image-min(min(B_scan_image)))/(max(max(B_scan_image))-min(min(B_scan_image)));
    %% 生成特征描述向量
    t1=clock;%Start time

    %% The number of groups in Gauss Pyramid
    nOctaves_1=num_octaves(B_scan_image,is_double_size);

    %% Pyramid first layer image
    B_scan_image=create_initial_image(B_scan_image,is_double_size,sigma);

    %%  Gauss Pyramid of Reference image
    tic;
    [gaussian_pyramid_1,gaussian_gradient_1,gaussian_angle_1]=...
    build_gaussian_pyramid(B_scan_image,nOctaves_1,dog_center_layer,sigma);                                                      
    disp(['参考图像创建Gauss Pyramid花费时间是：',num2str(toc),'s']);

    %% DOG Pyramid of Reference image
    tic;
    dog_pyramid_1=build_dog_pyramid(gaussian_pyramid_1,nOctaves_1,dog_center_layer);
    disp(['参考图像创建DOG Pyramid花费时间是：',num2str(toc),'s']);

    %% Reference image DOG Pyramid extreme point detection
    tic;
    [key_point_array_1]=find_scale_space_extream...
    (dog_pyramid_1,nOctaves_1,dog_center_layer,contrast_threshold_1,sigma,...
    edge_threshold,gaussian_gradient_1,gaussian_angle_1,edge_detect);
    disp(['参考图像关键点定位花费时间是：',num2str(toc),'s']);
    clear dog_pyramid_1;

    %% 是否仅选取向上/向下梯度关键点
    Vernum = 0;
    temp_key_point_array = struct('x',{},'y',{},'octaves',{},'layer',{},...
     'xi',{},'size',{},'angle',{},'gradient',{});
    for i = 1:size(key_point_array_1,2)
        if abs(key_point_array_1(i).angle-90)<T_angle
            Vernum = Vernum+1;
            if angleverse == "on"
                key_point_array_1(i).angle = key_point_array_1(i).angle+180;
            end
            temp_key_point_array(Vernum)=key_point_array_1(i);
        elseif abs(key_point_array_1(i).angle-270)<T_angle
            Vernum = Vernum+1;
            temp_key_point_array(Vernum)=key_point_array_1(i);
        end
    end
    key_point_array_1 = temp_key_point_array;
    
    %% 筛选小幅度数据
    if size(key_point_array_1,2)>contrast(1,1)
    Vernum = 0;
    temp_key_point_array = struct('x',{},'y',{},'octaves',{},'layer',{},...
     'xi',{},'size',{},'angle',{},'gradient',{});
    me = mean(B_scan_image(:));
        for i = 1:size(key_point_array_1,2)
            x = round(key_point_array_1(i).x);
            y = round(key_point_array_1(i).y);
            if abs(B_scan_image(y,x)-me)>contrast(1,2)
                Vernum = Vernum+1;
                temp_key_point_array(Vernum)=key_point_array_1(i);
            end
        end
    key_point_array_1 = temp_key_point_array;        
    end
    if isempty(key_point_array_1)
        continue
    end
    %% descriptor generation of the reference image 
    tic;
    [descriptors_1,nex_descriptors_1,locs_1]=calc_descriptors(gaussian_gradient_1,gaussian_angle_1,...
                                    key_point_array_1,nOctaves_1,is_double_size,is_sift_or_log,...
                                    LOG_POLAR_DESCR_WIDTH,LOG_POLAR_HIST_BINS,...
                                    SIFT_DESCR_WIDTH,SIFT_HIST_BINS,FS_vector,PCA_path);
    disp(['参考图像描述符生成花费时间是：',num2str(toc),'s']); 
    clear gaussian_gradient_1;
    clear gaussian_angle_1;
    
    %% test the accurancy of SVM(after the test in python)
    pred_result=csvread(pred_label_path);
    show_target_loc(B_scan_image,locs_1,pred_result);
    
    %% 上下合并,显示最终识别结果
    show_detect_target(B_scan_image,key_point_array_1,pred_result,dir_name,photo_path);
end