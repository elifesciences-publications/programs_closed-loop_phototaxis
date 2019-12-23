%% Comments
% Display squares 100*100 pixels and a red cross which is the middle of the projector screen 


%% Initialisation physchtoolbox
close all;
%clearvars;
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
red = [1 0 0];
% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Calibration
e = 1;
i=0;
a = yCenter-i*100;
while a > 0
    Screen('DrawLines', window, [0 screenXpixels; a a], e, black);
    i=i+1;
    a = yCenter-i*100;
end
i=0;
a = yCenter+i*100;
while a < screenYpixels
    Screen('DrawLines', window, [0 screenXpixels; a a], e, black);
    i=i+1;
    a = yCenter+i*100;
end
i=0;
a = xCenter-i*100;
while a > 0
    Screen('DrawLines', window, [a a; 0 screenXpixels], e, black);
    i=i+1;
    a = xCenter-i*100;
end
i=0;
a = xCenter+i*100;
while a < screenXpixels
    Screen('DrawLines', window, [a a; 0 screenXpixels], e, black);
    i=i+1;
    a = xCenter+i*100;
end

Screen('DrawLines', window, [xCenter xCenter; 0 screenYpixels], e, red);
Screen('DrawLines', window, [0 screenXpixels; yCenter yCenter], e, red);
%Screen('DrawDots', window, [xCenter yCenter+100], 10, [1 0 0], [], 2);

Screen ('Flip', window);