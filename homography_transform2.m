function [img_homography,img_mask] = homography_transform2(img1,img2)
s=1;
npoints =4;

bg_img = double(imread(img1));
figure, imshow(uint8(bg_img));
[X1,Y1] = ginput(4);
[h1,w1,p1] = size(bg_img);

img_homography = bg_img;
img_a_incruster = double(imread(img2));
figure, imshow(uint8(img_a_incruster));
[h2,w2,~] = size(img_a_incruster);
%[X2,Y2] = ginput(4);
    
X2 = [1; w2; w2; 1];
Y2 = [1; 1; h2; h2];

H = homographyEstimate(X1,Y1,X2,Y2,npoints);
xmin = round(min(X1));
xmax = round(max(X1));
ymin = round(min(Y1));
ymax = round(max(Y1));
img_mask = zeros(h1,w1,p1);

for y=ymin:ymax
    for x=xmin:xmax
        v1 = [x;y;s];
        v2 = H*v1;
        v3 = round(v2/v2(3,1));      
        if ((( 1 <= v3(2,1)) && (v3(2,1)<= h2)) && ((( 1 <= v3(1,1)) && (v3(1,1)<= w2))))

            img_homography(y,x,:) = img_a_incruster(v3(2,1),v3(1,1),:);
            img_mask(y,x,:) = 255;
        end
    end
end
figure, imshow(uint8(img_homography));
end
