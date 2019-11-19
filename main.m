clear, close all, clc
addpath('./images');
load('images/img_1.jpeg');


img1 = double(imread('img_2.png'));
figure, imshow(uint8(img1));
[X1,Y1] = ginput(4);


img_a_incruster = double(imread('img_a_incruster.jpeg'));
figure, imshow(uint8(img_a_incruster));
[h2,w2,~] = size(img_a_incruster);
%[X2,Y2] = ginput(4);

 X2 = [0; w2; w2; 0];
 Y2 = [0; 0; h2; h2];

npoints = 4;

%% ESTIMATION MATRICE HOMOGRAPHY
[H,A] = homographyEstimate(X1,Y1,X2,Y2,npoints);

%% APPLICATION HOMOGRAPHY
img_homography = homography_transform(img1,img_a_incruster,H);

figure, imshow(uint8(img_homography));

% il y a une rotation sur la gestin des vecteurs !!!!
