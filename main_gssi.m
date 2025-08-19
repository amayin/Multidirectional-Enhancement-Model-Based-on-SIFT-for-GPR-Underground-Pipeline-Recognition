function [dx, dt,Ydata,name] = main_gssi()
% clear all;
clc;
close all;
%-------------
%% �������
[name, path]=uigetfile('D:/study/GPR_yi/sim/B_scan_imaging_interpreting/*.DZT','���״�̽������');
file=strcat(path,name);

filename = file;
Data = readgssi(filename);
% ��ȡ���ݼ���ͷ
Ydata = Data.samp;  
% Ydata(1034:end,:) = [];
Ydata = Ydata./max(max(abs(Ydata))); %��һ��
Tmax =  Data.head.range*1e-9; %���ʱ�䣬Data.head.range����P_1��������ʱ������Ĵ�С
% Tmax =  Data.head.range*1e-9+Data.head.position*1e-9;
[ny, nx] = size(Ydata);
dt = Tmax/ny; %
t = (1-1:ny-1).*dt.*1e9; %ʱ��
Er = 1; %���ʽ�糣��   
D = t.*(0.3/sqrt(Er))./2; %���
x = (0:nx-1);  dx = 0.5; % ��������λ[cm]
X = x.*dx; % ���룬��λ[cm]

gain_p = 0;  % �Ƿ����棬1�����棬0��������
gain_t=5.*1e-9; % ָ������ʱ��[ns]
t_delay= 0.2504;  %��ʱУ׼[ns]
t_max=3; %������ʾ��ʱ��[ns]
D_max=t_max.*(0.3/sqrt(Er))./2;

colorbar_amp=0.5; %��ʾ��ɫͼ�߶�
max_gain=1; %��ʾ����ϵ����1��ʾû����ʾ���棬Խ���Ӳ�Խǿ

ntrace = 16; %�鿴ĳ������
%% ȥ����
Ydata = Ydata-repmat(sum(Ydata,2)/nx,1,nx); % ��ֵ����
% nn = 50; % ��������
% [Ydata, nn] = rmswbackgr(Ydata ,nn); % ����ȥ����
%% ��ʱУ��
index_cut_start=find(t>=t_delay,1,'first'); %��ʼ��ȡ�±�
Ydata(1:index_cut_start,:)=0;
Ydata=circshift(Ydata,[-1*index_cut_start,0]);
%% Gain
% g=(1:ny).';
% g(round(gain_t/dt):end)=g(round(gain_t/dt));
% % Gend=round(gain_t/dt);
% % g(1:Gend)=exp(t(1:Gend)*0.008).*(t(1:Gend)+dt);
% % g(Gend+1:end)=g(Gend+1:end)*g(Gend);
%   if gain_p == 0
%      g(:) = 1;
%   end
% Ydata=Ydata.*repmat(g,1,nx);
% Ydata = Ydata.*g; % 
% figure 
% tr = 10;
% plot(Ydata1(:,tr),'r')
% hold on
% plot(Ydata(:,tr),'--')
% figure 
% plot(g(:,tr),'--')
%%
figure(1)
imagesc(X,t,Ydata,[-colorbar_amp colorbar_amp])
% imagesc(x,tsamp,Ydata,[-1000000 1000000])
colormap gray
% colorbar
xlabel('Distance/cm')
% xlabel('Trace')
ylabel('Time/ns')
% xlim([0,X(end)])
ylim([0,t_max])
% ylim([3,7.5])
% ylim([0 t_max-t_delay]);
set(gca,'Fontsize',18)
% set(gca,'YDir','reverse');
% set(gca,'xtick',[],'xticklabel',[])
title(num2str(filename(1:end-8)))
% title(' ')
set(gcf,'unit','centimeters','position',[2 2 10 10.5])
figure(2)
imagesc(X,D, Ydata,[-colorbar_amp colorbar_amp])
colormap gray
% colorbar
xlabel('Distance/cm')
% xlabel('Trace')
ylabel('Depth/m')
% xlim([0,X(end)])
ylim([0,D_max])
% ylim([3,7.5])
% ylim([0 t_max-t_delay]);
set(gca,'Fontsize',18)
% set(gca,'YDir','reverse');
% set(gca,'xtick',[],'xticklabel',[])
title(num2str(filename(1:end-8)))
% title(' ')
set(gcf,'unit','centimeters','position',[2 2 10 10.5])


figure(3)

plot(t,Ydata(:,ntrace))
xlabel('Time/ns')
ylabel('Amplitude')
xlim([0,t_max])
% ylim([-4e6,6e6])
set(gca,'Fontsize',18)
% view(90,90)
% title('Trace25')
% title(['trace:',num2str(ntrace)])
% set(gcf,'unit','centimeters','position',[2 2 12 10])
% legend('����','����')% 
end
