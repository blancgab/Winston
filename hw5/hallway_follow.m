
function hallway_follow(serPort, local_ip)
    
    global port;
    port = serPort;

    %% Initialization
    
%   cam_ip = ['http://192.168.1.',local_ip,'/snapshot.cgi?user=admin&pwd=&resolution=16&rate=0'];
%   cam_ip = 'hallway_image.jpg';

    cam_ip = ['http://192.168.1.',local_ip,'/img/snapshot.cgi?'];

    image = imread(cam_ip);    
    resolution = size(image); 
	resolution = resolution(1:2);
    
    figure(1); drawnow;
    subplot(1,2,1); imshow(image);
    
    FWD_VEL   = 0.2;
    ANGLE_VEL = 0.15;
    STEP = 10;        

    HEIGHT = resolution(1);
    WIDTH  = resolution(2);
    CENTER = WIDTH/2;
          
    state = 'hallway_follow';
    SetFwdVelAngVelCreate(port, FWD_VEL, 0 );
    
    %% Running
    while(1)
        
        image = imread(cam_ip);
       
        %% Calculate Brightness
                
        brightness = 230;
        pixel_mask = brightness < image (:,:,1) & ...
                     brightness < image (:,:,2) & ...
                     brightness < image (:,:,3);
                
        Q = floor(WIDTH/STEP);
        
        brights   = zeros(1,Q);
        xvals     = zeros(1,Q);
                
        i = 1;
        
        for x=1:STEP:(WIDTH-STEP)
            
            xvals(i)     = x;
            brights(i)   = mean2(pixel_mask(:, x:x + STEP));
                        
            i = i+1;
        end      
        
        xvals   = xvals(1 : find(xvals,1,'last'));
        brights = brights(1 : find(brights,1,'last'));

        [max_brightness, b_line] = max(brights);        
        
        br = xvals(b_line)+STEP/2;
        
        x_br_line = [br br];
        y_br_line = [0 HEIGHT];
                
        %% Calculations
        
        center_offset = CENTER - br;
        fprintf('center offset is: %.2f\n',center_offset);
        found_door = false;
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);

        
        bump = BumpLeft || BumpFront || BumpRight;

        if bump
            fprintf('BUMP\n');
        end
        
        %% Plotting

        subplot(1,2,1); imshow(image);             
        subplot(1,2,2); imshow(pixel_mask);
        hold on; plot(x_br_line,y_br_line);
        drawnow;
        
        %% State
                      
        switch state
                
            case 'hallway_follow'
                                
                if (found_door)
                    
                    fprintf('found door, turning towards it\n');
                    state = 'door_follow';
                    
                else
                   
                    if (x > .8*CENTER) && (x < 1.2*CENTER)
                        turn = 0;
                    elseif (x < .8*CENTER)
                        fprintf('Turning left\n');
                        turn = ANGLE_VEL;
                    elseif (x > 1.2*center)
                        fprintf('Turning right\n');
                        turn = -ANGLE_VEL;
                    end

                    SetFwdVelAngVelCreate(port, FWD_VEL, turn);                    
                    
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