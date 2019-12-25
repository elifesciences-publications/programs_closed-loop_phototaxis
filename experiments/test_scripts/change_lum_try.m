%% Comments
% Display a uniform screen according to the opacity selected
% opacity between 0(black) and 1(white)


%% Code
[screenXpixels, screenYpixels, window, white, black, ifi] = open_psychtoolbox();

srcRect = [0 0 screenXpixels screenYpixels];
mask_white_matrix = ones(screenYpixels, screenXpixels);
mask_white = Screen('MakeTexture', window, mask_white_matrix);
textureOpacity = 1;
Screen('Drawtexture', window, mask_white, srcRect,[],[],[], textureOpacity);
Screen('Flip', window);
