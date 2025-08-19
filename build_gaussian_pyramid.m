function [gaussian_pyramid,gaussian_gradient,gaussian_angle]=build_gaussian_pyramid(...
    base_image,...       %基础图像
    nOctaves,...         %组数
    nOctaveLayers,...    %Dog每组层数，为金字塔中实际层数-3
    sigma)               %模糊系数
% 初始化存放模糊系数的向量
M=factorial(nOctaveLayers); % 对数底
sig_diff=zeros(1,nOctaveLayers+3); % 相邻层之间的模糊系数
sig_diff(1)=sigma;
sig=zeros(1,nOctaveLayers+3); % 该层的模糊系数
sig(1)=sigma;
k=zeros(1,nOctaveLayers+3); 
% 定义同一组中每一层的模糊系数
for i=2:1:(nOctaveLayers+3)
    k(i)=2^(log10(i)/log10(M)); %对数指数
%     k(i)=2^(1/nOctaveLayers); % 分数指数
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
            % 为第一组第一层时，原图像
            gaussian_pyramid{1,1}(:,:)=base_image;
        elseif(i==1)
            % 下一组的第一层等于上一组第三层直接下采样
            temp=gaussian_pyramid{(o-1),nOctaveLayers+1}(:,:);
            gaussian_pyramid{o,1}(:,:)=imresize(temp,1/2,'bilinear');
        else
            % 不为第一层时，对先前层加高斯模糊得到该层
            WINDOW_GAUSSIAN=round(2*sig_diff(i));        %令高斯窗口覆盖足够多的能量
            WINDOW_GAUSSIAN=2*WINDOW_GAUSSIAN+1;
            w=fspecial('gaussian',[WINDOW_GAUSSIAN,WINDOW_GAUSSIAN],sig_diff(i));
            temp=gaussian_pyramid{o,i-1}(:,:);
            gaussian_pyramid{o,i}=imfilter(temp,w,'replicate');

            if(i>=2 && i<=nOctaveLayers+1)
                % 构建梯度、角度金字塔
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