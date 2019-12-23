function [imfin]=crop_image(cx,cy,imgbn,width)

%% Comments
% For experiments which record image
% Reduce the size of the binarized image imgbn, make a square of width*width pixels centered on cx,cy 

width = width/2;

%% Code
if cy+width > size(imgbn,1)
    cy = size(imgbn,1)-width;
end
if cy-width < 1
    cy = width+1;
end
if cx+width > size(imgbn,2)
    cx = size(imgbn,2)-width;
end
if cx-width < 1
    cx = width+1;
end
imfin = imgbn(cy-width:cy+width-1,cx-width:cx+width-1);