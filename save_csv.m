function [time]=save_csv(data_csv,tit)
    % tit:路径
    % data_csv:需要保存的表格
    tic;
    fid = fopen(tit,'wt');
    [m,n]=size(data_csv);
    % 输入第一行head
    for j=1:1:n-1
        fprintf(fid,'%g,',j);
    end
    fprintf(fid,'%g\n',n);
    % 第二行之后为训练数据
    for i=1:1:m
        for j=1:1:n
           if j==n
             fprintf(fid,'%g\n',data_csv(i,j));
          else
            fprintf(fid,'%g,',data_csv(i,j));
           end
        end
    end
    fclose(fid);
    time=toc;
end