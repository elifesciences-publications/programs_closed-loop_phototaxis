function [head, tail, ang] = get_orientation_distmap(im_bw)
%% Comments

% Inputs -----
% im_bw: binarized image containing only one object. The background should
% be black (0) anf the object white (1)
% Outupus -----
% head: fish head coordinates (further point from the edge)
% tail: fish tail coordinates (furhter point from the head, located at the
% edge of the obejct)
% ang: angle made by the vector (tail, head)


%% Code
d = bwdist(~im_bw);
[yhp,xhp] = find(d==max(max(d)) & d>0); %find all the points at the center
[y2, x2] = find(d==1); %find all the points at the object border
dist = 0;
x2 = gather(x2);
y2 = gather(y2);
xt = 0;
yt = 0;

for k = 1:size(xhp,1)
    xht = xhp(k);
    yht = yhp(k);
    for j = 1:size(x2,1) %find the furthest point from the center, tail
        dist1 = sqrt((xht-x2(j))^2+(yht-y2(j))^2);
        if dist1>dist && dist1<40
            dist=dist1;
            xt = x2(j);
            yt = y2(j);
            xh = xhp(k);
            yh = yhp(k);
        end
    end
end
head = [xh, yh]; %head coordinates
tail = [xt, yt]; %swim bladder coordinates
ang = fishangle(xh, yh, xt, yt); %angle making by the fish