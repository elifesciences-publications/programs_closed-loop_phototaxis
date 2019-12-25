function [time_lost_ini,angle_ini,centroids_ini,framerate_ini,...
    fish_ini_im] = initialization_with_im(xin,yin,ini_tot,ini_rec,textureOpacityini,...
    vid,window,mask_white,srcRect,screenXpixels,screenYpixels,ifi,black,vbl,...
    imT,bwthresh,small)

%% Comments
% Initialization of the stereovisual and spatio_temporal experiment. Record
% also the images (binarized and croped)
% Inputs -----
% xin, yin: coordiantes of the inner circle the fish has to cross to record
% ini_tot: time of the initialisation (sec)
% ini_rec: time of the recordin (sec)
% textureOpacityini: opacity (illumination) of the screen during the
% initialisation (1, high intensity)
% vid, window, mask_white, srcRect, screenXpixels, sxreenYpixels, ifi,
% black, vbl: parameters for the projector
% imT: blured image for the background substraction
% bwthresh: binarized threshold (0 to 1=255/255)
% small: minimum sized to keep in the the binarized image
% Outputs -----
% time_lost_ini: matrix which records the time when the fish was outside
% the recording zone (1st colum: starting time of the lost sequence, 2nd
% colum: ending time of the lost sequence, 3rd column: lenght of the lost
% sequence (sec)
% angle_ini: real_angle of the fish (between 0-360). Each line represents
% one sequence
% centroids_ini: matrix(2,?,nb_recording_sequence): 1st dimension: (x,y) of the fish
% centroids, 2nd dimension: number of frame, 3rd dimension: sequence
% framerate_ini: matrix(4,nb_recording_sequence). 1st column: starting time
% of the sequence, 2nd column: ending time of the sequence, 3rd column:
% framerate, 4th column: number of frame in the sequence
% fish_ini_im: recording image (80,80,?,nb_recording_sequence): 3rd dimension: number of
% frame, 4th dimension: sequence. The 80 is the width input for the
% crop_image function, can be changed directly in this code, line

% need the functions:
% image_processing, OMR_radial_f, get_orientation_distmap, fishangle,
% crop_image

%% Code
disp('Recording initialisation')

Screen('Drawtexture', window, mask_white, srcRect,[],[],[], textureOpacityini);
Screen('Flip', window);
pause(ini_tot - ini_rec);

%recording for angle threshold
timeStamprec = 0;
i = 0;
angle_ini = [];
fish_ini_im = [];
time_lost_ini = [];
framerate_ini = zeros(1,4);
centroids_ini = [];

nb_seq_ini = 1;
w = waitbar(0,'Recording Initialisation');

start(vid)

while timeStamprec < ini_rec
    i = i + 1;
    trigger(vid)
    [img, timeStamprec] = getdata(vid);
    [n, area, fish_ini] = image_processing(img, imT, bwthresh,small);
    n1(nb_seq_ini,i)=n;
    waitbar(timeStamprec/ini_rec,w)
    
    % ----- if the fish is at the edge -----
    if n ~= 1 || area < small+5
        disp('Fish ini lost')
        time_lost_ini(nb_seq_ini,1) = timeStamprec;
        if i ~= 1
            framerate_ini(nb_seq_ini,2) = timeStamprec; %ending time of a sequence
            framerate_ini(nb_seq_ini,3) = i/(framerate_ini(nb_seq_ini,2)-framerate_ini(nb_seq_ini,1));
            framerate_ini(nb_seq_ini,4) = i;
            f_im(:,:,nb_seq_ini) = fish_ini;
        end
        in = 0;
        frameCounter = 0;
        % ----- wait until the fish returns in the center -----
        while in == 0 && timeStamprec < ini_rec
            timerVal = tic;
            OMR_radial_f(vbl,frameCounter,screenXpixels,screenYpixels,window,ifi,black);
            frameCounter = frameCounter + 1;
            trigger(vid)
            [img, timeStamprec] = getdata(vid);
            [n, area, fish_ini] = image_processing(img, imT, bwthresh,small);
            waitbar(timeStamprec/ini_rec,w)
            if area > small + 10
                [fraw, fcol] = find(fish_ini);
                cy = round((max(fraw)-min(fraw))/2 + min(fraw));
                cx = round((max(fcol)-min(fcol))/2 + min(fcol));
                in = inpolygon(cx,cy,xin,yin);
            end
            ti = toc(timerVal);
            if ti < 2*ifi
                pause(2*ifi-ti);
            end
        end
        time_lost_ini(nb_seq_ini,2) = timeStamprec;
        time_lost_ini(nb_seq_ini,3) = time_lost_ini(nb_seq_ini,2) - time_lost_ini(nb_seq_ini,1);
        trigger(vid)
        [img, timeStamprec] = getdata(vid);
        waitbar(timeStamprec/ini_rec,w)
        disp('Fish ini recording')
        if timeStamprec < ini_rec
            i = 1;
            nb_seq_ini = nb_seq_ini+1;
            [n, area, fish_ini] = image_processing(img, imT, bwthresh,small);
        end
    end
    
    % ----- Fish found -----
    if timeStamprec < ini_rec && n == 1
        if i ==1
            Screen('Drawtexture', window, mask_white, srcRect,[],[],[], textureOpacityini);
            Screen('Flip', window);
            framerate_ini(nb_seq_ini,1) = timeStamprec; %starting time for a new sequence
        end
        [h, t, angle_ini(nb_seq_ini,i)] = get_orientation_distmap(fish_ini);
        if i > 1 && abs(angle_ini(nb_seq_ini,i)-angle_ini(nb_seq_ini,i-1)) > 150
            angle_ini(nb_seq_ini,i) = angle_ini(nb_seq_ini,i);
        end
        cx = round(abs(h(1)+t(1))/2);
        cy = round(abs(h(2)+t(2))/2);
        centroids_ini(i,:,nb_seq_ini) = [cx cy];
        fish_ini_im(:,:,i,nb_seq_ini) = uint8(crop_image(cx,cy,imT-img,fish_ini,80));       
    elseif timeStamprec >= ini_rec
        if framerate_ini(nb_seq_ini,1) > 0
            framerate_ini(nb_seq_ini,2) = timeStamprec; %ending time of a sequence
            framerate_ini(nb_seq_ini,3) = i/(framerate_ini(nb_seq_ini,2)-framerate_ini(nb_seq_ini,1));
            framerate_ini(nb_seq_ini,4) = i;
        end
    end
end
% ----- angle_ini is analyzed at the end of the recording, before saving
% data -----
stop(vid)

disp('End initialisation')