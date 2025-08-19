% 定义路径
file_mode = "lte";
lte_path = 'D:\硕士文件\gprMAX相关\实测数据\Ite训练数据扩展';% lte文件路径
DZT_path = 'D:\硕士文件\gprMAX相关\实测数据\DZT实验数据整合';% DZT文件路径
image_path = 'D:\硕士文件\SIFT提取\实验结果\扩充训练集之后的实验结果\扩充后的训练集JPG';
if file_mode == "lte"
    files = dir(fullfile(lte_path, '*.lte'));
elseif file_mode == "DZT"
    files = dir(fullfile(DZT_path, '*.DZT'));
end
en = size(files,1);
% 读取数据
for outid = 1:en
    if file_mode == "lte"
    % 读取ite文件
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    [TrackInterval,dt,B_scan_image] = read_multi_B_scan(lte_path,file_name);
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
%     figure
%     imagesc(B_scan_image);
%     colormap('gray');
%     xlabel('Trace(m)');ylabel('Time(ns)');
%     set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');
%     origin_B_scan_image = B_scan_image;
    % 归一化
    B_scan_image_normalize = (B_scan_image-min(min(B_scan_image)))/(max(max(B_scan_image))-min(min(B_scan_image)));
    % 输出为.jpg
    pictrue_name = strcat(image_path,'\',file_label,'.jpg');
    imwrite(B_scan_image_normalize, pictrue_name); % 直接保存为png文件
end