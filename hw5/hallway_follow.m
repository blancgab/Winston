function hallway_follow(local_ip, serPort, velocity, epsilon)

    cam_ip = ['http://192.168.1.',local_ip,'/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0']

    image = imread(cam_ip);    
    resolution = size(image); 
	resolution = resolution(1:2);
    
    fig1 = figure(1); drawnow;
    subplot(1,2,1); imshow(image);
  
    while(1)
        
        image = imread(cam_ip);
       
        %% Calculate Brightness Line
        brightness = 230;
        pixel_mask = brightness < image (:,:,1) & ...
                     brightness < image (:,:,2) & ...
                     brightness < image (:,:,3);

        avg_bright = mean(pixel_mask);
        
        [m, index]  = max(avg_bright);

        x_br_line = [index index];
        y_br_line = [0 resolution(1)];    

        %% Path Finding (SOPHIE'S CODE)
        offset = (resolution(2) / 2) - index %how far off is the max index from midpoint?

        if(abs(offset) <= epsilon)
            turnAngle(serPort, velocity, 10)
        end

        
        %%
        
        
        %% Plotting

        figure(1);        
        subplot(1,2,1); imshow(image);             
        subplot(1,2,2); imshow(pixel_mask);
        hold on; plot(x_br_line,y_br_line);      
          
    end
    
end

function update_plot(h)
    set(0,'CurrentFigure',h)
end