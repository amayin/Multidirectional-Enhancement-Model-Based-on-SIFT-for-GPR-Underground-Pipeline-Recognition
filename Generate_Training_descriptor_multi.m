% 批量处理算法
clear;
clc;
close all;

% 本程序需要时刻注意的地方：参数定义区域，手动选取标签区域

%% Define the constants used
out_file_path = '\input\your\path\';% out文件路径
mat_file_path = '\input\your\path\';% mat文件路径
DZT_path = '\input\your\path';% DZT文件路径
lte_path = '\input\your\path';% lte文件路径
png_path = '\input\your\path';
output_path = '\input\your\path\';% 特征描述符输出路径
file_mode = "mat"; %两种文件格式：“lte”，“DZT”，“png”
PCA_path = 'D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\descriptors\target_real\PCA_model.csv';
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
is_sift_or_log='FE-GLOH-like';%Type of descriptor,it can be 'GLOH-like','SIFT','PCA-SIFT','MS-SIFT','FE-GLOH-like','RootSIFT'
LOG_POLAR_DESCR_WIDTH=8;
LOG_POLAR_HIST_BINS=8;
SIFT_DESCR_WIDTH=4;   %SIFT特征提取区域，默认4×4区域
SIFT_HIST_BINS=8;     %SIFT特征方向，默认8方向
T_angle=3;    % 距离垂直距离的偏移角度阈值，abs()<T_angle认定为垂直
FS_vector=[2,1,2,1,2,1,2,1]; % 每个角度的特征增强系数，最后一个值是关键点主方向增强系数
Min_dim = 128; % PCA-SIFT才用到，降维后的维度
edge_detect = "on"; % 是否去除边缘效应，on表示去除边缘效应
angleverse = "on"; % 是否暴力翻转主方向角度
T_symmetry = 1.2;
contrast = [10,0.1]; % 当关键点数量大于第一个数时，开启去除低幅度点模式，阈值为第二个数

if file_mode == "lte"
    files = dir(fullfile(lte_path, '*.lte'));
elseif file_mode == "DZT"
    files = dir(fullfile(DZT_path, '*.DZT'));
elseif file_mode == "png"
    files = dir(fullfile(png_path, '*.png'));
elseif file_mode == "mat"
    files = dir(fullfile(mat_file_path, '*.mat'));
end

en = size(files,1);
for outid = begin:en
    close all;
    disp(['----------------开始生成第',num2str(outid),'个文件的描述符----------------']);
    %% 读取文件
if file_mode == "out"
    % out仿真文件
    fileName = strcat(file_prefix,num2str(outid));
    fileName = strcat(fileName,'_merged.out');
    filePath = strcat(out_file_path,fileName);
    B_scan_image = readB_scan_simlation_data(filePath);
elseif file_mode == "lte"
    % 读取某一文件夹下所有的lte文件
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    [TrackInterval,dt,B_scan_image] = read_multi_B_scan(lte_path,file_name);
elseif file_mode == "png"
    % 读取某一文件夹下所有的png文件
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    png_full_path = strcat(png_path,'/',file_name);
    B_scan_png = imread(png_full_path);
    B_scan_image = im2double(B_scan_png(:,:,1));
elseif file_mode == "mat"
    % 读取训练mat文件
%     files = dir(fullfile(mat_file_path, '*.mat')); % 直接搜索.mat文件
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    filepath = strcat(mat_file_path,file_name);
    data = load(filepath);
    B_scan_image = data.matrix;    
    B_scan_image = B_scan_image';
   % 读取融合mat文件
%     filepath = 'D:\硕士文件\gprMAX相关\实测数据\2023年12月数据\fusion_of_different_freqency\Fusion.mat';
%     data = load(filepath);
%     B_scan_image = data.B;    
elseif file_mode == "DZT"
    % 读取DZT文件 
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    DZT_full_path = strcat(DZT_path,'/',file_name);
    [TrackInterval,dt,B_scan_image] = main_gssi(DZT_full_path);
    TrackInterval = TrackInterval*0.01;% 由于返回的是cm，因此乘0.01
    time = (0:size(B_scan_image,1)-1)*dt;
    track = (1:size(B_scan_image,2))*TrackInterval; 
end
    % 画图
    figure
    imagesc(B_scan_image);
    colormap('gray');
    xlabel('Trace(m)');ylabel('Time(ns)');
    set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');
    
    %% 预处理
    % 低秩稀疏分解去直达波
    % addpath('D:\硕士文件\gprMAX相关\实测数据\RPCA_With_TV')
    % addpath('D:\硕士文件\gprMAX相关\实测数据\RPCA_With_TV\read_data');  
    % addpath('D:\硕士文件\gprMAX相关\实测数据\RPCA_With_TV\prox_operator');  
    % addpath('D:\硕士文件\gprMAX相关\实测数据\RPCA_With_TV\calutate');
    % addpath('D:\硕士文件\gprMAX相关\实测数据\RPCA_With_TV\utils')
