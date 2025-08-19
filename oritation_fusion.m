function [main_oritation,main_gradient] = oritation_fusion(n,hist)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
polar_n = [1:n]/n*2*pi-pi; %转化为弧度
[oritation_x, oritation_y] = pol2cart(polar_n, hist);
main_oritation_x = sum(oritation_x);
main_oritation_y = sum(oritation_y);
[polar_main_oritation,main_gradient] = cart2pol(main_oritation_x,main_oritation_y);
main_oritation = round((polar_main_oritation+pi)/2/pi*n);
if main_oritation > n
    main_oritation = 1;
elseif main_oritation < 1
    main_oritation = n;
end
end

