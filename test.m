function [xlargeur,ylargeur] = test(X1,Y1,X2,Y2)

    xmax = max(max(X1,X2));
    xmin = min(min(X1,X2));
    ymax = max(max(Y1,Y2));
    ymin = min(min(Y1,Y2));

    xlargeur = abs(xmin-xmax);
    ylargeur = abs(ymin-ymax);

end
