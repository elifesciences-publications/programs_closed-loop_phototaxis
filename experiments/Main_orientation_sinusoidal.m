%% Comments
% Stereovisual experiment with a sinusoidal profile
% Enter the parameters for the experiment and run it

clear
close all
sca
imaqreset

%works with make_movie2, make_movie_ini, get_orientation_distmap, angle_per_frame,
%fishangle, open_psychtoolbox, parameters_image_processing, OMR_radial_f,
%initialization_with_im, initialization_without_im,
%luminosity_sinus, center_f, crop_image,
%experiment_sin_without_im, experiment_sin_with_im, image_processing,

%% ----- Set the different parameters -----
% ----- fish number -----
f = input('Fish number?');

% ---- global -----
%virtual circle for finding the fish, 1pixcam = 0.089mm
xin = 477 + (25/0.089)*cos(linspace(0,2*pi));
yin = 473 + (25/0.089)*sin(linspace(0,2*pi));
ang_thresh = 5;
fish_state = 'WT 6 dpf';

% ----- initalisation -----
ini_tot = 1*60; %total lenght of the initialisation in seconds
ini_rec = 0.5*60; %duration for recording baseline
textureOpacityini = 1;

% ----- experiment -----
percPm = 0.6; %percentage max of the luminosity during the experiment
lum_sin = luminosity_sinus(percPm);
recording_time_sec = 3*60; %total lenght of the experiement in seconds
time_adapt = 0; %adaptation time after OMR

% ----- recording im? -----
% yes = 1 /!\ decreases the framerate
% no = 0
im = 0;

%% video configuration
v = exist('vid');
if v == 0
    vid = videoinput('pointgrey', 1, 'F7_Raw8_1280x1024_Mode0');
end

stop(vid)
vid.FramesPerTrigger = 1;
resolution=vid.VideoResolution;
vid.TriggerRepeat = Inf;
vid.ROIPosition = [0 0 resolution(1) resolution(2)];
triggerconfig(vid, 'manual');
src = getselectedsource(vid);
% src.GainMode = 'Manual';
% src.Gain = 10;
% src.ShutterMode = 'Manual';
% src.Shutter =1.8;
% src.ExposureMode = 'Manual';
% src.Exposure = 0.7;
% framerateprop = propinfo(src,'FrameRate'); % look for max framerate
% MaxFramerate = framerateprop.ConstraintValue(2);
% src.FrameRateMode = 'Manual';
% src.FrameRate = MaxFramerate;

%% Psychtoolbox projector config, screen & projection parameters

[screenXpixels, screenYpixels, window, white, black, ifi] = open_psychtoolbox();

% Perform initial flip to blacken background and sync us to the retrace:
vbl = Screen('Flip', window);

%experiment features
waitframes = 3;
srcRect = [0 0 screenXpixels screenYpixels];
mask_white_matrix = ones(screenYpixels, screenXpixels);
mask_white = Screen('MakeTexture', window, mask_white_matrix);
textureOpacity = 1;
Screen('Drawtexture', window, mask_white, srcRect,[],[],[], textureOpacity);
Screen('Flip', window);

%% Check the center position
if f==1
    n=1;
    center_f(screenXpixels,screenYpixels,window,mask_white,srcRect)
    while n~= 0
        n = input('Place the projector center on the camera center (black dot) then press 0');
    end
end

%% Get ROI petridish and image processing parameters
Screen('Drawtexture', window, mask_white, srcRect,[],[],[], textureOpacity);
Screen('Flip', window);
n=1;
start(vid);
frame = getsnapshot(vid);
imshow(frame);
ROIdish = [158, 27, 946, 946];
h = imellipse(gca, ROIdish);
disp('Doubled click')
wait(h);
maskbw = createMask(h);
stop(vid);
vid.ROIPosition = ROIdish;
close all
while n ~= 0
    n = input('Add the fish then press 0');
end

% get parameters for image processing
[bwthresh, imT, small, maskbw] = parameters_image_processing(vid, ROIdish, maskbw);

