MyImage=imread('images/img_1.jpeg'); 
RGBsum=sum(MyImage,3);
NewImage = zeros(size(MyImage));
[row,column,depth]=size(MyImage);
 for d=1:depth
    for r=1:row 
        for c=1:column
           if  RGBsum(r,c) <= 250
               NewImage(r,c,d)=0;
           else
               NewImage(r,c,d)=MyImage(r,c,d);
           end
        end 
    end
end
imshow(uint8(NewImage));