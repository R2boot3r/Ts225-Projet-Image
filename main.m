clear, close all, clc
addpath('./images');

%% APPLICATION HOMOGRAPHY
%[img_homography, img_mask] = homography_transform('img7.jpg','img6.jpg'); %Projection
% [img_homography] = homography_transform2('img7.jpg'); %Extraction

% il y a une rotation sur la gestion des vecteurs !!!!

% figure,imshow('img7.jpg');

npoints = 4;

a = Image('img6.jpg');

b = Image('img7.jpg');

tic


[H] = homographyEstimate(a.getCoordx,a.getCoordy,b.getCoordx,b.getCoordy,npoints);
toc
%[H2] = homographyEstimate(b2.getCoordx,b2.getCoordy,a2.getCoordx,a2.getCoordy,npoints);


b.Homography(H);
toc
b.fusion(a);
b.affichage();

%a.fusion(b);
% 
% b.getnewginput();
% c = Image('3.png');
% [H1] = homographyEstimate(c.getCoordx,c.getCoordy,b.getCoordx,b.getCoordy,npoints);
% 
% c.Homography(H1);
% c.fusion(b);
% c.affichage();


%b.affichage();
toc


%  a2.Homography(H2);
%  a2.fusion(b2);
%  a2.affichage();
