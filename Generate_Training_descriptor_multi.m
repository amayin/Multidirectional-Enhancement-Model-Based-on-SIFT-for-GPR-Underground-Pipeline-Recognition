% ���������㷨
clear;
clc;
close all;

% ��������Ҫʱ��ע��ĵط����������������ֶ�ѡȡ��ǩ����

%% Define the constants used
out_file_path = 'E:\PyCharmCommunity\SIFT_SVM\GenerateCylinder_new\testDataset6\out_data4\';% out�ļ�·��
mat_file_path = 'C:\Users\chen2\OneDrive\Desktop\�½��ļ���\mat\';% mat�ļ�·��
DZT_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\DZTʵ����������';% DZT�ļ�·��
lte_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\lte������������';% lte�ļ�·��
png_path = 'D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\��YOLO�Ա�\�������ݶԱ�\���Լ�\test_image_png';
output_path = 'D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\����ѵ����֮���ʵ����\����DZT����������_RootSIFT\';% �������������·��
file_mode = "mat"; %�����ļ���ʽ����lte������DZT������png��
PCA_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\SIFT_extract_in_GPR\descriptors\target_real\PCA_model.csv';
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
is_sift_or_log='FE-GLOH-like';%Type of descriptor,it can be 'GLOH-like','SIFT','PCA-SIFT','MS-SIFT','FE-GLOH-like','RootSIFT'
LOG_POLAR_DESCR_WIDTH=8;
LOG_POLAR_HIST_BINS=8;
SIFT_DESCR_WIDTH=4;   %SIFT������ȡ����Ĭ��4��4����
SIFT_HIST_BINS=8;     %SIFT��������Ĭ��8����
T_angle=3;    % ���봹ֱ�����ƫ�ƽǶ���ֵ��abs()<T_angle�϶�Ϊ��ֱ
FS_vector=[2,1,2,1,2,1,2,1]; % ÿ���Ƕȵ�������ǿϵ�������һ��ֵ�ǹؼ�����������ǿϵ��
Min_dim = 128; % PCA-SIFT���õ�����ά���ά��
edge_detect = "on"; % �Ƿ�ȥ����ԵЧӦ��on��ʾȥ����ԵЧӦ
angleverse = "on"; % �Ƿ�����ת������Ƕ�
T_symmetry = 1.2;
contrast = [10,0.1]; % ���ؼ����������ڵ�һ����ʱ������ȥ���ͷ��ȵ�ģʽ����ֵΪ�ڶ�����

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
    disp(['----------------��ʼ���ɵ�',num2str(outid),'���ļ���������----------------']);
    %% ��ȡ�ļ�
if file_mode == "out"
    % out�����ļ�
    fileName = strcat(file_prefix,num2str(outid));
    fileName = strcat(fileName,'_merged.out');
    filePath = strcat(out_file_path,fileName);
    B_scan_image = readB_scan_simlation_data(filePath);
elseif file_mode == "lte"
    % ��ȡĳһ�ļ��������е�lte�ļ�
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    [TrackInterval,dt,B_scan_image] = read_multi_B_scan(lte_path,file_name);
elseif file_mode == "png"
    % ��ȡĳһ�ļ��������е�png�ļ�
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    png_full_path = strcat(png_path,'/',file_name);
    B_scan_png = imread(png_full_path);
    B_scan_image = im2double(B_scan_png(:,:,1));
elseif file_mode == "mat"
    % ��ȡѵ��mat�ļ�
%     files = dir(fullfile(mat_file_path, '*.mat')); % ֱ������.mat�ļ�
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    filepath = strcat(mat_file_path,file_name);
    data = load(filepath);
    B_scan_image = data.matrix;    
    B_scan_image = B_scan_image';
   % ��ȡ�ں�mat�ļ�
%     filepath = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\2023��12������\fusion_of_different_freqency\Fusion.mat';
%     data = load(filepath);
%     B_scan_image = data.B;    
elseif file_mode == "DZT"
    % ��ȡDZT�ļ� 
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    DZT_full_path = strcat(DZT_path,'/',file_name);
    [TrackInterval,dt,B_scan_image] = main_gssi(DZT_full_path);
    TrackInterval = TrackInterval*0.01;% ���ڷ��ص���cm����˳�0.01
    time = (0:size(B_scan_image,1)-1)*dt;
    track = (1:size(B_scan_image,2))*TrackInterval; 