%% Initialisation - filtering ---------------------------------------------
if im == 0 % no image recording
    [time_lost_ini,angle_ini,centroids_ini,framerate_ini]...
        = initialization_without_im(xin,yin,ini_tot,ini_rec,textureOpacityini,...
        vid,window,mask_white,srcRect,screenXpixels,screenYpixels,ifi,black,vbl,...
        imT,bwthresh,small);
elseif im == 1 % image recording
    [time_lost_ini,angle_ini,centroids_ini,framerate_ini,...
        fish_ini_im] = initialization_with_im(xin,yin,ini_tot,ini_rec,textureOpacityini,...
        vid,window,mask_white,srcRect,screenXpixels,screenYpixels,ifi,black,vbl,...
        imT,bwthresh,small);
end

%% Experiment ------------------------------------------------------
if im == 0 % no image recording
    [time_lost,angle,angle_cum,angle_illum,luminosity,centroids,...
        framerate_rec,f_lost] = experiment_sin_without_im(xin,yin,ang_thresh,...
        recording_time_sec,time_adapt,lum_sin,...
        vid,window,mask_white,srcRect,screenXpixels,screenYpixels,ifi,black,vbl,...
        waitframes,imT,bwthresh,small);
elseif im == 1 %image recording
    [time_lost,angle,angle_cum,angle_illum,luminosity,centroids,...
        framerate_rec,f_lost,error_head,fish_im] = experiment_sin_with_im(xin,yin,ang_thresh,...
        recording_time_sec,time_adapt,lum_sin,...
        vid,window,mask_white,srcRect,screenXpixels,screenYpixels,ifi,black,vbl,...
        waitframes,imT,bwthresh,small);
end

%% Save data
%create the folder
disp('Saving')
formatOut = 'yy-mm-dd';
day = datestr(now,formatOut);
name  = sprintf('fish%d',f);
directory='F:\Projects\Julie\data\utilisables_lum_sinus';
directory = fullfile(directory,day,name);
mkdir(directory);


%save data
D.fish = fish_state;
D.dateTime = date;

D.cameraFeatures.Gain = src.Gain;
D.cameraFeatures.Shutter = src.Shutter;
D.cameraFeatures.Exposure = src.Exposure;
D.cameraFeatures.ROIdish = ROIdish;

D.imageProcessing.adaptthresh = 0.62;
D.imageProcessing.bwthresh = bwthresh;
D.imageProcessing.small = small;
D.imageProcessing.mask = imT;

D.initialization.timetot = ini_tot;
D.initialization.timerec = ini_rec;
D.initialization.angleThreshold = ang_thresh;
D.initialization.timeLostIni = time_lost_ini;
D.initialization.angleIni = angle_ini;
D.initialization.coordinatesIni = centroids_ini;
D.initialization.framerateIni = framerate_ini;

D.experiment.timeth = recording_time_sec;
D.experiment.timeLost = time_lost;
D.experiment.adapt = time_adapt;
D.experiment.angle = angle;
D.experiment.angleCum = angle_cum;
D.experiment.angleFiltered = angle_illum;
D.experiment.luminosity = luminosity;
D.experiment.coordinates = centroids;
D.experiment.framerate = framerate_rec;
%D.experiment.f_lost = f_lost;

data = 'data';
save(fullfile(directory, [data name]),'D');
if im == 1
    im_bn = 'fish_ini_seq';
    save(fullfile(directory, [data im_bn]), 'fish_ini_im');
    im_bn = 'fish_seq';
    save(fullfile(directory, [data im_bn]), 'fish_im');
    for i = 1:size(fish_ini_im,4)
        name_ini = sprintf('movie_ini_seq_%d',i);
        make_movie2(uint8(fish_ini_im(:,:,:,i)),directory,name_ini);
    end
    for i = 1:size(fish_im,4)
        name_exp = sprintf('movie_exp_seq_%d',i);
        make_movie2(uint8(fish_im(:,:,:,i)),directory,name_exp);
    end
end

close all
disp('End')