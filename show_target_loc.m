function [button_1]=show_target_loc(img,loc,pred)
% 提取所有预测值为1的点位置
pred_loc = zeros(sum(pred),size(loc,2));
k=1;
for i=1:size(pred,1)
    if pred(i,1) == 1
        pred_loc(k,:) = loc(i,:);
        k=k+1;
    end
end
button_1=figure('Position', [100, 100, 1200, 400]);
subplot(1,2,1)
uni1=loc(:,[1 2 3 4 5]);
[~,i,~]=unique(uni1,'rows','first');
loc=loc(sort(i)',:);
cor1_x=loc(:,2);cor1_y=loc(:,1);
colormap('gray');imagesc(img);
title(['Reference image',num2str(size(cor1_x,1)),'points']);hold on;
scatter(cor1_x,cor1_y,'r');hold on;%scatter???????è????????
fprintf('The image points num is %d.\n', size(loc,1));


subplot(1,2,2)
[~,i,~]=unique(pred_loc,'rows','first');
pred_loc=pred_loc(sort(i)',:);
cor1_x=pred_loc(:,2);cor1_y=pred_loc(:,1);
colormap('gray');imagesc(img);
title(['Reference image',num2str(size(cor1_x,1)),'points']);hold on;
scatter(cor1_x,cor1_y,'r');hold on;%scatter???????è????????
fprintf('The image points num is %d.\n', size(pred_loc,1));
end