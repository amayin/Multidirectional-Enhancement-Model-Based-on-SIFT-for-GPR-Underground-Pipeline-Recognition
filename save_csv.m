function [time]=save_csv(data_csv,tit)
    % tit:·��
    % data_csv:��Ҫ����ı��
    tic;
    fid = fopen(tit,'wt');
    [m,n]=size(data_csv);
    % �����һ��head
    for j=1:1:n-1
        fprintf(fid,'%g,',j);
    end
    fprintf(fid,'%g\n',n);
    % �ڶ���֮��Ϊѵ������
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