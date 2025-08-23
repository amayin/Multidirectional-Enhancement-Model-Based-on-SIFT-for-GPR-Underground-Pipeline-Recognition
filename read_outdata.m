function [TrackInterval,dt,B_scan_data,filename] = read_outdata()
%UNTITLED 本函数的作用是读取out文件
%   此处显示详细说明
if nargin == 0
[filename, pathname] = uigetfile('*.out', 'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');
fullfilename = fullfile(pathname, filename);
end
if fullfilename ~= 0
    header.iterations = double(h5readatt(fullfilename, '/', 'Iterations'));
    header.dt = h5readatt(fullfilename, '/', 'dt');
    header.srcsteps = 0.01;
    fieldpath = strcat('/rxs/rx1/', 'Ez');
    field = h5read(fullfilename, fieldpath)';
    time = linspace(0, (header.iterations - 1) * header.dt, header.iterations)';
    traces = 1:size(field, 2);
    dt = header.dt;
end
figure;
% field = (field-min(min(field)))./(max(max(field))-min(min(field)));        %归一化到0到1之间
imagesc(traces, time*1e9,field);
xlabel('Trace Number');ylabel('Time(ns)');title('Source Image');
set(gca,'linewidth',1,'fontsize',21,'fontname','Microsft YaHei UI');
colormap('gray');
colorbar;
B_scan_data = field;
TrackInterval = 0.02;

end
