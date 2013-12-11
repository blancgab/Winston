
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
    
    %figure(1); drawnow;
    %subplot(1,2,1); imshow(image);
    
    FWD_VEL   = 0.1;
    ANGLE_VEL = 0.15;
    STEP = 10;        
    
    HEIGHT = resolution(1);
    WIDTH  = resolution(2);
    CENTER = WIDTH/2;
    DOOR_THRESHOLD = 0.8
              
    state = 'hallway_follow';
    found_door = false;
    door_state = '1';
    
    SetFwdVelAngVelCreate(port, FWD_VEL, 0 );
    prev_A = 0;
    
    skip_all = false;
    turning = ''
    
    %% Running
    while(1)
        
        if ~skip_all
            image = imread(cam_ip);

            %% HSV Color Detection

            % Hue MIN/MAX
            H = [.6 .7];

            % Sat MIN/MAX
            S = [.10 .35];

            hsv = rgb2hsv(image);
            hue = hsv(:,:,1);
            sat = hsv(:,:,2);    
            val = hsv(:,:,3);            

            sv = (sat >= S(1)) & (sat <= S(2)) & ...
                 (val >= .1) & (val <= 1);

            %binarized mask for blue values
            blue = ((hue > H(1))&(hue <= H(2)))&(sv) ;         

            %% Calculate Brightness    

            brightness = 230;
            pixel_mask = brightness < image (:,:,1) & ...
                         brightness < image (:,:,2) & ...
                         brightness < image (:,:,3);

            Q = floor(WIDTH/STEP);

            brights = zeros(1,Q);
            xvals   = zeros(1,Q);

            i = 1;

            for x=1:STEP:(WIDTH - STEP)

                xvals(i)     = x;
                brights(i)   = mean2(pixel_mask(:, x:x + STEP));

                i = i+1;
            end      

            xvals   = xvals(1 : find(xvals,1,'last'));
            brights = brights(1 : find(brights,1,'last'));

            [~, b_line] = max(brights);        

            br = xvals(b_line)+STEP/2;

            x_br_line = [br br];
            y_br_line = [0 HEIGHT];

            [~,~, ~, A] =  door_find(blue)
            if (A > 6000)
                found_door = true;
            end

            %% Calculations

            center_offset = CENTER - br;
            fprintf('center offset is: %.2f\n',center_offset);
        end
        
        
        %% Plotting

        %subplot(1,2,1); imshow(image);             
        %subplot(1,2,2); imshow(blue); % imshow(pixel_mask);
        %hold on; plot(x_br_line,y_br_line);
        %drawnow;
        
        %% State
                      
        switch state
                
            case 'hallway_follow'
                fprintf('HALLWAYFOLLOW \n')
                

                if (found_door)
                    
                    fprintf('found door, turning towards it\n');
                    state = 'door_follow';
                    if br > CENTER
                        turning = 'right'
                    else
                        turning = 'left'
                    end
                    
                else
                   
                    if (br > .8*CENTER) && (br < 1.2*CENTER)
                        turn = 0;
                    elseif (br < .8*CENTER)
                        fprintf('MEOW MEOW MEOW hallway_follow')
                        fprintf('Turning left\n');
                        turn = ANGLE_VEL;
                    elseif (br > 1.2*CENTER)
                        fprintf('Turning right\n');
                        turn = -ANGLE_VEL;
                    end

                    SetFwdVelAngVelCreate(port, FWD_VEL, turn);   

                    state='hallway_follow';                
                    
                end
                                
            case 'door_follow'
                fprintf('door follow\n');
                [center_x, left_x, right_x, door_area] = door_find(blue);
                switch door_state 
                    case '1'
                        fprintf('state 1\n');
                        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);
                        bump = BumpLeft || BumpFront || BumpRight;

                        if BumpRight
                            SetFwdVelAngVelCreate(port, 0, 0);
                            turnAngle(port, ANGLE_VEL, -45);
                            state = 'knock'
                            skip_all = true;
                            continue;
                        elseif BumpLeft
                            SetFwdVelAngVelCreate(port, 0, 0);
                            turnAngle(port, ANGLE_VEL, 45);
                            state = 'knock'
                            skip_all = true;
                            continue;
                        elseif BumpFront
                            SetFwdVelAngVelCreate(port, 0, 0);
                            skip_all = true;
                            state = 'knock'
                            continue
                        end
                       
