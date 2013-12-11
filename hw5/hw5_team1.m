function hw5(serPort)

    global port;    
    port = serPort;
    FWD_VEL = 0.07;
    FWD_DIST = 0.01;
    ANGLE_VEL = 0.11;
    TURN_DEGREE = 1;

    % Reading your image
%     image = imread('http://192.168.1.100/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0');
    image = imread('http://192.168.1.102/img/snapshot.cgi?');
    
    resolution = size(image); 
	resolution = resolution(1:2);
    center = resolution(2)/2;

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    
    rgb = impixel(image, c, r); 
    pixel_mask = create_mask(image, rgb);
    [~, ~, area, ~] = find_largest_blob(pixel_mask);
    goal_area = area
    prev_area = area;
    prev_x = center;
    speed = 0;
    turn = 0;
    
    while(1)
%       image = imread('http://192.168.1.100/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0');
        image = imread('http://192.168.1.102/img/snapshot.cgi?');
        pixel_mask = create_mask(image, rgb);
        [x, y, area, box] = find_largest_blob(pixel_mask);
        figure(1);
        imshow(image);
        figure(2);
        imshow(pixel_mask);
        
        if (box == -1)
            fprintf('Cant find object\n');
            continue;
        end
        
        if (x > .8*center) && (x < 1.2*center)
            turn = 0;
        elseif (x < .8*center) 
%             && (prev_x < .8*center)
            fprintf('Turn left\n');
            turn = ANGLE_VEL;
        elseif (x > 1.2*center) 
%             && (prev_x > 1.2*center)
            fprintf('Turn right\n');
            turn = -ANGLE_VEL;
        end
        
        if (area > goal_area*.8) && (area < goal_area*1.2)
            speed = 0;
        elseif (area < goal_area*.8) 
%             && (prev_area < goal_area*.8)
            fprintf('Move forward\n');
            speed = FWD_VEL;
        elseif (area > goal_area*1.2) 
%             && (prev_area > goal_area *1.2)
            fprintf('Move backward\n');
            speed = -FWD_VEL;
        end
        
        SetFwdVelAngVelCreate(port, speed, turn);
        
        prev_x = x;
        prev_area = area;
        rectangle('Position',box, 'EdgeColor', 'r')
        rectangle('Position',[x,y,5,5],'FaceColor','g', 'Curvature',1)
    end
end

function [center_x, center_y, area, box] = find_largest_blob(pixel_mask)
    blobs = regionprops(pixel_mask, 'Area', 'BoundingBox', 'Centroid');

    largest = 0;
    index = 0;
    for i = 1:size(blobs,1)
        if (blobs(i).Area>largest)
            largest = blobs(i).Area;
            index = i;
        end
    end
    largest
    if (largest > 750)    
        box = blobs(index).BoundingBox;
        center = blobs(index).Centroid;
        area = blobs(index).Area;
        center_x = center(1);
        center_y = center(2);
    else
        box = -1;
        area = -1;
        center_x = -1;
        center_y = -1;
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
