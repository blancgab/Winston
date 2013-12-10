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
             
    brights   = double.empty;
    entropies = double.empty;
    xvals     = double.empty;

    for (x=1:step_size:w)

        xvals     = [xvals x]
        entropies = [entropies entropy(image(:, x:step_size))]
        brights   = [brights mean(pixel_mask(:, x:step_size))]

    end 
    
    

end
