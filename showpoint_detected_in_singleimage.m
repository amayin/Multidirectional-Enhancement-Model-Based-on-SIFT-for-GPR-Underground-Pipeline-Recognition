function [button_1]=showpoint_detected_in_singleimage(im1,loc1)
uni1=loc1(:,[1 2 3 4 5]);
[~,i,~]=unique(uni1,'rows','first');
loc1=loc1(sort(i)',:);
cor1_x=loc1(:,2);cor1_y=loc1(:,1);
button_1=figure;colormap('gray');imagesc(im1);
title(['Reference image',num2str(size(cor1_x,1)),'points']);hold on;
scatter(cor1_x,cor1_y,'r');hold on;%scatter???????ии????????
fprintf('The image points num is %d.\n', size(loc1,1));
end