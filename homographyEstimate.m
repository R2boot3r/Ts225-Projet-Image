function [H] = homographyEstimate(X1,Y1,X2,Y2,npoints)

M2 = [X2 Y2]
B = reshape(M2',[8,1])

A = zeros(2*npoints);

for i=1:npoints
   A(2*i-1,:) = [X1(i,1), Y1(i,1), 1,0,0,0, -X1(i,1)*X2(i,1), -X2(i,1)*Y1(i,1)];
   A(2*i,:) = [0, 0, 0, X1(i,1), Y1(i,1), 1, -X1(i,1)*Y2(i,1), -Y1(i,1)*Y2(i,1)];
end 


H = [A\B;1];
%%H = A^-1
H = reshape(H,[3,3]).';

end
