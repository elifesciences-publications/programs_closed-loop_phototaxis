%% Comments
% Visual pattern for the OMR radial


%% Initialisation physchtoolbox
close all;
clearvars;
sca;
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% Get the screen numbers
screens = Screen('Screens');
% Draw to the external screen if avaliable
screenNumber = max(screens);
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Set up alpha-blending for smooth (anti-aliased) lines
%Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

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
xo = screenXpixels / 2 + 30;
yo = screenYpixels / 2 + 25;

white_rect0 = zeros(4,nbCycleNeeded);
white_rect = zeros(4,nbCycleNeeded);
for i = 1: nbCycleNeeded
    white_rect0(:,i) = [xo - (2*(i-1)+0.5)*layer ; yo - (2*(i-1)+0.5)*layer ; xo + (2*(i-1)+0.5)*layer ; yo + (2*(i-1)+0.5)*layer];
end

% Drift speed cycles per second
% velocity in mm/s
velocity = 20*2;
cyclesPerSecond = velocity/mmPerCycle_exp; %velocity
waitframes = 1;
waitduration = waitframes * ifi;
shiftPerFrame = cyclesPerSecond * pixPerCycle * waitduration;
vlb = Screen('Flip', window);
frameCounter = 0;
offmask = 2*layer*(nbCycle+0.5);


while ~KbCheck
    xoffset = mod(frameCounter * shiftPerFrame, pixPerCycle);

    % Now increment the frame counter for the next loop
    frameCounter = frameCounter + 1;
    % Define our source rectangle for grating sampling
    white_rect(1,:) = white_rect0(1,:) + xoffset;
    white_rect(2,:) = white_rect0(2,:) + xoffset;
    white_rect(3,:) = white_rect0(3,:) - xoffset;
    white_rect(4,:) = white_rect0(4,:) - xoffset;

    Screen('FrameOval', window, [255 255 255], white_rect, layer, layer);
    Screen('FrameOval', window, black, [xo-offmask yo-offmask xo+offmask yo+offmask], 2*layer, 2*layer);
    %Screen('FrameOval', window, [0 0 0], black_rect, layer, layer);
    vlb = Screen('Flip', window, vlb + (waitframes - 0.5) * ifi);
end


