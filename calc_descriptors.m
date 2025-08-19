function [descriptors,nex_descriptors,locs]=calc_descriptors...
(gaussian_gradient,...
gaussian_angle,...
key_point_array,...
nOctaves,...
is_double_size,...
is_sift_or_log,...
LPDW,...
LPHB,...
SDW,...
SHB,...
FEV...
)

LOG_POLAR_DESCR_WIDTH=LPDW;
LOG_POLAR_HIST_BINS=LPHB;
SIFT_DESCR_WIDTH=SDW;   %SIFT特征提取区域，默认4×4区域
SIFT_HIST_BINS=SHB;     %SIFT特征方向，默认8方向

M=size(key_point_array,2);
locs=zeros(M,7);  % locs各列：行，列，size，角度，梯度，组，层
if(strcmp(is_sift_or_log,'GLOH-like'))
    d=LOG_POLAR_DESCR_WIDTH;
    n=LOG_POLAR_HIST_BINS;
    descriptors=zeros(M,(2*d+1)*n);
    nex_descriptors=zeros(M,(2*d+1)*n);
    
    for i=1:1:M
    kpt=key_point_array(i);
    octaves=kpt.octaves;
    layer=kpt.layer;
    y=kpt.y/(2^(octaves-1));
    x=kpt.x/(2^(octaves-1));
    main_angle=kpt.angle;
    scale=kpt.size/(2^(octaves-1));
    
    temp_gradient=gaussian_gradient{octaves,layer-1};
    temp_angle=gaussian_angle{octaves,layer-1};
    descriptors(i,:)=calc_log_polar_descriptor(temp_gradient,temp_angle,...
                                        round(x),round(y),scale,main_angle,d,n);
    % 多尺度特征融合策略                                

    if octaves<=nOctaves-1
        nex_octave = octaves+1;
    else
        nex_octave = nOctaves;
    end
    nex_y=kpt.y/(2^(nex_octave-1));
    nex_x=kpt.x/(2^(nex_octave-1));
    temp_gradient=gaussian_gradient{nex_octave,layer-1};
    temp_angle=gaussian_angle{nex_octave,layer-1};
    nex_descriptors(i,:)=calc_log_polar_descriptor(temp_gradient,temp_angle,...
                                        round(nex_x),round(nex_y),scale,main_angle,d,n);                                
                                    
    if(is_double_size==true)
        locs(i,1)=kpt.y/2;
        locs(i,2)=kpt.x/2;
    elseif(is_double_size==false)
        locs(i,1)=kpt.y;
        locs(i,2)=kpt.x; 
    end
    locs(i,3)=kpt.size;
    locs(i,4)=kpt.angle;
    locs(i,5)=kpt.gradient;
    locs(i,6)=kpt.octaves;
    locs(i,7)=kpt.layer;
    end
elseif(strcmp(is_sift_or_log,'SIFT'))
    d=SIFT_DESCR_WIDTH;
    n=SIFT_HIST_BINS;
    descriptors=zeros(M,d*d*n);
    nex_descriptors=zeros(M,d*d*n);
    
    for i=1:1:M
    kpt=key_point_array(i);
    octaves=kpt.octaves;
    layer=kpt.layer;
    y=kpt.y/(2^(octaves-1));
    x=kpt.x/(2^(octaves-1));
    main_angle=kpt.angle;
    scale=kpt.size/(2^(octaves-1));
    
    temp_gradient=gaussian_gradient{octaves,layer-1};
    temp_angle=gaussian_angle{octaves,layer-1};
    descriptors(i,:)=calc_sift_descriptor(temp_gradient,temp_angle,...
                                        round(x),round(y),scale,main_angle,d,n);
                                    
    % 多尺度特征融合策略                                

    if octaves<=nOctaves-1
        nex_octave = octaves+1;
    else
        nex_octave = nOctaves;
    end
    nex_y=kpt.y/(2^(nex_octave-1));
    nex_x=kpt.x/(2^(nex_octave-1));
    temp_gradient=gaussian_gradient{nex_octave,layer-1};
    temp_angle=gaussian_angle{nex_octave,layer-1};
    nex_descriptors(i,:)=calc_sift_descriptor(temp_gradient,temp_angle,...
                                        round(nex_x),round(nex_y),scale,main_angle,d,n);  
    if(is_double_size==true)
        locs(i,1)=kpt.y/2;
        locs(i,2)=kpt.x/2;
    elseif(is_double_size==false)
        locs(i,1)=kpt.y;
        locs(i,2)=kpt.x; 
    end
    locs(i,3)=kpt.size;
    locs(i,4)=kpt.angle;
    locs(i,5)=kpt.gradient;
    locs(i,6)=kpt.octaves;
    locs(i,7)=kpt.layer;
    end
    
elseif(strcmp(is_sift_or_log,'FE-GLOH-like')) 
    d=LOG_POLAR_DESCR_WIDTH;
    n=LOG_POLAR_HIST_BINS;
    descriptors=zeros(M,(2*d+1)*n);
    nex_descriptors=zeros(M,(2*d+1)*n);
    FE_vector = FEV;
    for i=1:1:M
    kpt=key_point_array(i);
    octaves=kpt.octaves;
    layer=kpt.layer;
    y=kpt.y/(2^(octaves-1));
    x=kpt.x/(2^(octaves-1));
    main_angle=kpt.angle;
    scale=kpt.size/(2^(octaves-1));
    
    temp_gradient=gaussian_gradient{octaves,layer-1};
    temp_angle=gaussian_angle{octaves,layer-1};
    descriptors(i,:)=calc_FE_descriptor(temp_gradient,temp_angle,...
                                        round(x),round(y),scale,main_angle,d,n,FE_vector);
    % 多尺度特征融合策略                                

    if octaves<=nOctaves-1
        nex_octave = octaves+1;
    else
        nex_octave = nOctaves;
    end
    nex_y=kpt.y/(2^(nex_octave-1));
    nex_x=kpt.x/(2^(nex_octave-1));
    temp_gradient=gaussian_gradient{nex_octave,layer-1};
    temp_angle=gaussian_angle{nex_octave,layer-1};
    nex_descriptors(i,:)=calc_log_polar_descriptor(temp_gradient,temp_angle,...
                                        round(nex_x),round(nex_y),scale,main_angle,d,n);                                  
    if(is_double_size==true)
        locs(i,1)=kpt.y/2;
        locs(i,2)=kpt.x/2;
    elseif(is_double_size==false)
        locs(i,1)=kpt.y;
        locs(i,2)=kpt.x; 
    end
    locs(i,3)=kpt.size;
    locs(i,4)=kpt.angle;
    locs(i,5)=kpt.gradient;
    locs(i,6)=kpt.octaves;
    locs(i,7)=kpt.layer;
    end
    
end
end