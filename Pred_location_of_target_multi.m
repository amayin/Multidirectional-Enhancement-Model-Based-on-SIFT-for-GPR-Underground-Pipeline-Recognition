% ���������㷨
clear;
clc;
close all;

% ��������Ҫʱ��ע��ĵط����������������ֶ�ѡȡ��ǩ���򣬱���·��

%% Define the constants used
root_path = 'D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\���������ܶԱ�\�����޶���������\';% SVMԤ������ȡout_file_path = 'E:\PyCharmCommunity\SIFT_SVM\GenerateCylinder_new\testDataset6\out_data4\';% out�ļ�·��
mat_file_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\SIFT_extract_in_GPR\training_data1\';% mat�ļ�·��
lte_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\lteʵ����������';
DZT_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\���ֲ���ʵ����������\���ֲ���ʵ����������';
png_path = 'D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\��YOLO�Ա�\�������ݶԱ�\���Լ�\test_image_png';
file_mode = "DZT"; %�����ļ���ʽ����lte������DZT������jpg�� 
PCA_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\SIFT_extract_in_GPR\descriptors\target_real\PCA_model.csv';
photo_path = 'D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\����ѵ����֮���ʵ����\����DZTʶ����_RootSIFT\';% ʶ��ͼ������·��
file_prefix = 'xmbdata_';% �ļ���ͷ
begin = 1;% �ļ���ʼ��ȡ��
en = 1;% �ļ�������ȡ��
rownum = 128;% ��������гߴ�
colnum = 128;% ��������гߴ�
sigma=1.6;%��ײ��˹�������ĳ߶�
dog_center_layer=5;%������DOG������ÿ���м������Ĭ����3
contrast_threshold_1=0.03;%Contrast threshold ԭ�������0.03
edge_threshold=10;%Edge threshold
is_double_size=false;%expand image or not
change_form='affine';%change mode,'perspective','affine','similarity'
is_sift_or_log='FE-GLOH-like';%Type of descriptor,it can be 'GLOH-like','SIFT','FE-GLOH-like','RootSIFT','PCA-SIFT'
LOG_POLAR_DESCR_WIDTH=8;
LOG_POLAR_HIST_BINS=8;
SIFT_DESCR_WIDTH=4;   %SIFT������ȡ����Ĭ��4��4����
SIFT_HIST_BINS=8;     %SIFT��������Ĭ��8����
T_angle=3;    % ���봹ֱ�����ƫ�ƽǶ���ֵ��abs()<T_angle�϶�Ϊ��ֱ
FS_vector=[16,8,16,1,16,8,16,1]; % ÿ���Ƕȵ�������ǿϵ�������һ��ֵ�ǹؼ�����������ǿϵ��
Min_dim = 128; % PCA-SIFT���õ�����ά���ά��
edge_detect = "on"; % �Ƿ�ȥ����ԵЧӦ��on��ʾȥ����ԵЧӦ
angleverse = "on"; % �Ƿ�����ת������Ƕ�
contrast = [10,0.1]; % ���ؼ����������ڵ�һ����ʱ������ȥ���ͷ��ȵ�ģʽ����ֵΪ�ڶ�����

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
%% ��ȡ�ļ�
    % out�����ļ�
    if file_mode == "out"
    fileName = strcat(file_prefix,num2str(outid));
    fileName = strcat(fileName,'_merged.out');
    filePath = strcat(out_file_path,fileName);
    B_scan_image = readB_scan_simlation_data(filePath);
    % ��ȡĳһ�ļ�������pred��Ӧ��lte�ļ�
    elseif file_mode == "lte"
    lte_name = strcat(dir_name,'.lte');
    [TrackInterval,dt,B_scan_image] = read_multi_B_scan(lte_path,lte_name);
    % ��ȡmat�ļ�
    elseif file_mode == "mat"
%     files = dir(fullfile(mat_file_path, '*.mat')); % ֱ������.mat�ļ�
    photofiles = 'training_data_';
    filename = strcat(photofiles,num2str(outid),'.mat');
    filepath = strcat(mat_file_path,filename);
    data = load(filepath);
    B_scan_image = data.Cutimg;   
   % ��ȡ�ں�mat�ļ�
%     filepath = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\2023��12������\fusion_of_different_freqency\Fusion.mat';
%     data = load(filepath);
%     B_scan_image = data.B;    
    elseif file_mode == "png"
    % ��ȡĳһ�ļ��������е�png�ļ�
    file_name = photofiles(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    png_full_path = strcat(png_path,'/',file_name);
    B_scan_png = imread(png_full_path);
    B_scan_image = im2double(B_scan_png(:,:,1));
    % ��ȡGSSI�ļ�
    elseif file_mode == "DZT"
    
    DZT_name = strcat(dir_name,'.DZT');
    DZT_full_path = strcat(DZT_path,'/',DZT_name);
    [TrackInterval,dt,B_scan_image] = main_gssi(DZT_full_path);
    TrackInterval = TrackInterval*0.01;% ���ڷ��ص���cm����˳�0.01
    time = (0:size(B_scan_image,1)-1)*dt;
    track = (1:size(B_scan_image,2))*TrackInterval; 
    end

    % ��һ��
    B_scan_image = (B_scan_image-min(min(B_scan_image)))/(max(max(B_scan_image))-min(min(B_scan_image)));
    %% ����������������
    t1=clock;%Start time

    %% The number of groups in Gauss Pyramid
    nOctaves_1=num_octaves(B_scan_image,is_double_size);

    %% Pyramid first layer image
    B_scan_image=create_initial_image(B_scan_image,is_double_size,sigma);

    %%  Gauss Pyramid of Reference image
    tic;
    [gaussian_pyramid_1,gaussian_gradient_1,gaussian_angle_1]=...
    build_gaussian_pyramid(B_scan_image,nOctaves_1,dog_center_layer,sigma);                                                      
    disp(['�ο�ͼ�񴴽�Gauss Pyramid����ʱ���ǣ�',num2str(toc),'s']);

    %% DOG Pyramid of Reference image
    tic;
    dog_pyramid_1=build_dog_pyramid(gaussian_pyramid_1,nOctaves_1,dog_center_layer);
    disp(['�ο�ͼ�񴴽�DOG Pyramid����ʱ���ǣ�',num2str(toc),'s']);

    %% Reference image DOG Pyramid extreme point detection
    tic;
    [key_point_array_1]=find_scale_space_extream...
    (dog_pyramid_1,nOctaves_1,dog_center_layer,contrast_threshold_1,sigma,...
    edge_threshold,gaussian_gradient_1,gaussian_angle_1,edge_detect);
    disp(['�ο�ͼ��ؼ��㶨λ����ʱ���ǣ�',num2str(toc),'s']);
    clear dog_pyramid_1;

    %% �Ƿ��ѡȡ����/�����ݶȹؼ���
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
    
    %% ɸѡС��������
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
    disp(['�ο�ͼ�����������ɻ���ʱ���ǣ�',num2str(toc),'s']); 
    clear gaussian_gradient_1;
    clear gaussian_angle_1;
    
    %% test the accurancy of SVM(after the test in python)
    pred_result=csvread(pred_label_path);
    show_target_loc(B_scan_image,locs_1,pred_result);
    
    %% ���ºϲ�,��ʾ����ʶ����
    show_detect_target(B_scan_image,key_point_array_1,pred_result,dir_name,photo_path);
end