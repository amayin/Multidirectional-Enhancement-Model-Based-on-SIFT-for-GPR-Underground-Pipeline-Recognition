% ���ļ������㷨
clear;
clc;
close all;

% ��������Ҫʱ��ע��ĵط��������������򣬶�ȡ�ļ����������ֶ�ѡȡ��ǩ����

%% Define the constants used
output_path = 'F:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\Multidirectional Enhancement Model Based on SIFT for GPR Underground Pipeline Recognition_latex\������\'; % ���������·��
PCA_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\SIFT_extract\SIFT_extract_in_GPR\descriptors\target_real\PCA_model.csv'; % �ڹ���PCA-SIFT������ʱ��PCAģ��·��
begin = 1;% �ļ���ʼ��ȡ��
en = 1;% �ļ�������ȡ��
sigma=1.6;%��ײ��˹�������ĳ߶�
dog_center_layer=5;%������DOG������ÿ���м������Ĭ����5
contrast_threshold_1=0.03;%Contrast threshold ԭ�������0.03
edge_threshold=10;%Edge threshold
is_double_size=false;%expand image or not
des_type ='FE-GLOH-like';%Type of descriptor,it can be 'GLOH-like','SIFT','PCA-SIFT','RootSIFT','FE-GLOH-like'
LOG_POLAR_DESCR_WIDTH=8;
LOG_POLAR_HIST_BINS=8;
SIFT_DESCR_WIDTH=4;   %SIFT������ȡ����Ĭ��4��4����
SIFT_HIST_BINS=8;     %SIFT��������Ĭ��8����
T_angle=3;    % ���봹ֱ�����ƫ�ƽǶ���ֵ��abs()<T_angle�϶�Ϊ��ֱ
FS_vector=[1,1,1,1,1,1,1,1]; % ÿ���Ƕȵ�������ǿϵ�������һ��ֵ�ǹؼ�����������ǿϵ��
edge_detect = "on"; % �Ƿ�ȥ����ԵЧӦ��on��ʾȥ����ԵЧӦ
angleverse = "on"; % �Ƿ�����ת������Ƕ�
contrast = [10,0.05]; % ���ؼ����������ڵ�һ����ʱ������ȥ���ͷ��ȵ�ģʽ����ֵΪ�ڶ�����
T_symmetry = 1.2;
n_max = 100; % ���������λ��������󶶶���С
n_sigma2 = 1; % ��˹������С
phase_noise = "off"; %�Ƿ����λ��������on�����룬��off��������
interpola = "off"; %�Ƿ�������ţ�"on"�ǣ�"off"��
inter_m = [512,160]; %���ű���
mode = "DZT"; % Դ�ļ����ͣ�����"out","lte","DZT","png"�����Զ�����������

for outid = begin:en
    disp(['----------------��ʼ���ɵ�',num2str(outid),'���ļ���������----------------']);
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

    % ��ͼ
    figure
    imagesc(B_scan_image);
    colormap('gray');
    xlabel('Trace(m)');ylabel('Time(ns)');
    set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');
    origin_B_scan_image = B_scan_image;

    %% Ԥ����
    % ����ϡ��ֽ�ȥֱ�ﲨ
    addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV');
    addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV\read_data');  
    addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV\prox_operator');  
    addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV\calutate');
    addpath('D:\˶ʿ�ļ�\gprMAX���\ʵ������\RPCA_With_TV\utils');
