%% ��ȡgprMax��������
% ���������Ƚ����е�����Բ����ܵ�
% ���룺gprMax .out �ļ� �����Bɨ�����Ӳ����ƺ����ݾ���
%%
function [field_after_clutter_suppression] = readB_scan_simlation_data(Path)

%% ԭʼBɨͼ�����ݶ�ȡ

if exist('Path')
    fullfilename = Path;
else
    [filename, pathname] = uigetfile('*.out', 'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');
    fullfilename = fullfile(pathname, filename);
end

if fullfilename ~= 0
    header.iterations = double(h5readatt(fullfilename, '/', 'Iterations'));
    header.dt = h5readatt(fullfilename, '/', 'dt');

%     prompt = 'Which field do you want to view? Ex, Ey, or Ez: ';
%     field = input(prompt,'s');
    fieldpath = strcat('/rxs/rx1/', 'Ez');
    field = double(h5read(fullfilename, fieldpath)');
    time = linspace(0, (header.iterations - 1) * header.dt, header.iterations)';
    traces = 1:size(field, 2);
end
%     figure('Name', fullfilename);
%     imagesc(traces, time, field);
%     colormap('gray')
%     xlabel('trace number');
%     ylabel('time(s)');
%     colorbar();
%% ��ֵ����ȥ�Ӳ�
[r,c] = size(field);
T_std = 50;
field_average = double(mean(field,2));
field_std = zeros(r,1);
% ������
for i = 1:r
    field_std(i) = std(field(i,:));
end
field_average_matrix = field_average*ones(1,c);
for i = 1:r
    if field_std(i)>T_std
        field_average_matrix(i,:) = 0;
    end
end

field_after_clutter_suppression = field-field_average_matrix;
figure;
imagesc(traces, time, field_after_clutter_suppression);
xlabel('trace number');
ylabel('time(s)');
colorbar();
colormap('gray');

end 



