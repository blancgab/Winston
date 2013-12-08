function hw5()
    % Reading your image
    image = imread('http://192.168.1.102/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0');
    
    resolution = size(image); 
	resolution = resolution(1:2);

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    
    rgb = impixel(image, c, r);    
    while(1)
        image = imread('http://192.168.1.102/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0');
        pixel_mask = create_mask(image, rgb);
        blobMeasurements = regionprops(pixel_mask, 'Area', 'BoundingBox', 'Centroid');
        
        largest = 0;
        index = 0;
        for i = 1:size(blobMeasurements,1)
            if (blobMeasurements(i).Area>largest)
                largest = blobMeasurements(i).Area;
                index = i;
            end
        end
        box = blobMeasurements(index).BoundingBox;
        center = blobMeasurements(index).Centroid
        area = blobMeasurements(index).Area
        x = center(1);
        y = center(2);
        
        figure(1);
        subplot(1,2,1); imshow(image);
        subplot(1,2,2); imshow(pixel_mask);
        rectangle('Position',box, 'EdgeColor', 'r')
        rectangle('Position',[x,y,5,5],'FaceColor','g', 'Curvature',1)
    end
end

function pixel_mask = create_mask(image, rgb)

    max_r = max(rgb(:,1));
    max_g = max(rgb(:,2));
    max_b = max(rgb(:,3));
    
    min_r = min(rgb(:,1));
    min_g = min(rgb(:,2));
    min_b = min(rgb(:,3));
    
    % Color Threshold
    ct = 5;
    
    pixel_mask = min_r-ct < image (:,:,1) & image(:,:,1) < max_r+ct & ...
                 min_g-ct < image (:,:,2) & image(:,:,2) < max_g+ct & ...
                 min_b-ct < image (:,:,3) & image(:,:,3) < max_b+ct;
end
