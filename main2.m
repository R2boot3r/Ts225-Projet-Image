clear, close all, clc
addpath('./images');
load('images/img_1.jpeg');


img_a_recadre = double(imread('img_5.png'));
figure, imshow(uint8(img_a_recadre));
[X1,Y1] = ginput(4);

hauteur = 400;
largeur = 600;
npoints = 4;

X2 = [1 ;largeur ; largeur;1];
Y2 = [1;1; hauteur ;hauteur ];


[H,A] = homographyEstimate(X1,Y1,X2,Y2,npoints);
img_homography = homography_transform2(img_a_recadre,largeur,hauteur,H);
figure, imshow(uint8(img_homography));