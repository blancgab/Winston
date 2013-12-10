
function hallway_follow(serPort, local_ip)
    
    global port;
    port = serPort;

    %% Initialization
%     cam_ip = ['http://192.168.1.',local_ip,'/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0']

    cam_ip = 'hallway_image.jpg';
    
    image = imread(cam_ip);    
    resolution = size(image); 
	resolution = resolution(1:2);
    
    figure(1); drawnow;
    subplot(1,2,1); imshow(image);
    
    FWD_VEL   = 0.2;
    TURN_VEL  = 0.15;
    CENTER    = resolution(2)/2;
    EPSILON   = 30;
    TOLERANCE = 200;
    HEIGHT    = resolution(2);
    WIDTH     = resolution(1)
          
    state = 'find_hallway';
    
    %% Running
    while(1)
        
        image = imread(cam_ip);
       
        %% Calculate Brightness Line
        brightness = 230;
        pixel_mask = brightness < image (:,:,1) & ...
                     brightness < image (:,:,2) & ...
                     brightness < image (:,:,3);

        avg_bright = mean(pixel_mask);
        
        [max_brightness, b_line]  = max(avg_bright);

        x_br_line = [b_line b_line];
        y_br_line = [0 resolution(1)];
        
        %% Calculations
        
        center_offset = CENTER - b_line;
        fprintf('center offset is: %.2f\n',center_offset);
        found_door = false;
        
        bump = BumpLeft || BumpFront || BumpRight;
        
        if bump
            fprintf('BUMP\n');
        end
        
        %% Plotting

        figure(1);        
        subplot(1,2,1); imshow(image);             
        subplot(1,2,2); imshow(pixel_mask);
        hold on; plot(x_br_line,y_br_line);
        
        %% State
                      
        switch state
            
            case 'find_hallway'
                
                fprintf('searching for hallway\n');  
                
                
                if(max_brightness > TOLERANCE)
                    fprintf('found hallway\n');  
                    state = 'hallway_follow';
                end
                
            case 'hallway_follow'
                                
                if (max_brightness < TOLERANCE)
                    
                    fprintf('cannot find hallway\n'); 
                    state = 'find_hallway';
                elseif (found_door)
                    
                    fprintf('found door, turning towards it\n');
                    state = 'door_follow';
                    
                elseif (abs(center_offset) <= EPSILON)
                        s = sign(center_offset);
                        
                        if (s == 1)
                            fprintf('turning counter-clockwise\n');
                        else
                            fprintf('turning clockwise\n');
                        end
                        
%                       turnAngle(port, FWD_VEL, 10*s)
                end
                                
                
            case 'door_follow'

                if bump
                    state = 'knock';
                end
                
            case 'knock'
                
                % reverse, wait then go forward
                
                state = 'final';
                
            case 'failure'
                SetFwdVelAngVelCreate(port, 0, 0 );
                fprintf('ERROR: Unable to reach goal\n');
                return;
                
            case 'final'
                fprintf('DONE\n');
                SetFwdVelAngVelCreate(port, 0, 0 );
                return;
        end    
          
    end
    
end

function update_plot(h)
    set(0,'CurrentFigure',h)
end