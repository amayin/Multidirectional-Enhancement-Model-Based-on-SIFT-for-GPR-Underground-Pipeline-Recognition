function [button_1]=showpoint_detected_in_different_layer(im1,loc1)
uni1=loc1(:,[1 2 3 4 5]);
[~,i,~]=unique(uni1,'rows','first');
loc1=loc1(sort(i)',:);
cor1_x=loc1(:,2);cor1_y=loc1(:,1);layer=loc1(:,7);
button_1=figure;colormap('gray');imagesc(im1);
title(['Reference image',num2str(size(cor1_x,1)),'points']);hold on;
colors = {'r','y','g','c','b','m'};
for k = 2:max(layer)
    idx = layer == k;
    scatter(cor1_x(idx),cor1_y(idx),36,colors{k-1},'filled');hold on;%scatter???????ии????????
end
fprintf('The image points num is %d.\n', size(loc1,1));
end