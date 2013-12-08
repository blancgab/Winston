function hw5()
    
    global image;

    % Reading your image
    image = imread('http://192.168.1.100/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0');
    
    resolution = size(image); 
	resolution = resolution(1:2);

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    
    rgb = impixel(image, c, r);

%     r = sum(rgb(:,1))/length(rgb)
%     g = sum(rgb(:,2))/length(rgb)
%     b = sum(rgb(:,3))/length(rgb)
%     
%     % Color Threshold
%     ct = 25;
%     
%     pixel_mask = (r-ct) < image (:,:,1) & image(:,:,1) < (r+ct) & ...
%                  (g-ct) < image (:,:,2) & image(:,:,2) < (g+ct) & ...
%                  (b-ct) < image (:,:,3) & image(:,:,3) < (b+ct);

    max_r = max(rgb(:,1))
    max_g = max(rgb(:,2))
    max_b = max(rgb(:,3))
    
    min_r = min(rgb(:,1))
    min_g = min(rgb(:,2))
    min_b = min(rgb(:,3))
    
    % Color Threshold
    ct = 5;
    
    pixel_mask = min_r-ct < image (:,:,1) & image(:,:,1) < max_r+ct & ...
                 min_g-ct < image (:,:,2) & image(:,:,2) < max_g+ct & ...
                 min_b-ct < image (:,:,3) & image(:,:,3) < max_b+ct;



    figure(2);
    imshow(pixel_mask);

    
end
