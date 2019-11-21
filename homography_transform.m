function [img_homography,img_mask] = homography_transform(img1,img_a_incruster,H,X1,Y1)
[h1,w1,p1] = size(img1);
[h2,w2,~] = size(img_a_incruster);
s=1;

img_homography = img1;
%%figure, imshow(uint8(img_homography));

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
            
            %v3;
            %sprintf("valeur de i %d",y);
            %sprintf("valeur de j %d",x);
            %%if (v2(1,1) > w2 || v2(1,1) > w2 < 1 || v2(2,1) > h2 || v2(2,1) < 1) 
            % copier le pixel v2(1,1) et v2(2,1) de l'image a inscruster
            % dans l'autre
            
            img_homography(y,x,:) = img_a_incruster(v3(2,1),v3(1,1),:);
            img_mask(y,x,:) = 255;
        
            
       
        end
        
       
    end

end

end
