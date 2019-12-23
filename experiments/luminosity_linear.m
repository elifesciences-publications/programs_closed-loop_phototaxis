function [lum_lin]=luminosity_linear(percPm)
%% Comments
% Calculate the opacity for having an linear luminosity profile
%Inputs -----
% percPm = pourcentage of the light intensity for the maximum of the
% profile
%Outputs ------
% lum_lin: matrix, 1st column: angle, 2nd column: luminosity, 3rd column: opacity 

%% Code
load('/Users/karp/Documents/PhD/Projects/Behaviorfish/PhototaxisFreeSwim/Data/Calibration/op_lum_121117.mat')

Pm = max(lum_op_cal(:,2));
ang = linspace(0,180,181);

lum_lin(:,1) = ang;
lum_lin(:,2) = ang/180*Pm*percPm;
lum_lin(:,3) = interp1(lum_op_cal(:,2),lum_op_cal(:,1),lum_lin(:,2));
lum_lin(181,3) = 1;

% plot(lum_lin(:,3),lum_lin(:,2),'r')
% figure
% plot(lum_lin(:,1),lum_lin(:,2))