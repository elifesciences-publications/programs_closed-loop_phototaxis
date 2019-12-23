function [] = center_f(screenXpixels,screenYpixels,window,mask_white,srcRect)

%% Comments
% For the stereovisual and spatio_temporal sampling experiments
% Display a red cross which is the middle of the projector
% Enable to adjust the projector center to the camera center


%% Code
red = [1 0 0];
xCenter = screenXpixels/2;
yCenter = screenYpixels/2;

Screen('Drawtexture', window, mask_white, srcRect,[],[],[], 1);
Screen('DrawLines', window, [xCenter xCenter; 0 screenYpixels], 1, red);
Screen('DrawLines', window, [0 screenXpixels; yCenter yCenter], 1, red);
Screen ('Flip', window);