clear, close all, clc
addpath('./images');

%% APPLICATION HOMOGRAPHY
%[img_homography, img_mask] = homography_transform('img7.jpg','img6.jpg'); %Projection
% [img_homography] = homography_transform2('img7.jpg'); %Extraction

% il y a une rotation sur la gestion des vecteurs !!!!

% figure,imshow('img7.jpg');

npoints = 4;

a = Image('uttower1.jpg');

b = Image('uttower2.jpg');


[H] = homographyEstimate(a.getCoordx,a.getCoordy,b.getCoordx,b.getCoordy,npoints);


b.Homography(H);

%a.Homography(inv(H));

b.fusion(a);

b.affichage();

