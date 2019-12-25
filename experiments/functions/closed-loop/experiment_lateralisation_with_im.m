function [time_lost,angle,angle_cum,angle_filtered,centroids,head,...
    framerate_rec,error_head,fish_im] = experiment_lateralisation_with_im(xin,yin,ang_thresh,...
    recording_time_sec,time_adapt,lum_lin,ang_t,width,r,...
    vid,window,mask_white,srcRect,screenXpixels,screenYpixels,ifi,black,vbl,...
    waitframes,imT,bwthresh,small)

%% Comments
% Code for the spatio-temporal experiment (lateralisation). Record the images
% Inputs -----
% xin, yin: coordiantes of the inner circle the fish has to cross to record
% ang_thresh: angle threshold for the filtering
% recording_time_sec: time of the experiment (sec)
% time_adapt: time of the adaptation after the OMR (sec)
% vid, window, mask_white, srcRect, screenXpixels, sxreenYpixels, ifi,
% black, vbl,waitframes: parameters for the projector
% imT: blured image for the background substraction
% bwthresh: binarized threshold (0 to 1=255/255)
% small: minimum sized to keep in the the binarized image
% Outputs -----
% time_lost: matrix which records the time when the fish was outside
% the recording zone (1st colum: starting time of the lost sequence, 2nd
% colum: ending time of the lost sequence, 3rd column: lenght of the lost
% sequence (sec)
% angle: real_angle of the fish (between 0-360). Each line represents
% one sequence
% angle_cum: angle of the sequence, angle0 random
% angle_illum: angle used for the illumination
% luminosity: illumination level
% centroids: matrix(2,?,nb_recording_sequence): 1st dimension: (x,y) of the fish
% centroids, 2nd dimension: number of frame, 3rd dimension: sequence
% framerate_rec: matrix(4,nb_recording_sequence). 1st column: starting time
% of the sequence, 2nd column: ending time of the sequence, 3rd column:
% framerate, 4th column: number of frame in the sequence
% error_head: index of the frame when the code did a mistake, inversed the
% head and the tail

% need the functions:
% image_processing, OMR_radial_f, get_orientation_distmap, fishangle,
% lateralisation_f, angle_per_frame

%% Code
stop(vid)
% for the opacity
opacity0 = lum_lin(end,2)/2;

% ----- Parameters -----
nb_seq = 1;
time_lost = zeros(1,3);
framerate_rec = zeros(1,4);
fish_im = [];
angle = 0;
centroids = zeros(1,2);
head = zeros(1,2);
angle_pframe = zeros(1,2);
angle_cum = round(rand*360);
angle_filtered = 0;
d=0;
h=0;
t=0;
error_head = [];

i=0;
disp('Recording')
w = waitbar(0,'Recording');
start(vid);
timeStamprec = 0;

% ----- Start recording -----
while timeStamprec < recording_time_sec
    i = i+1;
    trigger(vid)
    [img, timeStamprec0] = getdata(vid);
    [n, area, fish] = image_processing(img, imT, bwthresh,small);
    waitbar(timeStamprec/recording_time_sec,w)
    timeStamprec = timeStamprec0;
    
    % ----- if the fish is at the edge -----
    while n ~= 1 || area < small+5
        disp('Fish lost')
        framerate_rec(nb_seq,2) = timeStamprec0; %ending time of a sequence
        framerate_rec(nb_seq,3) = i/(framerate_rec(nb_seq,2)-framerate_rec(nb_seq,1));
        framerate_rec(nb_seq,4) = i;
        in = 0;
        time_lost(nb_seq,1) = timeStamprec0; %starting time of fish lost period
        frameCounter = 0;
        % ----- wait until fish returns in the center -----
        while in == 0 && timeStamprec < recording_time_sec
            timerVal = tic;
            OMR_radial_f(vbl,frameCounter,screenXpixels,screenYpixels,window,ifi,black);
            frameCounter = frameCounter + 1;
            trigger(vid)
            [img, timeStamprec] = getdata(vid);
            [n, area, fish] = image_processing(img, imT, bwthresh,small);
            waitbar(timeStamprec/recording_time_sec,w)
            if area > small + 10
                [fraw, fcol] = find(fish);
                cy = round((max(fraw)-min(fraw))/2 + min(fraw));
                cx = round((max(fcol)-min(fcol))/2 + min(fcol));
                in = inpolygon(cx,cy,xin,yin);
            end
            ti = toc(timerVal);
            if ti < 2*ifi
                pause(2*ifi-ti);
            end
        end
        % ----- adaptation -----
        if in == 1 && timeStamprec < recording_time_sec - time_adapt
            if time_adapt > 0
                Screen('Drawtexture', window, mask_white, srcRect,[],[],[], 1);
                Screen('Flip', window);
                pause(time_adapt)
            end
            trigger(vid)
            [img, timeStamprec] = getdata(vid);
            [n, area, fish] = image_processing(img, imT, bwthresh,small);
            waitbar(timeStamprec/recording_time_sec,w)
            if n==1 && area > small +10
                disp('New recording sequence')
                Screen('Drawtexture', window, mask_white, srcRect,[],[],[], opacity0);
                Screen('Flip', window);
                time_lost(nb_seq,2) = timeStamprec; %ending time of fish lost period + adap
                time_lost(nb_seq,3) = time_lost(nb_seq,2) - time_lost(nb_seq,1); % fish lost period + adap
                i = 1;
                nb_seq = nb_seq+1;
            end
        elseif in == 1 && timeStamprec >= recording_time_sec - time_adapt %end recording
            time_lost(nb_seq,2) = timeStamprec; %ending time of fish lost period + adap
            time_lost(nb_seq,3) = time_lost(nb_seq,2) - time_lost(nb_seq,1); % fish lost period + adap
            pause(recording_time_sec - timeStamprec)
            timeStamprec = recording_time_sec;
            n=1;
            area = small + 10;
        elseif timeStamprec >= recording_time_sec %end_recording
            time_lost(nb_seq,2) = timeStamprec; %ending time of fish lost period + adap
            time_lost(nb_seq,3) = time_lost(nb_seq,2) - time_lost(nb_seq,1); % fish lost period + adap
            n=1;
            area = small + 10;
        end
        if timeStamprec >= recording_time_sec
            n=1;
            area = small + 10;
        end
    end
    % ----- End adaptation if fish has been on the edge -----
    
    % ----- If the fish is in the center -----
    % ----- get angle, filter, change illumination -----
    if timeStamprec < recording_time_sec && n==1
        hcomp = h;
        tcomp = t;
        [h, t, angle(nb_seq,i)] = get_orientation_distmap(fish);
        if i == 1
            framerate_rec(nb_seq,1) = timeStamprec; %starting time for a new sequence
            if mod(nb_seq,2) == 1
                angle_cum(nb_seq,1) = round(rand*360);
            else
                angle_cum(nb_seq,1) = mod(angle_cum(nb_seq-1,1)+180,360);
            end
        else
            angle_pframe(1) = angle_pframe(2);
            d = angle(nb_seq,i)-angle(nb_seq,i-1);
            angle_pframe(2) = angle_per_frame(d);
            if abs(angle_pframe(2)) > 150  % maybe error in detecting the head
                if abs(h(1)-tcomp(1)) <= 2 && abs(h(2)-tcomp(2)) <= 2
                    %if the head has the same coordinates than the previous
                    %tail, +-2, error
                    angle_pframe(2) = angle_pframe(1);
                    error_head = [error_head; nb_seq i];
                end
            end
            angle_cum(nb_seq,i) = angle_cum(nb_seq,i-1) + angle_pframe(2);
        end        
        
        %----- smooth angle_pframe(i+1) according to its absolute value -----
        if i > 4
            d = angle_cum(nb_seq,i) - mean(angle_cum(nb_seq,i-3:i-1));
            if abs(d) < ang_thresh
                angle_filtered(nb_seq,i) = angle_filtered(nb_seq,i-1);
            else
                angle_filtered(nb_seq,i) = mean(angle_cum(nb_seq,i-1:i));
            end
            
            if angle_filtered(nb_seq,i)-angle_filtered(nb_seq,i-1) ~= 0
                angle_lat = angle_filtered(nb_seq,i) + (angle(nb_seq,1) - angle_cum(nb_seq,1));
                lateralisation_f(screenXpixels, screenYpixels, window,...
                    h,angle_lat,ang_t,width,r,lum_lin,vbl,waitframes,ifi);
            end
            
        else %if i < 5
            angle_filtered(nb_seq,i) = mean(angle_cum(nb_seq,1:i));
            angle_lat = angle_filtered(nb_seq,i) + (angle(nb_seq,1) - angle_cum(nb_seq,1));
            lateralisation_f(screenXpixels, screenYpixels, window,...
                h,angle_lat,ang_t,width,r,lum_lin,vbl,waitframes,ifi);
        end
        cx = round(abs(h(1)+t(1))/2);
        cy = round(abs(h(2)+t(2))/2);
        centroids(i,:,nb_seq) = [cx cy];
        head(i,:,nb_seq) = h;
        fish_im(:,:,i,nb_seq) = uint8(crop_image(cx,cy,imT-img,fish,40));
    elseif timeStamprec >= recording_time_sec
        if framerate_rec(nb_seq,2) == 0
            framerate_rec(nb_seq,2) = timeStamprec; %ending time of a sequence
            framerate_rec(nb_seq,3) = i/(framerate_rec(nb_seq,2)-framerate_rec(nb_seq,1));
            framerate_rec(nb_seq,4) = i;
        end
    end
end

disp('End recording')
stop(vid)
close all