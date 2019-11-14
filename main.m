clear, close all, clc
addpath('./images');
load('images/img_1.jpeg');
img = imread('img_1.jpeg');
[h,w] = size(img);

M1 = [1,1;
      w,1;
      1,h;
      w,h];
      
M2 = [1,1;
       w,1;
       1,2*h;
       w,h];
      
npoints = 4;

H = homographyEstimate(M1,M2,npoints);



