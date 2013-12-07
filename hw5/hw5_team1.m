function hw5()
    
    global image;

    % Reading your image
    image = imread('http://192.168.1.100/snapshot.cgi?user=admin&pwd=&resolution=32&rate=0');
    
    resolution = size(image); 
	resolution = resolution(1:2);

    figure(1);
    imshow(image);
    
    P = getpts(1);
    
    sumr = 0;
    sumb = 0;
    sumg = 0;
    
    for i = P
       
        C = getColor(uint64(i(1)), uint64(i(2)), image);
        
        C(1)
        C(2)
        C(3)
        
        sumr = sumr + C(1);
        sumg = sumg + C(2);
        sumb = sumb + C(3);
        
    end
    
    sumr;
    sumg;
    sumb;
    
    r = sumr/length(P)
    g = sumg/length(P)
    b = sumb/length(P)
    
    
    % Color Threshold
    ct = 75;
    
    
    
    pixel_mask = (r-ct) < image (:,:,1) & image(:,:,1) < (r+ct) & ...
                 (g-ct) < image (:,:,2) & image(:,:,2) < (g+ct) & ...
                 (b-ct) < image (:,:,3) & image(:,:,3) < (b+ct);


    imshow(pixel_mask);

    
end