end
    % ��ͼ
    figure
    imagesc(B_scan_image);
    colormap('gray');
    xlabel('Trace(m)');ylabel('Time(ns)');
    set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');
    
    %% Ԥ����
    % ����ϡ��ֽ�ȥֱ�ﲨ
    % addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV')
    % addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV\read_data');  
    % addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV\prox_operator');  
    % addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV\calutate');
    % addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV\utils')
%     lambda = 0.01;beta = 0.03;
%     n_iters_ADMM=500;n_iters_TV=100;
%     [X,runtime] = LRS_TV_InALM(B_scan_image,lambda,beta,n_iters_ADMM,n_iters_TV);
%     B_scan_image_sparse = X.S;

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

    %% display the Gauss Pyramid,DOG Pyramid,gradient of Reference image
%     display_product_image(gaussian_pyramid_1,dog_pyramid_1,gaussian_gradient_1,...
%             gaussian_angle_1,nOctaves_1,dog_center_layer,'Reference image');                              
%      clear gaussian_pyramid_1;

    %% Reference image DOG Pyramid extreme point detection
    tic;
    [key_point_array_1]=find_scale_space_extream...
    (dog_pyramid_1,nOctaves_1,dog_center_layer,contrast_threshold_1,sigma,...
    edge_threshold,gaussian_gradient_1,gaussian_angle_1,edge_detect);
    disp(['�ο�ͼ��ؼ��㶨λ����ʱ���ǣ�',num2str(toc),'s']);
%     clear dog_pyramid_1;
    
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
    disp(['�ο�ͼ�����������ɻ���ʱ���ǣ�',num2str(toc),'s']); 
