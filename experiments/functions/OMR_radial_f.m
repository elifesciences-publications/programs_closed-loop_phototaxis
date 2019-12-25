function []=OMR_radial_f(vbl,frameCounter,screenXpixels,screenYpixels,window,ifi,black)
%% Comments
% Visual pattern for the OMR radial
%Inputs -----
% screenXpixels, screenYpixels, window, vbl, waitframes, ifi, black:
% parameters

%Code
%% Projector calibration
mm_pix = 0.257;
% 167mm=650pix

%% create the different circles

%diameter of the chamber in pixels
diameterChamber = 1000;

%number of cycles: black + white in the OMR
mmPerCycle_th = 15;
nbCycle = round(diameterChamber/(2*mmPerCycle_th)*mm_pix);
nbCycleNeeded = nbCycle + 1;
layer = round(diameterChamber / (4*nbCycle));
pixPerCycle = 2*layer;
mmPerCycle_exp = pixPerCycle*mm_pix;

%center of the circle
%don't change
xo = screenXpixels / 2;
yo = screenYpixels / 2;

%black_rect = zeros(4,nbCycle);
white_rect0 = zeros(4,nbCycleNeeded);
white_rect = zeros(4,nbCycleNeeded);
for i = 1: nbCycleNeeded
    %black_rect(:,i) = [xo - (2*i-0.5)*layer ; yo - (2*i-0.5)*layer ; xo + (2*i-0.5)*layer ; yo + (2*i-0.5)*layer];
    white_rect0(:,i) = [xo - (2*(i-1)+0.5)*layer ; yo - (2*(i-1)+0.5)*layer ; xo + (2*(i-1)+0.5)*layer ; yo + (2*(i-1)+0.5)*layer];
end

% Drift speed cycles per second
velocity = 20*2;
cyclesPerSecond = velocity/mmPerCycle_exp; %velocity
waitframes = 1;
waitduration = waitframes * ifi;
shiftPerFrame = cyclesPerSecond * pixPerCycle * waitduration;
%vbl = Screen('Flip', window);
offmask = 2*layer*(nbCycle+0.5);

% display

xoffset = mod(frameCounter * shiftPerFrame, pixPerCycle);

% Define our source rectangle for grating sampling
white_rect(1,:) = white_rect0(1,:) + xoffset;
white_rect(2,:) = white_rect0(2,:) + xoffset;
white_rect(3,:) = white_rect0(3,:) - xoffset;
white_rect(4,:) = white_rect0(4,:) - xoffset;

Screen('FrameOval', window, [255 255 255], white_rect, layer, layer);
Screen('FrameOval', window, black, [xo-offmask yo-offmask xo+offmask yo+offmask], 2*layer, 2*layer);
%Screen('FrameOval', window, [0 0 0], black_rect, layer, layer);
vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);



