function entropy_follow(step_size)

    image = imread('hallway_image.jpg');

    % Reading your image
    resolution = size(image); 
	resolution = resolution(1:2);
    w = resolution(2)
    h = resolution(1)
    %res(1) is y res(2) is x

    brightness = 230;
    
    pixel_mask = brightness < image (:,:,1) & ...
                 brightness < image (:,:,2) & ...
                 brightness < image (:,:,3);

   
    entropies = [0]
    xvals = [0]

    for(x=1:step_size:w)

        xvals = [xvals x]
        entropies = [entropies entropy(pixel_mask(:, x:step_size))]
    end 

    entropies = entropies(find(entropies,1,'first'), :)
    xvals = xvals(find(xvals, 1, 'first'), :)



    %avg_bright = mean(pixel_mask);
    
    %[m, index]  = max(avg_bright);
        
    %x_br_line = [index index];
    %y_br_line = [0 resolution(1)];   
    
    %figure(1);
    %subplot(1,2,1); imshow(image);             
    %subplot(1,2,2); imshow(pixel_mask);
    %hold on; plot(x_br_line,y_br_line);
    

    %[m, index]  = max(avg_bright); %check that m is certain value, else


    %x_br_line = [index index]; 
    %y_br_line = [0 resolution(1)];  %draw from bottom to top  
    
    %figure(2); 
    %imshow(image);hold on;
    %plot(x_br_line,y_br_line);


end



%how much to move and in which dir
