function [symmery_flag,temp_locs,E_distance] = screen_point_by_symmery(descriptors_1,locs_1,LOG_POLAR_HIST_BINS,SIFT_HIST_BINS,T_symmetry,is_sift_or_log)
%UNTITLED2 此处显示有关此函数的摘要
%   使用PCA方法
%     pca_matrix = zeros(size(descriptors_1,1),4);
%     for i = 1:size(descriptors_1,1)
%         [pca_descriptor,~]=PCA_of_Gloh_descriptor(descriptors_1(i,:), LOG_POLAR_HIST_BINS);
%         pca_matrix(i,:) = pca_descriptor';
%     end
%     len_temp_locs = sum(pca_matrix(:,1)>=T_symmetry);
%     temp_locs = zeros(len_temp_locs,size(locs_1,2));
%     j = 0;
%     for i = 1:size(descriptors_1,1)
%         if pca_matrix(i,1)<T_symmetry
%             descriptors_1(i,:) = 0;
%             continue
%         end
%         j = j+1;
%         temp_locs(j,:) = locs_1(i,:);
%     end
    
%   使用欧氏距离方法
if (strcmp(is_sift_or_log,'GLOH-like')) || (strcmp(is_sift_or_log,'FS-GLOH-like')) || (strcmp(is_sift_or_log,'FE-GLOH-like'))
    E_distance = zeros(size(descriptors_1,1),1);
    for i = 1:size(descriptors_1,1)
        [E,~]=Euclid_distance_of_Gloh_descriptor(descriptors_1(i,:), LOG_POLAR_HIST_BINS);
        E_distance(i,:) = E;
    end
    len_temp_locs = sum(E_distance<=T_symmetry);
    temp_locs = zeros(len_temp_locs,size(locs_1,2));
    symmery_flag = ones(size(descriptors_1,1),1);
    j = 0;
    for i = 1:size(descriptors_1,1)
        if E_distance(i,:)>T_symmetry
            symmery_flag(i,:) = 0;
            continue
        end
        j = j+1;
        temp_locs(j,:) = locs_1(i,:);
    end
elseif (strcmp(is_sift_or_log,'SIFT')) || (strcmp(is_sift_or_log,'RootSIFT'))
    E_distance = zeros(size(descriptors_1,1),1);
    for i = 1:size(descriptors_1,1)
        [E,~]=Euclid_distance_of_SIFT_descriptor(descriptors_1(i,:), SIFT_HIST_BINS);
        E_distance(i,:) = E;
    end
    len_temp_locs = sum(E_distance<=T_symmetry);
    temp_locs = zeros(len_temp_locs,size(locs_1,2));
    symmery_flag = ones(size(descriptors_1,1),1);
    j = 0;
    for i = 1:size(descriptors_1,1)
        if E_distance(i,:)>T_symmetry
            symmery_flag(i,:) = 0;
            continue
        end
        j = j+1;
        temp_locs(j,:) = locs_1(i,:);
    end
elseif strcmp(is_sift_or_log,'PCA-SIFT')
    symmery_flag = ones(size(descriptors_1,1),1);
    temp_locs = locs_1;
    E_distance = zeros(size(descriptors_1,1),1);
end

end

