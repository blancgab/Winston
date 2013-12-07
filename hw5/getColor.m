function PIXEL = getColor(x,y,image)

    r = image(x,y,1);
    g = image(x,y,2);
    b = image(x,y,3);

    PIXEL = [r g b];
    
end
