
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
    TURN_VEL  = 0.15;
    EPSILON   = 30;
    TOLERANCE = 200;
    HEIGHT    = resolution(1);
    WIDTH     = resolution(2);
          
    state = 'hallway_follow';
    
    %% Running
    while(1)
        
        image = imread(cam_ip);
       
        %% Calculate Brightness and Entropy Line
                
        brightness = 230;
        pixel_mask = brightness < image (:,:,1) & ...
                     brightness < image (:,:,2) & ...
                     brightness < image (:,:,3);
        
        STEP = 10;        
        
        Q = floor(WIDTH/STEP);
        
        brights   = zeros(1,Q+1);
        entropies = zeros(1,Q+1);
        xvals     = zeros(1,Q+1);
        
        grayscale = rgb2gray(image);        
        
        i = 1;
        
        for(x=1:STEP:(WIDTH-STEP))
            xvals(i)     = x;
            entropies(i) = entropy(grayscale(:, x:x + STEP));
            brights(i)   = mean2(pixel_mask(:, x:x + STEP));
                        
            i = i+1;
        end      
        
        xvals     = xvals(1 : find(xvals,1,'last'))
        entropies = entropies(1 : find(entropies,1,'last'))
        brights   = brights(1 : find(brights,1,'last'))

        [max_brightness, b_line] = max(brights);        
        [max_entropy, e_line]    = max(entropies);        

        br = xvals(b_line)+STEP/2;
        en = xvals(e_line)+STEP/2;
        
        x_br_line = [br br];
        y_br_line = [0 HEIGHT];
        
        x_en_line = [en en];
        y_en_line = [0 HEIGHT];
                
        %% Calculations
        
        center_offset = WIDTH/2 - b_line;
        fprintf('center offset is: %.2f\n',center_offset);
        found_door = false;
        
%         bump = BumpLeft || BumpFront || BumpRight;

%         if bump
%             fprintf('BUMP\n');
%         end
        
        %% Plotting

        subplot(1,2,1); imshow(image);             
        subplot(1,2,2); imshow(pixel_mask);
        hold on; plot(x_br_line,y_br_line);
        plot(x_en_line,y_en_line,'r');
        drawnow;
        
        %% State
                      
        switch state
            
            case 'find_hallway'
                
                fprintf('searching for hallway\n');  
                
                
                if(max_brightness > TOLERANCE)
                    fprintf('found hallway\n');  
                    state = 'hallway_follow';
                end
                
            case 'hallway_follow'
                                
%                 if (max_brightness < TOLERANCE)
%                     
%                     fprintf('cannot find hallway\n'); 
%                     state = 'find_hallway';
%                 else
                if (found_door)
                    
                    fprintf('found door, turning towards it\n');
                    state = 'door_follow';
                    
                elseif (abs(center_offset) <= EPSILON)
                    s = sign(center_offset);
                        
                    if (s == 1)
                        fprintf('turning counter-clockwise\n');
                    else
                        fprintf('turning clockwise\n');
                    end
                        
%                     turnAngle(port, FWD_VEL, 10*s)
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