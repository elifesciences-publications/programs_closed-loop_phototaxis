function [bwthresh, imT, small, maskbw] = parameters_image_processing(vid, ROIdish, maskbw)
%% Comments
% Parameters to chock before running the experiment
%Inputs -----
% vid: parameters of the camera
% ROIdish: Region of the interest [xtopleft ytopleft xwidth ywidth]
% maskbw: mask creating with the ROIdish before
%Outputs -----
% bwthresh: binarized threshold (0 to 1=255/255)
% imT: blured image for the background substraction
% small: maximum size of the object to remove
% maskbw: mask applied to imT

%% Code
start(vid)
im = getsnapshot(vid);
maskbw = uint8(maskbw(ROIdish(2):ROIdish(2)+size(im,1)-1,ROIdish(1):ROIdish(1)+size(im,2)-1));
imT = uint8(adaptthresh(im,0.6)*255);
imT = imT.*maskbw;
img = getsnapshot(vid);
stop(vid)

bwthresh = 11/255;
n = 11;
sprintf('Binarized threshold sets at %d', n)

while n ~= 0
    imb = imbinarize(imT-img,n/255);
    imshow(imb);
    disp('Choose the binarized threshold, then press 0')
    n = input('binarized threshold?');
    if n ~= 0
        bwthresh = n/255;
    end
end

n = 40;
small = 40;
sprintf('Remove object smaller than %d pixels', small)
while n ~= 0
    imshow(bwareaopen(imb,small));
    n = input('smaller than?');
    if n ~= 0
        small = n;
    end
end
imc = bwareaopen(imb,small);

close all