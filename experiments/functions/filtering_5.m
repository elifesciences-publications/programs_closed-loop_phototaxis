%function []=filtering_5(angle)

%% Comments
% Last version of the angle fitlering used for the stereovisual experiment

%% Code
close all

d=0;
ang_thresh = 5;
nb_seq=1;
percPm = 0.6;
lum_exp = luminosity_sinus(percPm);
angle_pframe = [0 0];

for i = 1:max(size(angle))
    
    if i == 1
        angle_cum(nb_seq,1) = angle(1);
    else
        angle_pframe(1) = angle_pframe(2);
        d = angle(nb_seq,i)-angle(nb_seq,i-1);
        angle_pframe(2) = angle_per_frame(d);
        if abs(angle_pframe(2)) > 150
            angle_pframe(2) = angle_pframe(1);
        end
        angle_cum(nb_seq,i) = angle_cum(nb_seq,i-1) + angle_pframe(2);
    end
    % ----- smooth angle_pframe(i+1) according to its absolute value -----
    if i > 5
        d = angle_cum(nb_seq,i) - mean(angle_cum(nb_seq,i-4:i-1));
        if abs(d) < ang_thresh
            angle_cum_filtered(nb_seq,i) = angle_cum_filtered(nb_seq,i-1);
        else
            angle_cum_filtered(nb_seq,i) = mean(angle_cum(nb_seq,i-1:i));
        end
        
        % ----- change illumination -----
        dang = angle_illum(nb_seq,i-1) - mean(angle_cum_filtered(nb_seq,i-4:i-1));
        if abs(dang) < 2*ang_thresh
            angle_illum(nb_seq,i) = angle_illum(nb_seq,i-1);
        else
            angle_illum(nb_seq,i) =  mean(angle_cum_filtered(nb_seq,i-1:i));
        end
        
        if angle_illum(nb_seq,i)-angle_illum(nb_seq,i-1) ~= 0
            d = mod(angle_illum(nb_seq,i),360);
            d = 180 - abs(180 - d);
            luminosity(nb_seq,i) = interp1(lum_exp(:,1),lum_exp(:,2),d);
            opacity = interp1(lum_exp(:,2),lum_exp(:,3),luminosity(nb_seq,i));
            if opacity < 0
                opacity = 0;
            elseif opacity > 1
                opacity = 1;
            end
        else
            luminosity(nb_seq,i) = luminosity(nb_seq,i-1);
        end
        
    else %if i < 4
        d = mod(angle_cum(nb_seq,1),360);
        d = 180 - abs(180 - d);
        luminosity(nb_seq,i) = interp1(lum_exp(:,1),lum_exp(:,2),d);
        angle_cum_filtered(nb_seq,i) = mean(angle_cum(nb_seq,1:i));
        angle_illum(nb_seq,i) = angle_cum_filtered(nb_seq,i);
    end
end

figure
hold on
%plot(angle_cum,'b')
plot(angle_cum_filtered,'r')
plot(angle_illum,'k')