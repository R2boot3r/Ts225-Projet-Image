function [img_homography] = homography_transform(img1,img2,H)
[h1,w1] = size(img1);
[h2,w2] = size(img2);
s=1;

for i=1:w1
    for j=1:h1
        v1 = [i;j;s];
        v2 = H*v1;
        v3 =v2/v2(3,1);
        if (v2(1,1) > w2 || v2(1,1) > w2 < 1 || v2(2,1) > h2 || v2(2,1) < 1) 
            continue;
        else
            img_homography=img1(i,j);
        end
    end

end
end
