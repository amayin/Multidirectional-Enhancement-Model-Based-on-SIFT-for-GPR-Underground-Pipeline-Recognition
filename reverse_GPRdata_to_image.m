% ����·��
file_mode = "lte";
lte_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\Iteѵ��������չ';% lte�ļ�·��
DZT_path = 'D:\˶ʿ�ļ�\gprMAX���\ʵ������\DZTʵ����������';% DZT�ļ�·��
image_path = 'D:\˶ʿ�ļ�\SIFT��ȡ\ʵ����\����ѵ����֮���ʵ����\������ѵ����JPG';
if file_mode == "lte"
    files = dir(fullfile(lte_path, '*.lte'));
elseif file_mode == "DZT"
    files = dir(fullfile(DZT_path, '*.DZT'));
end
en = size(files,1);
% ��ȡ����
for outid = 1:en
    if file_mode == "lte"
    % ��ȡite�ļ�
    file_name = files(outid).name;
    file_parts = split(file_name,'.');
    file_label = file_parts{1};
    [TrackInterval,dt,B_scan_image] = read_multi_B_scan(lte_path,file_name);
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
%     figure
%     imagesc(B_scan_image);
%     colormap('gray');
%     xlabel('Trace(m)');ylabel('Time(ns)');
%     set(gca,'linewidth',1,'fontsize',20,'fontname','Times New Roman');
%     origin_B_scan_image = B_scan_image;
    % ��һ��
    B_scan_image_normalize = (B_scan_image-min(min(B_scan_image)))/(max(max(B_scan_image))-min(min(B_scan_image)));
    % ���Ϊ.jpg
    pictrue_name = strcat(image_path,'\',file_label,'.jpg');
    imwrite(B_scan_image_normalize, pictrue_name); % ֱ�ӱ���Ϊpng�ļ�
end