%     lambda = 0.01;beta = 0.03;
%     n_iters_ADMM=500;n_iters_TV=100;
%     [X,runtime] = LRS_TV_InALM(B_scan_image,lambda,beta,n_iters_ADMM,n_iters_TV);
%     B_scan_image_sparse = X.S;

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

    %% display the Gauss Pyramid,DOG Pyramid,gradient of Reference image
%     display_product_image(gaussian_pyramid_1,dog_pyramid_1,gaussian_gradient_1,...
%             gaussian_angle_1,nOctaves_1,dog_center_layer,'Reference image');                              
%      clear gaussian_pyramid_1;

    %% Reference image DOG Pyramid extreme point detection
    tic;
    [key_point_array_1]=find_scale_space_extream...
    (dog_pyramid_1,nOctaves_1,dog_center_layer,contrast_threshold_1,sigma,...
    edge_threshold,gaussian_gradient_1,gaussian_angle_1,edge_detect);
    disp(['参考图像关键点定位花费时间是：',num2str(toc),'s']);
%     clear dog_pyramid_1;
    
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
    me = mean(B_scan_image_normalize(:));
        for i = 1:size(key_point_array_1,2)
            x = round(key_point_array_1(i).x);
            y = round(key_point_array_1(i).y);
            if abs(B_scan_image_normalize(y,x)-me)>contrast(1,2)
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
%     clear gaussian_gradient_1;
%     clear gaussian_angle_1;
    
    %% 根据对称性筛选双曲线
    [now_flag,now_locs_1,now_smy] = screen_point_by_symmery(descriptors_1,locs_1,LOG_POLAR_HIST_BINS,SIFT_HIST_BINS,T_symmetry,is_sift_or_log);
    [nex_flag,nex_locs_1,nex_smy] = screen_point_by_symmery(nex_descriptors_1,locs_1,LOG_POLAR_HIST_BINS,SIFT_HIST_BINS,T_symmetry,is_sift_or_log);

    %% Display the detect points
    [button1]=showpoint_detected_in_singleimage(B_scan_image_normalize,now_locs_1);
    dir_save_im1=['.\save_image2\',file_label];
    if ~exist(dir_save_im1, 'dir')
        % 文件夹不存在，创建文件夹
        mkdir(dir_save_im1);
    end
    save_im1 = [dir_save_im1,'\The detection point in now octave.jpg'];
    saveas(button1,save_im1,'jpg');
    
    [button2]=showpoint_detected_in_singleimage(B_scan_image_normalize,nex_locs_1);
    dir_save_im2=['.\save_image2\',file_label];
    if ~exist(dir_save_im2, 'dir')
        % 文件夹不存在，创建文件夹
        mkdir(dir_save_im2);
    end
    save_im2 = [dir_save_im2,'\The detection point in next octave.jpg'];
    saveas(button2,save_im2,'jpg');
    
    [button3]=showpoint_detected_in_singleimage(B_scan_image_normalize,locs_1);
    dir_save_im3=['.\save_image2\',file_label];
    if ~exist(dir_save_im3, 'dir')
        % 文件夹不存在，创建文件夹
        mkdir(dir_save_im3);
    end
    save_im3 = [dir_save_im3,'\Reference image detection point.jpg'];
    saveas(button3,save_im3,'jpg');
    
    [button4]=disp_points_distribute(locs_1,nOctaves_1,dog_center_layer);
    %% 针对实测数据的手动选取标签
% 2023年12月18日427.lte用这个
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,2)>=72 && locs_1(i,2)<76 && locs_1(i,1)>=190 && locs_1(i,1)<250
%             label(i,:)=1;
%         end
%     end        
% data3/410lte用这个
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,2)>=50 && locs_1(i,2)<60
%             label(i,:)=1;
%         end
%     end    
% 2023年12月12日383.lte用这个
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,1)>=150 && locs_1(i,1)<180 && locs_1(i,2)<25
%             label(i,:)=1;
%         end
%     end
% 2023年12月15日121.DZT,122.DZT用这个
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,1)>=250
%             label(i,:)=1;
%         end
%     end
% 桂林数据用下面这个
    label = zeros(size(locs_1,1),1);
    for i = 1:size(descriptors_1,1)
        if locs_1(i,1)>=140 && locs_1(i,2)>1200 && locs_1(i,2)<2000
            label(i,:)=1;
            if locs_1(i,1)<200 && locs_1(i,2)>1700
                label(i,:)=0;
            end
        end
    end
