function door_RGB()
    
    image = imread('http://192.168.1.102/img/snapshot.cgi?');

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    rgb1 = impixel(image, c, r);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    image = imread('http://192.168.1.102/img/snapshot.cgi?');

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    rgb2 = impixel(image, c, r); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    image = imread('http://192.168.1.102/img/snapshot.cgi?');

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    rgb3 = impixel(image, c, r); 
    
    
    max_r = max([max(rgb1(:,1)), max(rgb2(:,1)), max(rgb3(:,1))]);
    max_g = max([max(rgb1(:,2)), max(rgb2(:,2)), max(rgb3(:,2))]);
    max_b = max([max(rgb1(:,3)), max(rgb2(:,3)), max(rgb3(:,3))]);
    
    min_r = min([min(rgb1(:,1)), min(rgb2(:,1)), min(rgb3(:,1))]);
    min_g = min([min(rgb1(:,2)), min(rgb2(:,2)), min(rgb3(:,2))]);
    min_b = min([min(rgb1(:,3)), min(rgb2(:,3)), min(rgb3(:,3))]);
    
    
    
    while(1)
        image = imread('http://192.168.1.102/img/snapshot.cgi?');
        
        % Color Threshold
        ct = 5;

        pixel_mask = min_r-ct < image (:,:,1) & image(:,:,1) < max_r+ct & ...
                     min_g-ct < image (:,:,2) & image(:,:,2) < max_g+ct & ...
                     min_b-ct < image (:,:,3) & image(:,:,3) < max_b+ct;
    
        
        gray = rgb2gray(image);
        horizontal_edge = imfilter(gray,[-1 0 1]);
                 
                 
                 
                 
        figure(1);
        imshow(image);
        
        figure(2);
        imshow(pixel_mask);
        
        figure(3);
        imshow(horizontal_edge);
        
        figure(4);
        imshow(pixel_mask .* horizontal_edge);
    end
    
    
    
    
end

function pixel_mask = create_mask(image, rgb)

    max_r = max(rgb(:,1));
    max_g = max(rgb(:,2));
    max_b = max(rgb(:,3));
    
    min_r = min(rgb(:,1));
    min_g = min(rgb(:,2));
    min_b = min(rgb(:,3));
    
    
end