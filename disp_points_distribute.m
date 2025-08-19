function button=disp_points_distribute(locs_1,nOctaves_1,dog_center_layer)

dis_num1=zeros(nOctaves_1,dog_center_layer);

for i=1:1:nOctaves_1
    for j=1:1:dog_center_layer
        temp1=find(locs_1(:,6)==i & locs_1(:,7)==j+1);
        dis_num1(i,j)=size(temp1,1);
    end
end

width=0.5;
button=figure;
b1=bar3(dis_num1,width);
xlabel('layer num');
ylabel('group num');
zlabel('point num');

title(['Reference point initial distribution ',num2str(size(locs_1,1)),'points']);
labely1=cell(1,nOctaves_1);
labelx1=cell(1,dog_center_layer);
for i=1:1:nOctaves_1
    labely1{1,i}=['oct-',num2str(i)];
end
for i=1:1:dog_center_layer
    labelx1{1,i}=['lay-',num2str(i)];
end
set(gca,'xticklabel',labelx1);
set(gca,'yticklabel',labely1);
height=max(max(dis_num1))*0.1;
for x=1:dog_center_layer
    for y=1:nOctaves_1
        text(x,y,dis_num1(y,x)+height,num2str(dis_num1(y,x)));
    end
end
set(gca,'FontName','Time New Roman','FontSize',7);

end