%                         if((door_area / (WIDTH * HEIGHT)) > 0.4)
%                             door_state = '2';
%                             SetFwdVelAngVelCreate(port, 0, 0); 
%                             continue;
%                         end
                        if (strcmp(turning,'left')~=0)
                            if (left_x > .85*CENTER) && (left_x < 1.15*CENTER)
                                turn = 0;
                            elseif (left_x < .85*CENTER)
                                turn = ANGLE_VEL/2;
                            elseif (left_x > 1.15*CENTER)
                                turn = -(ANGLE_VEL/2);
                            end
                        
                        else
                            if (right_x > .85*CENTER) && (right_x < 1.15*CENTER)
                                turn = 0;
                            elseif (right_x < .85*CENTER)
                                turn = ANGLE_VEL/2;
                            elseif (right_x > 1.15*CENTER)
                                turn = -(ANGLE_VEL/2);
                            end
                        end
                        
                        SetFwdVelAngVelCreate(port, FWD_VEL, turn);
                        
%                     case '2'
%                         fprintf('state 2\n');
%                         
%                         %keep traveling in the right direction
%                         if (center_x > .85*CENTER) && (center_x < 1.15*CENTER)
%                             turn = 0;
%                         elseif (center_x < .9*CENTER)
%                             turn = ANGLE_VEL;
%                         elseif (center_x > 1.1*CENTER)
%                             turn = -ANGLE_VEL;
%                         end
%                             
%                         if((door_area / (WIDTH * HEIGHT)) > .6)
%                             door_state = '3'
%                             SetFwdVelAngVelCreate(port, FWD_VEL, 0);
%                             continue;
%                         end
%                         
%                         SetFwdVelAngVelCreate(port, 0, turn);            
                        
                    case '3'
                        fprintf('state 3\n');
                        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);
                        bump = BumpLeft || BumpFront || BumpRight;

                        if bump
                            state = 'knock'
                        end
                end
                        

            case 'knock'
                
                SetFwdVelAngVelCreate(port, -(FWD_VEL*3), 0);
                pause(.1);
                SetFwdVelAngVelCreate(port, FWD_VEL*4, 0);
                pause(.2);
                SetFwdVelAngVelCreate(port, -(FWD_VEL*3), 0);
                pause(.1);
                SetFwdVelAngVelCreate(port, FWD_VEL*4, 0);
                pause(.2);
                SetFwdVelAngVelCreate(port, -(FWD_VEL*3), 0);
                pause(.1);
                BeepRoomba(port);
                SetFwdVelAngVelCreate(port, 0, 0);
                pause(5);
                
                SetFwdVelAngVelCreate(port, FWD_VEL, 0);
                
                pause(3);
                
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

function [center_x, left_x, right_x, A] = door_find(blue)
   %find door in the blue-binarized mask and get its offset
    [h, w] = size(blue);
    center = w/2;

    blobs = regionprops(blue, 'Area', 'BoundingBox', 'Centroid');
    %simply with largest Area 
    A = max([blobs.Area])
    biggest = find([blobs.Area] == A)
    center_x = blobs(biggest).Centroid(1);
    left_x = blobs(biggest).BoundingBox(1);
    right_x = blobs(biggest).BoundingBox(1)+ blobs(biggest).BoundingBox(3)

    %offset = xval - center;

    imshow(blue)
    hold on
    plot([center_x], [0 h])

end

