clear, closeall, clc;
addpath('./imageavion');

StructImg = dir(fullfile('/','*.*));
strcat structimg.name
%% APPLICATION HOMOGRAPHY
%[img_homography, img_mask] = homography_transform('img7.jpg','img6.jpg'); %Projection
% [img_homography] = homography_transform2('img7.jpg'); %Extraction

% il y a une rotation sur la gestion des vecteurs !!!!

% figure,imshow('img7.jpg');

npoints = 4;

a = Image('1.jpg');

b = Image('2.jpg');


tic


[H] = homographyEstimate(a.getCoordx,a.getCoordy,b.getCoordx,b.getCoordy,npoints);
toc



b.Homography(H);

toc
%b.fusion(a);
b.fusion(a);

c = Image('3.jpg');

b.getnewginput();

[H2] = homographyEstimate(b.getCoordx,b.getCoordy,c.getCoordx,c.getCoordy,npoints);
toc

c.Homography(H2);
b.fusion(c);

b.modifmask();

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
