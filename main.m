clear, close all, clc
addpath('./images');
load('images/img_1.jpeg');


img1 = moyenne(double(imread('img_1.jpeg')));
figure, imshow('img_1.jpeg');
[X1,Y1] = ginput(4);

img2 = moyenne(double(imread('img_2.jpeg')));
figure, imshow('img_2.jpeg');
[X2,Y2] = ginput(4);

[h,w] = size(img1);
npoints = 4;

%% ESTIMATION MATRICE HOMOGRAPHY
[H,A] = homographyEstimate(X1,Y1,X2,Y2,npoints);

%% APPLICATION HOMOGRAPHY
img_homography = homography_transform(img1,img2,H);


