function [image_recadre] = homography_transform2(img_)
%[h1,w1,~] = size(img);
%% Initialisation
s=1;
npoints = 4;

%% Lecture de l'image & acquisition des points
img = double(imread(img_));
figure, imshow(uint8(img));
[X1,Y1] = ginput(4);

[hauteur, largeur, ~] = size(img);
X2 = [1; largeur; largeur; 1];
Y2 = [1; 1; hauteur; hauteur];


%% Estimation de la matrice d'homographie
H = homographyEstimate(X1,Y1,X2,Y2,npoints);


%% Extraction de la nouvelle image
image_recadre = zeros(hauteur,largeur,3);
for y=1:hauteur
    for x=1:largeur
        v1 = [x;y;s];
        v2 = H\v1;
        v3 = round(v2/v2(3,1));          
        image_recadre(y,x,:) = img(v3(2,1),v3(1,1),:);          
    end
end
figure, imshow(uint8(image_recadre));

end
