function hw5()
    
    global image;

    % Reading your image
    image = imread('http://192.168.1.100/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0');
    
    resolution = size(image); 
	resolution = resolution(1:2);

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    
    rgb_values = impixel(image, c, r);

    r = sum(rgb_values(:,1))/length(rgb_values)
    g = sum(rgb_values(:,2))/length(rgb_values)
    b = sum(rgb_values(:,3))/length(rgb_values)
    
    % Color Threshold
    ct = 25;
    
    pixel_mask = (r-ct) < image (:,:,1) & image(:,:,1) < (r+ct) & ...
                 (g-ct) < image (:,:,2) & image(:,:,2) < (g+ct) & ...
                 (b-ct) < image (:,:,3) & image(:,:,3) < (b+ct);

    figure(2);
    imshow(pixel_mask);

    
end
