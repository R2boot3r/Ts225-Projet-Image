clear, close all, clc
addpath('./images');

%% APPLICATION HOMOGRAPHY
%[img_homography, img_mask] = homography_transform('img7.jpg','img6.jpg'); %Projection
% [img_homography] = homography_transform2('img7.jpg'); %Extraction

% il y a une rotation sur la gestion des vecteurs !!!!

% figure,imshow('img7.jpg');

npoints = 4;

a = Image('img7.jpg');

b = Image('img6.jpg');


[H] = homographyEstimate(a.getCoordx,a.getCoordy,b.getCoordx,b.getCoordy,npoints);



b.Homography(H);
% % a.Homography(inv(H));
%c.affichage();
%b.affichage();