%% Comments
% Visual pattern for the spatio-temporal experiment

%% Code
%% open psyxhtoolbox
[screenXpixels, screenYpixels, window, white, black, ifi] = open_psychtoolbox();

%% display
h = [476 476];
angle = 236;
width = 15;
ang_t = 40;
lum_lin = luminosity_linear(1);

% fixed parameters
Lx = round(sqrt(screenXpixels^2+screenYpixels^2)*2)+1;
Ly = round(Lx/2);
radius = Ly;
pixproj = 2.28;
xcentercam = 476;
ycentercam = 476;
xcenterproj = screenXpixels/2;
ycenterproj = screenYpixels/2;
r = 26; %radius of the circle around the fish, in mm
layer = round(Lx-r*4.93);

% fish features
% xHeadFish = h(1);
% yHeadFish = h(2);
dx = h(1) - xcentercam;
dy = h(2) - ycentercam;
xHFproj = xcenterproj - dx/pixproj;
yHFproj = ycenterproj - dy/pixproj;
ang_f = angle;

% for the triangle
ang = -mod(ang_f+180,360);
xtproj = xcenterproj - dx/pixproj - width/tan(ang_t*pi/180)*cos(ang*pi/180)*pixproj;
ytproj = ycenterproj - dy/pixproj - width/tan(ang_t*pi/180)*sin(ang*pi/180)*pixproj;
xc = xtproj + radius*cos(ang*pi/180);
yc = ytproj + radius*sin(ang*pi/180);
angles = [ang+180, mod(ang + ang_t,360), mod(ang - ang_t,360)];
anglesRad = angles*pi/180;
anglesRad = sort(anglesRad);
yPosVector = sin(anglesRad).* radius + yc;
xPosVector = cos(anglesRad).* radius + xc;
rectColor = [0 0 0];
isConvex = 1;

% for the body
body = 0;
bodyTexture = Screen('MakeTexture', window, body);
dstRect = [xtproj-Ly, ytproj-width, xtproj+Ly, ytproj+width];

% for the different illumination
mask = ones(Ly,Lx);
TextureMask = Screen('MakeTexture', window, mask);

% for the left eye
xcLeftMask = round(xtproj + Ly/2*cos((ang-90)*pi/180));
ycLeftMask = round(ytproj + Ly/2*sin((ang-90)*pi/180));
x1 = round(xcLeftMask - Lx/2);
y1 = round(ycLeftMask - Ly/2);
x2 = round(xcLeftMask + Lx/2);
y2 = round(ycLeftMask + Ly/2);
if abs(x2-x1)>Lx
    x2 = x2+(Lx - abs(x2-x1));
elseif abs(x2-x1)<Lx
    x2 = x2 + (Lx - abs(x2-x1));
end
if abs(y2-y1)>Ly
    y2 = y2+(Ly - abs(y2-y1));
elseif abs(y2-y1)<Ly
    y2 = y2 + (Ly - abs(y2-y1));
end
leftopacity = interp1(lum_lin(:,1),lum_lin(:,3),180-abs(180-mod(ang_f,360)));
dstLeft = [x1, y1, x2, y2];

% for the right eye
xcRightMask = round(xtproj + Ly/2*cos((ang+90)*pi/180));
ycRightMask = round(ytproj + Ly/2*sin((ang+90)*pi/180));
x1 = round(xcRightMask - Lx/2);
y1 = round(ycRightMask - Ly/2);
x2 = round(xcRightMask + Lx/2);
y2 = round(ycRightMask + Ly/2);
if abs(x2-x1)>Lx
    x2 = x2+(Lx - abs(x2-x1));
elseif abs(x2-x1)<Lx
    x2 = x2 + (Lx - abs(x2-x1));
end
if abs(y2-y1)>Ly
    y2 = y2+(Ly - abs(y2-y1));
elseif abs(y2-y1)<Ly
    y2 = y2 + (Ly - abs(y2-y1));
end
rightopacity = interp1(lum_lin(:,1),lum_lin(:,3),abs(180-mod(ang_f,360)));
dstRight = [x1, y1, x2, y2];

% Draw the rect to the screen

Screen('DrawTexture', window, TextureMask, dstLeft, dstLeft, ang, [], leftopacity);
Screen('DrawTexture', window, TextureMask, dstRight, dstRight, ang, [], rightopacity);
Screen('DrawTexture', window, bodyTexture, [], dstRect, ang);
Screen('FillPoly', window, rectColor, [xPosVector; yPosVector]', isConvex);
Screen('FrameOval', window, black, [xHFproj-Lx, yHFproj-Lx, xHFproj+Lx, yHFproj+Lx], layer, layer);
%Screen('DrawDots', window, [xtproj ytproj], 10, [1 1 1], [], 2);
%Screen('DrawDots', window, [xHFproj yHFproj], 3, [1 1 1], [], 2);

Screen('Flip', window);