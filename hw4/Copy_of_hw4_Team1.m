% HW4 - Team #1

% Gabriel Blanco - gab2135
% Adam Reis - ahr2127
% Sophie Chou - sbc2125

%%
function hw4_Team1(serPort)
    % Given a input file 'input3' of a room with obstacles, our function
    % runs a python script that expands all of the obstacles, finds their
    % convex hull and then runs Djikstra's algorithm to find the shortest
    % path. It then outputs that path as a series of points in an output
    % file, which this Matlab function reads.
    
    % The function then turns and moves to each of those points, one at a
    % time until it reaches the final point, terminating gracefully.
    
    %  ============ NOTE! ============
    % 
    %  When the Python script is run, it 
    %  prints out the Visibility graph first.
    %  In order to run the rest of the Matlab
    %  function, you have to close the window
    %  with the visibility graph.
    %
    %  ============ NOTE! ============


    global port;    
    port = serPort;

    %% Generate Path

    clc;
%     system('python path_finder.py input');
    outputFileID = fopen('output');
    A = textscan(outputFileID, '%f %f');
    fclose(outputFileID);
    
    pathX = cell2mat(A(1));
    inv_pathY = cell2mat(A(2));
    pathY = -1*inv_pathY;

    for i = 1:length(pathX),
        fprintf('(%.2f, %.2f)\n',pathX(i), pathY(i));
    end

    %% Variable Declaration
    
    glob_x = pathX(1);
    glob_y = pathY(1);
    glob_theta = 0;
    
    FWD_VEL = 0.25;
    ANGLE_VEL = 0.1;
    THRESHOLD = .05;
    TURN_DEGREE = 2;

    X = pathX(1);
    Y = pathY(1);
    
    point = 1;
    final = length(pathX);
    state = 'turn';
  
    %% Main Loop
    
    while 1

        %% Odometry
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);
        Wall    = WallSensorReadRoomba(port);                % Poll for Wall Sensor
        d_dist  = DistanceSensorRoomba(port);                % Poll for Distance delta
        d_theta = AngleSensorRoomba(port);                   % Poll for Angle delta
        
        glob_theta = glob_theta + d_theta;
        glob_x     = glob_x + cos(glob_theta) * d_dist;
        glob_y     = glob_y + sin(glob_theta) * d_dist;                      

        
        %% Plotting function
        
        X = [X,glob_x];
        Y = [Y,glob_y];
                
        figure(2);
        plot(X,Y);
        xlim([-4,11]);
        ylim([-4,4]);
        set(gca,'xtick',-4:11);
        set(gca,'ytick',-4:4);
        grid;
        axis square;
        
        drawnow; 
        
        %% State
              
        switch state
            
            % Turn towards next point
            case 'turn'
                
                if(point==final)
                    state = 'final';
                else
                    % Current angle of Roomba
                    cur_angle = mod(glob_theta+pi,2*pi)-pi;
                    
                    % Angle from current position to next point
                    nxt_x = pathX(point+1); 
                    nxt_y = pathY(point+1);
                    dx = nxt_x - glob_x;
                    dy = nxt_y - glob_y;
                    d_theta = mod(atan2(dy,dx)+pi,2*pi)-pi;
                
                    % Difference between current angle & next angle
                    turn_angle = d_theta - cur_angle;
                
                    fprintf('turn: t = %.2f; d = %.2f; c = %.2f;\n',turn_angle, d_theta, cur_angle);

%                   CODE THAT I'M TRYING OUT
%                     if (abs(turn_angle) < THRESHOLD)
%                         state = 'move';                                      
%                     else
%                         turnAngle(port,ANGLE_VEL,turn_angle);                    
%                     end

                    turnAngle(port,ANGLE_VEL,(turn_angle*180/pi));
                    state = 'move';
%                     if (abs(turn_angle) < THRESHOLD)
%                         state = 'move';                                      
%                     elseif (turn_angle > 0)
%                         turnAngle(port,ANGLE_VEL,TURN_DEGREE);
%                     else
%                         turnAngle(port,ANGLE_VEL,-TURN_DEGREE);                        
%                     end

                end               
                
            % Move to the next point
            case 'move'
                
                if (BumpRight || BumpLeft || BumpFront)
                    fprintf('BUMP\n');
                end
                
                % Travel along path (angle has been preset) to next point
                next_x = pathX(point + 1);
                next_y = pathY(point + 1);

                if(glob_x >= next_x)     % If we've moved enough
                    point = point + 1;   % Go to next point
                    
                    state = 'turn';
                else
                    SetFwdVelAngVelCreate(port, FWD_VEL, 0 );
                    state = 'move';
                end
                
            % Fail State    
            case 'failure'
                SetFwdVelAngVelCreate(port, 0, 0 );
                fprintf('ERROR: Unable to reach goal\n');
                return;
                
            % Final State
            case 'final'
                fprintf('DONE\n');
                SetFwdVelAngVelCreate(port, 0, 0 );
                return;
        end
        
    end
    
end

