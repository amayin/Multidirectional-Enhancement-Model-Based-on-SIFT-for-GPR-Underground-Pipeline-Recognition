function [TrackInterval,dt,Ydata] = read_multi_B_scan(path,name)
% clear;
clc ;
close all;
FileHead=1024;
switch nargin
    case 1
        fileName = path;
    case 2
        fileName = fullfile(path,name);
end
if exist('fileName')==0
    disp('File Not Exist');
end  

fid =fopen(fileName);
% fseek(fid,4,'bof');
% fseek(fid,5,'bof');
fseek(fid,0,'bof');
tag=fread(fid,1,'int16');%������־λ,2600Ϊ256,ɨ�١�ʱ���������Σ������豸��float��
fseek(fid,4,'bof');
samPointNum=fread(fid,1,'int16');%����������
fseek(fid,0,'bof');
p1=ftell(fid);
fseek(fid,0,'eof');
p2=ftell(fid);
lenperL=(p2-p1-FileHead)/(samPointNum*2);%��ͷ�ļ��ж����ܵĵ���

fseek(fid,18,'bof');
PulseInterval = fread(fid,1,'float32');%��������������һ�������

fseek(fid,109,'bof');
Interval2 = fread(fid,1,'short');%�����ڶ������

TrackInterval = PulseInterval*Interval2*1e-2;%�����
if tag==256
    fseek(fid,26,'bof');
    timeWindow=fread(fid,1,'int32');%��ͷ�ļ��ж���ʱ��
    fseek(fid,10,'bof');
    scanspeed=fread(fid,1,'int32');%��ͷ�ļ��ж���ɨ��
else
    fseek(fid,26,'bof');
    timeWindow=fread(fid,1,'float32');%��ͷ�ļ��ж���ʱ��
    fseek(fid,10,'bof');
    scanspeed=fread(fid,1,'float32');%��ͷ�ļ��ж���ɨ��
end
dt = timeWindow/samPointNum*1e-9;         %�������
fseek(fid,30,'bof');
freq=fread(fid,1,'int16');%��ͷ�ļ��ж���Ƶ��
fseek(fid,FileHead,'bof');
Ydata=fread(fid,[samPointNum,lenperL],'int16');%����ԭʼ����
fclose(fid);
end