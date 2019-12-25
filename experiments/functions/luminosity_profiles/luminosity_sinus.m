function [lum_sin] = luminosity_sinus(percPm)
%% Comments
% Calculate the opacity for having an sinusoidal luminosity profile
%Inputs -----
% percPm = pourcentage of the light intensity for the maximum of the
% profile
%Outputs ------
% lum_sin: matrix, 1st column: angle, 2nd column: luminosity, 3rd column: opacity 

%% Code
load ('/Users/karp/Documents/PhD/Projects/Behaviorfish/PhototaxisFreeSwim/Data/Calibration/op_lum_121117.mat')
Pm = max(lum_op_cal(:,2));
% CHANGE :
Pm = 378;
ang = linspace(0,180,181);

lum_sin(:,1) = ang;

lum_sin(:,2) = percPm*Pm*sin(ang*pi/(2*180));
lum_sin(:,3) = interp1(lum_op_cal(:,2),lum_op_cal(:,1),lum_sin(:,2));

%plot(lum_sin(:,1),lum_sin(:,2))