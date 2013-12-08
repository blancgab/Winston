function light_follow(image)
    % Reading your image
    resolution = size(image); 
	resolution = resolution(1:2);

    subplot(1,2,1); imshow(image);
    
    brightness = 230;
    
    pixel_mask = brightness < image (:,:,1) & ...
                 brightness < image (:,:,2) & ...
                 brightness < image (:,:,3);
    
    figure(1);
    subplot(1,2,1); imshow(image);             
    subplot(1,2,2); imshow(pixel_mask);
    
    
    light_regions = regionprops(pixel_mask, 'Area', 'Centroid');
    
    num_of_pts = length(light_regions);
    
    X = zeros(1,num_of_pts);
    Y = zeros(1,num_of_pts); 
    
    for i = 1:num_of_pts
                
        if (light_regions(i).Area > 10)
        
            p = light_regions(i).Centroid;
        
            X(i) = p(1);
            Y(i) = p(2);
        end
        
    end
    
    % Remove Zero Values
    X=X(X~=0);
    Y=Y(Y~=0);
    
    X_avg = mean2(X);
    
    avg_line_x = [X_avg X_avg]
    avg_line_y = [min(Y) max(Y)]
    
    figure(2); 
    scatter(X,Y); hold on;

%     coeff = polyfit(X,Y,1);    
%     Y2 = coeff(1)*X + coeff(2);
%     plot(X,Y2);
    
    
    plot(avg_line_x,avg_line_y);

end