%     clear gaussian_gradient_1;
%     clear gaussian_angle_1;
    
    %% ���ݶԳ���ɸѡ˫����
    [now_flag,now_locs_1,now_smy] = screen_point_by_symmery(descriptors_1,locs_1,LOG_POLAR_HIST_BINS,SIFT_HIST_BINS,T_symmetry,is_sift_or_log);
    [nex_flag,nex_locs_1,nex_smy] = screen_point_by_symmery(nex_descriptors_1,locs_1,LOG_POLAR_HIST_BINS,SIFT_HIST_BINS,T_symmetry,is_sift_or_log);

    %% Display the detect points
    [button1]=showpoint_detected_in_singleimage(B_scan_image_normalize,now_locs_1);
    dir_save_im1=['.\save_image2\',file_label];
    if ~exist(dir_save_im1, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(dir_save_im1);
    end
    save_im1 = [dir_save_im1,'\The detection point in now octave.jpg'];
    saveas(button1,save_im1,'jpg');
    
    [button2]=showpoint_detected_in_singleimage(B_scan_image_normalize,nex_locs_1);
    dir_save_im2=['.\save_image2\',file_label];
    if ~exist(dir_save_im2, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(dir_save_im2);
    end
    save_im2 = [dir_save_im2,'\The detection point in next octave.jpg'];
    saveas(button2,save_im2,'jpg');
    
    [button3]=showpoint_detected_in_singleimage(B_scan_image_normalize,locs_1);
    dir_save_im3=['.\save_image2\',file_label];
    if ~exist(dir_save_im3, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(dir_save_im3);
    end
    save_im3 = [dir_save_im3,'\Reference image detection point.jpg'];
    saveas(button3,save_im3,'jpg');
    
    [button4]=disp_points_distribute(locs_1,nOctaves_1,dog_center_layer);
    %% ���ʵ�����ݵ��ֶ�ѡȡ��ǩ
% 2023��12��18��427.lte�����
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,2)>=72 && locs_1(i,2)<76 && locs_1(i,1)>=190 && locs_1(i,1)<250
%             label(i,:)=1;
%         end
%     end        
% data3/410lte�����
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,2)>=50 && locs_1(i,2)<60
%             label(i,:)=1;
%         end
%     end    
% 2023��12��12��383.lte�����
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,1)>=150 && locs_1(i,1)<180 && locs_1(i,2)<25
%             label(i,:)=1;
%         end
%     end
% 2023��12��15��121.DZT,122.DZT�����
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,1)>=250
%             label(i,:)=1;
%         end
%     end
% �����������������
    label = zeros(size(locs_1,1),1);
    for i = 1:size(descriptors_1,1)
        if locs_1(i,1)>=140 && locs_1(i,2)>1200 && locs_1(i,2)<2000
            label(i,:)=1;
            if locs_1(i,1)<200 && locs_1(i,2)>1700
                label(i,:)=0;
            end
        end
    end
% 370.ite ���������
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,1)>=150
%             label(i,:)=1;
%         end
%     end
% 12��22��·�����������
%     label = zeros(size(locs_1,1),1);
%     for i = 1:size(descriptors_1,1)
%         if locs_1(i,1)>=340 && locs_1(i,1)<550
%             label(i,:)=1;
%         end
%     end
    %% Save the data with csv
    % ����Գ����б�flag
    % ��������Ҫ�������ļ�������
    flagfolderName = strcat(output_path,file_label,'\flag_',is_sift_or_log);
    % ����ļ����Ƿ��Ѿ�����
    if ~exist(flagfolderName, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(flagfolderName);
        disp(['�ļ��� "' flagfolderName '" �Ѵ���.']);
    else
        % �ļ����Ѵ���
        disp(['�ļ��� "' flagfolderName '" �Ѵ���.']);
    end
    labtit=strcat(flagfolderName,'\now_flag_',num2str(outid),'.csv');% ˳������
    [time] = save_csv(now_flag,labtit);
    disp(['����Գ��Ա�־����ʱ���ǣ�',num2str(time),'s']);
    labtit=strcat(flagfolderName,'\nex_flag_',num2str(outid),'.csv');% ˳������
    [time] = save_csv(nex_flag,labtit);
    disp(['����Գ��Ա�־����ʱ���ǣ�',num2str(time),'s']);
    
    % ����label
    labelfolderName = strcat(output_path,file_label,'\label_',is_sift_or_log);
    % ����ļ����Ƿ��Ѿ�����
    if ~exist(labelfolderName, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(labelfolderName);
        disp(['�ļ��� "' labelfolderName '" �Ѵ���.']);
    else
        % �ļ����Ѵ���
        disp(['�ļ��� "' labelfolderName '" �Ѵ���.']);
    end
    labtit=strcat(labelfolderName,'\label_',num2str(outid),'.csv');% ˳������
    [time] = save_csv(label,labtit);
    disp(['�����ǩ����ʱ���ǣ�',num2str(time),'s']);

    % ����descriptor
    datafolderName = strcat(output_path,file_label,'\data_',is_sift_or_log);
    % ����ļ����Ƿ��Ѿ�����
    if ~exist(datafolderName, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(datafolderName);
        disp(['�ļ��� "' datafolderName '" �Ѵ���.']);
    else
        % �ļ����Ѵ���
        disp(['�ļ��� "' datafolderName '" �Ѵ���.']);
    end
    destit=strcat(datafolderName,'\now_descriptor_',num2str(outid),'.csv');% ˳������
    [time] = save_csv(descriptors_1,destit);
    disp(['������������������ʱ���ǣ�',num2str(time),'s']);
    desnextit=strcat(datafolderName,'\nex_descriptor_',num2str(outid),'.csv');% ˳������
    [time] = save_csv(nex_descriptors_1,desnextit);
    disp(['������������������ʱ���ǣ�',num2str(time),'s']);
    
    % ����loc
    locfolderName = strcat(output_path,file_label,'\loc_',is_sift_or_log);
    % ����ļ����Ƿ��Ѿ�����
    if ~exist(locfolderName, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(locfolderName);
        disp(['�ļ��� "' locfolderName '" �Ѵ���.']);
    else
        % �ļ����Ѵ���
        disp(['�ļ��� "' locfolderName '" �Ѵ���.']);
    end
    loctit=strcat(locfolderName,'\loc_',num2str(outid),'.csv');% ˳������
    [time] = save_csv(locs_1,loctit);
    disp(['������������������ʱ���ǣ�',num2str(time),'s']);

    % ����keypoint
    keypointfolderName = strcat(output_path,file_label,'\keypoint_',is_sift_or_log);
    % ����ļ����Ƿ��Ѿ�����
    if ~exist(keypointfolderName, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(keypointfolderName);
        disp(['�ļ��� "' keypointfolderName '" �Ѵ���.']);
    else
        % �ļ����Ѵ���
        disp(['�ļ��� "' keypointfolderName '" �Ѵ���.']);
    end
    keypointtit=strcat(keypointfolderName,'\keypoint_',num2str(outid),'.mat');% ˳������
    save(keypointtit,'key_point_array_1');
    disp(['������������������ʱ���ǣ�',num2str(time),'s']);    
end
