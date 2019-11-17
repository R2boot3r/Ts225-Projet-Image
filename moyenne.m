function Moy = moyenne(image)
    R = image(:,:,1);
    V = image(:,:,2);
    B = image(:,:,3);
    
    Moy = (R+V+B)/3;

end