% 370.ite 用下面这个
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,1)>=150
%             label(i,:)=1;
%         end
%     end
% 12月22日路面数据用这个
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,1)>=340 && locs_1(i,1)<550
%             label(i,:)=1;
%         end
%     end
    %% Save the data with csv
    % 保存对称性判别flag
    % 设置你想要创建的文件夹名称
    flagfolderName = strcat(output_path,file_label,'\flag_',is_sift_or_log);
    % 检查文件夹是否已经存在
    if ~exist(flagfolderName, 'dir')
        % 文件夹不存在，创建文件夹
        mkdir(flagfolderName);
        disp(['文件夹 "' flagfolderName '" 已创建.']);
    else
        % 文件夹已存在
        disp(['文件夹 "' flagfolderName '" 已存在.']);
    end
    labtit=strcat(flagfolderName,'\now_flag_',num2str(outid),'.csv');% 顺序名称
    [time] = save_csv(now_flag,labtit);
    disp(['保存对称性标志花费时间是：',num2str(time),'s']);
    labtit=strcat(flagfolderName,'\nex_flag_',num2str(outid),'.csv');% 顺序名称
    [time] = save_csv(nex_flag,labtit);
    disp(['保存对称性标志花费时间是：',num2str(time),'s']);
    
    % 保存label
    labelfolderName = strcat(output_path,file_label,'\label_',is_sift_or_log);
    % 检查文件夹是否已经存在
    if ~exist(labelfolderName, 'dir')
        % 文件夹不存在，创建文件夹
        mkdir(labelfolderName);
        disp(['文件夹 "' labelfolderName '" 已创建.']);
    else
        % 文件夹已存在
        disp(['文件夹 "' labelfolderName '" 已存在.']);
    end
    labtit=strcat(labelfolderName,'\label_',num2str(outid),'.csv');% 顺序名称
    [time] = save_csv(label,labtit);
    disp(['保存标签花费时间是：',num2str(time),'s']);

    % 保存descriptor
    datafolderName = strcat(output_path,file_label,'\data_',is_sift_or_log);
    % 检查文件夹是否已经存在
    if ~exist(datafolderName, 'dir')
        % 文件夹不存在，创建文件夹
        mkdir(datafolderName);
        disp(['文件夹 "' datafolderName '" 已创建.']);
    else
        % 文件夹已存在
        disp(['文件夹 "' datafolderName '" 已存在.']);
    end
    destit=strcat(datafolderName,'\now_descriptor_',num2str(outid),'.csv');% 顺序名称
    [time] = save_csv(descriptors_1,destit);
    disp(['保存特征描述符花费时间是：',num2str(time),'s']);
    desnextit=strcat(datafolderName,'\nex_descriptor_',num2str(outid),'.csv');% 顺序名称
    [time] = save_csv(nex_descriptors_1,desnextit);
    disp(['保存特征描述符花费时间是：',num2str(time),'s']);
    
    % 保存loc
    locfolderName = strcat(output_path,file_label,'\loc_',is_sift_or_log);
    % 检查文件夹是否已经存在
    if ~exist(locfolderName, 'dir')
        % 文件夹不存在，创建文件夹
        mkdir(locfolderName);
        disp(['文件夹 "' locfolderName '" 已创建.']);
    else
        % 文件夹已存在
        disp(['文件夹 "' locfolderName '" 已存在.']);
    end
    loctit=strcat(locfolderName,'\loc_',num2str(outid),'.csv');% 顺序名称
    [time] = save_csv(locs_1,loctit);
    disp(['保存特征描述符花费时间是：',num2str(time),'s']);

    % 保存keypoint
    keypointfolderName = strcat(output_path,file_label,'\keypoint_',is_sift_or_log);
    % 检查文件夹是否已经存在
    if ~exist(keypointfolderName, 'dir')
        % 文件夹不存在，创建文件夹
        mkdir(keypointfolderName);
        disp(['文件夹 "' keypointfolderName '" 已创建.']);
    else
        % 文件夹已存在
        disp(['文件夹 "' keypointfolderName '" 已存在.']);
    end
    keypointtit=strcat(keypointfolderName,'\keypoint_',num2str(outid),'.mat');% 顺序名称
    save(keypointtit,'key_point_array_1');
    disp(['保存特征描述符花费时间是：',num2str(time),'s']);    
end

