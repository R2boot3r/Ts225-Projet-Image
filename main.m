clear, close all, clc;
addpath('./imageavion');


%% APPLICATION HOMOGRAPHY
npoints = 4;
a = Image('1.jpg');
b = Image('2.jpg');
[H] = homographyEstimate(a.getCoordx,a.getCoordy,b.getCoordx,b.getCoordy,npoints);
b.Homography(H);

b.fusion(a);
b.affichage();

c = Image('3.jpg');

b.getnewginput();

[H2] = homographyEstimate(b.getCoordx,b.getCoordy,c.getCoordx,c.getCoordy,npoints);
toc

c.Homography(H2);
b.fusion(c);

b.modifmask();

b.affichage();