%     lambda = 0.01;beta = 0.03;
%     n_iters_ADMM=500;n_iters_TV=100;
%     [X,runtime] = LRS_TV_InALM(B_scan_image,lambda,beta,n_iters_ADMM,n_iters_TV);
%     B_scan_image_sparse = X.S;
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
    B_scan_image_normalize = (B_scan_image-min(min(B_scan_image)))/(max(max(B_scan_image))-min(min(B_scan_image)));
    
    % �����λ����
    if phase_noise == "on"
        [m,n]=size(B_scan_image_normalize);
        A_scan_length = m-n_max;
        phase_mean = n_max/2;
        phase = phase_mean+n_sigma2*randn(1,n);
        temp_B_scan_image = zeros(A_scan_length,n);
        for i = 1:n
            phase_begin = phase(i);
            if phase_begin>n_max
                phase_begin = phase_mean;
            end
            temp_B_scan_image(:,i) = B_scan_image_normalize(phase_begin+1:phase_begin+A_scan_length,i);
        end
        B_scan_image_normalize = temp_B_scan_image;
    end
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
    
    %% ѡȡ����/�����ݶȹؼ���
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
    end
    key_point_array_1 = temp_key_point_array; 
    if isempty(key_point_array_1)
        continue
    end
    %% descriptor generation of the reference image 
    tic;
    [descriptors_1,nex_descriptors_1,locs_1]=calc_descriptors(gaussian_gradient_1,gaussian_angle_1,...
                                    key_point_array_1,nOctaves_1,is_double_size,des_type,...
                                    LOG_POLAR_DESCR_WIDTH,LOG_POLAR_HIST_BINS,...
                                    SIFT_DESCR_WIDTH,SIFT_HIST_BINS,FS_vector);
    disp(['�ο�ͼ�����������ɻ���ʱ���ǣ�',num2str(toc),'s']); 
%     clear gaussian_gradient_1;
%     clear gaussian_angle_1;
    
    %% ���ݶԳ���ɸѡ˫����
    [now_flag,now_locs_1,now_smy] = screen_point_by_symmery(descriptors_1,locs_1,LOG_POLAR_HIST_BINS,SIFT_HIST_BINS,T_symmetry,des_type);
    [nex_flag,nex_locs_1,nex_smy] = screen_point_by_symmery(nex_descriptors_1,locs_1,LOG_POLAR_HIST_BINS,SIFT_HIST_BINS,T_symmetry,des_type);

    %% Display the detect points
    [button1]=showpoint_detected_in_different_layer(B_scan_image_normalize,now_locs_1) ;
    str1=['.\save_image\','The detection point in now octave','.jpg'];
    saveas(button1,str1,'jpg');
    
    [button1]=showpoint_detected_in_different_layer(B_scan_image_normalize,nex_locs_1);
    str3=['.\save_image\','The detection point in next octave','.jpg'];
    saveas(button1,str3,'jpg');
    
    [button1]=showpoint_detected_in_different_layer(B_scan_image_normalize,locs_1);
    str4=['.\save_image\','Reference image detection point','.jpg'];
    saveas(button1,str4,'jpg');
    [button2]=disp_points_distribute(locs_1,nOctaves_1,dog_center_layer);
    %% ������ʵ�����ݵ��ֶ�ѡȡ��ǩ�������ֲ�Ӱ������ʶ����
    label = zeros(size(locs_1,1),1);
    for i = 1:size(descriptors_1,1)
        if locs_1(i,1)>=300
            label(i,:)=1;
        end
    end
    %% Save the data with csv
    % ����Գ����б�flag
    % ��������Ҫ�������ļ�������
    flagfolderName = strcat(output_path,file_label,'\flag_',des_type);
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
    disp(['�����ǩ����ʱ���ǣ�',num2str(time),'s']);
    labtit=strcat(flagfolderName,'\nex_flag_',num2str(outid),'.csv');% ˳������
    [time] = save_csv(nex_flag,labtit);
    disp(['�����ǩ����ʱ���ǣ�',num2str(time),'s']);
    
    % ����label
    labelfolderName = strcat(output_path,file_label,'\label_',des_type);
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
    datafolderName = strcat(output_path,file_label,'\data_',des_type);
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
    locfolderName = strcat(output_path,file_label,'\loc_',des_type);
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
    keypointfolderName = strcat(output_path,file_label,'\keypoint_',des_type);
    % ����ļ����Ƿ��Ѿ�����
    if ~exist(keypointfolderName, 'dir')
        % �ļ��в����ڣ������ļ���
        mkdir(keypointfolderName);
        disp(['�ļ��� "' keypointfolderName '" �Ѵ���.']);
    else
        % �ļ����Ѵ���
        disp(['�ļ��� "' keypointfolderName '" �Ѵ���.']);
    end
    keypointtit=strcat(keypointfolderName,'\keypoint_',num2str(outid),'.mat'); % ˳������
    save(keypointtit,'key_point_array_1');
    disp(['������������������ʱ���ǣ�',num2str(time),'s']);
end
