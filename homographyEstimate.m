function [H] = homographyEstimate(M1,M2, npoints)


A = zeros(2*npoints);

for i=1:npoints
   A(2*i-1,:) = [M1(i,1), M1(i,2), 1,0,0,0, -M1(i,1)*M2(i,1), -M2(i,1)*M1(i,2)];
   A(2*i,:) = [0,0,0, M1(i,1), M1(i,2), 1, -M1(i,1)*M2(i,2), -M2(i,2)*M1(i,2)];
end 

B = reshape(M2,[8,1]); 

H = A\B;
H = [H;1];
H = reshape(H,[3,3]);

end

