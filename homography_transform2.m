function [image_recadre] = homography_transform2(img1,largeur,hauteur,H)
%[h1,w1,~] = size(img1);

s=1;
image_recadre = zeros(hauteur,largeur,3);
%%figure, imshow(uint8(img_homography));





for y=1:hauteur
    for x=1:largeur
        v1 = [x;y;s];
        v2 = H\v1;
        v3 = round(v2/v2(3,1));          
        image_recadre(y,x,:) = img1(v3(2,1),v3(1,1),:);       
        
    end
end
end
