function [M2b] = homography(point,H)

s=1;
M1b = [ point(1,1)*s;
        point(1,2)*s;
        s];

M2b = H*M1b;
sh = M2b(3,1);
M2b(1,1)= M2b(1,1)/sh;
M2b(2,1) = M2b(2,1)/sh;


end

