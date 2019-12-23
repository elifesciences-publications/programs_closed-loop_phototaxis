function [n, area, fish]=image_processing(img, imT, bwthresh,small)

%% Comments
% For the seterovisual and spatio_temporal experiments
% Inputs -----
% img: picture taken by the camera, picture to process
% imT: blured image for the background substraction (with bwadapt
% bwthresh: threshold for the binarization (between 0 and 1=255/255)
% small: minimal size of the obejct to keep
% Outputes -----
% n: number of object in the binarized image
% area: area of the obejct in the binarized image
% fish: binarized image


%% Code
imb = imbinarize(imT-img,bwthresh);
fish = bwareaopen(imb,small);
[L,n] = bwlabel(fish);
area = bwarea(fish);