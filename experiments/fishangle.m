function angle = fishangle(xh, yh, xt, yt)

%% Comments
% Inputs -----
% xh,yh: fish head coordinates (or first point coordinates)
% xt,yt: fish tail coordinates (or second point coordinates)
% Output -----
% angle: angle between the horizontal and the vector (TH) (tail, head)
% angle of the fish

%% Code
if xh~=xt
    if xh>xt
        angle = atand((yt-yh)/(xh-xt));
        if angle<0
            angle = angle+360;
        end
    else
        angle = atand((yt-yh)/(xh-xt))+180;
        
    end
else % rotation de 90
    if yh>=yt
        angle = 270;
    else
        angle = 90;
    end
end
