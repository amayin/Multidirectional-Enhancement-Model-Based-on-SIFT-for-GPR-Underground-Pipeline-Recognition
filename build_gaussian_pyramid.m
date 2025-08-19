function [gaussian_pyramid,gaussian_gradient,gaussian_angle]=build_gaussian_pyramid(...
    base_image,...       %����ͼ��
    nOctaves,...         %����
    nOctaveLayers,...    %Dogÿ�������Ϊ��������ʵ�ʲ���-3
    sigma)               %ģ��ϵ��
% ��ʼ�����ģ��ϵ��������
M=factorial(nOctaveLayers); % ������
sig_diff=zeros(1,nOctaveLayers+3); % ���ڲ�֮���ģ��ϵ��
sig_diff(1)=sigma;
sig=zeros(1,nOctaveLayers+3); % �ò��ģ��ϵ��
sig(1)=sigma;
k=zeros(1,nOctaveLayers+3); 
% ����ͬһ����ÿһ���ģ��ϵ��
for i=2:1:(nOctaveLayers+3)
    k(i)=2^(log10(i)/log10(M)); %����ָ��
%     k(i)=2^(1/nOctaveLayers); % ����ָ��
%     if i == nOctaveLayers+3
%         k(i)=k(i-2);
%     end
    sig(i)=sig(i-1)*k(i);
    sig_previous=sig(i-1);
    sig_current=sig(i);
    sig_diff(i)=sqrt(sig_current^2-sig_previous^2);
end

gaussian_pyramid=cell(nOctaves,nOctaveLayers+3);
gaussian_gradient=cell(nOctaves,nOctaveLayers+3);
gaussian_angle=cell(nOctaves,nOctaveLayers+3);
h=[-1,0,1;-2,0,2;-1,0,1];

for o=1:1:nOctaves
    for i=1:1:(nOctaveLayers+3)
        if(o==1 && i==1)
            % Ϊ��һ���һ��ʱ��ԭͼ��
            gaussian_pyramid{1,1}(:,:)=base_image;
        elseif(i==1)
            % ��һ��ĵ�һ�������һ�������ֱ���²���
            temp=gaussian_pyramid{(o-1),nOctaveLayers+1}(:,:);
            gaussian_pyramid{o,1}(:,:)=imresize(temp,1/2,'bilinear');
        else
            % ��Ϊ��һ��ʱ������ǰ��Ӹ�˹ģ���õ��ò�
            WINDOW_GAUSSIAN=round(2*sig_diff(i));        %���˹���ڸ����㹻�������
            WINDOW_GAUSSIAN=2*WINDOW_GAUSSIAN+1;
            w=fspecial('gaussian',[WINDOW_GAUSSIAN,WINDOW_GAUSSIAN],sig_diff(i));
            temp=gaussian_pyramid{o,i-1}(:,:);
            gaussian_pyramid{o,i}=imfilter(temp,w,'replicate');

            if(i>=2 && i<=nOctaveLayers+1)
                % �����ݶȡ��ǶȽ�����
                gradient_x=imfilter(gaussian_pyramid{o,i}(:,:),h,'replicate');
                gradient_y=imfilter(gaussian_pyramid{o,i}(:,:),h','replicate');
                gaussian_gradient{o,i-1}(:,:)=sqrt(gradient_x.^2+gradient_y.^2); 
                
                temp_angle=atan2(gradient_y,gradient_x);
                temp_angle=temp_angle*180/pi;
                temp_angle(temp_angle<0)=temp_angle(temp_angle<0)+360;
                gaussian_angle{o,i-1}(:,:)=temp_angle;
            end
        end
    end
end
end