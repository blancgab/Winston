% HW2 - Team #1

% Adam Reis - ahr2127

% Gabriel Blanco - gab2135

%%
function hw2_Team1(serPort)

    % Bug 2 algorithm application implemented on an iRobot.
    % 
    % The structure of our second homework is based on the TA's solution to
    % the first homework assignment. This function uses the Bug 2 algorithm
    % to navigate the Roomba to a position 10 meters in front of where it
    % starts (configurable with the 'goal_y' variable.  It also plots the x and y
    % positions as it goes, in a seperate figure. The orientation data is
    % also collected, but for performance reasons, it only gets plotted
    % after the roomba reaches the final or fail states. 
    %
    % Note: the orientation graph plots theta over time in polar
    % coordinates, with orientation being thata, and time being rho.  This
    % means that discrete time is represented by concentric rings about the
    % origin -- for example a robot going in circles would result in a
    % spiral graph.
    %
    % Double Note:  because we based our movement and coordinate system on
    % the TA code for assignment 1, we assume that those aspects will
    % perform correctly in the environment (bluetooth speed, operating 
    % system, flooring, etc) for which it was originally written.  We
    % didn't want to mess up the calibration for the test robot in the test
    % environment, so the only changes we made were to implement the Bug 2
    % algorithm.
    
    global port;
    
    port = serPort;

    %% Variable Declaration
    
    clc;
    
%%%%%%%%%%%%%%%%%%%%%
    roomba_d = 0.34;
    boundary = roomba_d;
    temp_m = 0;
    m_direct = 1; % vertical = 1, horizontal = 0
    bumptime = tic;
%%%%%%%%%%%%%%%%%%%%%
    
    
    
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);

    % Goal Distance
    goal_y    = 65;
    
    % Current Position
    glob_x     = 0;
    glob_y     = 0;
    glob_theta = 0;             % Theta represents the change in angle from
                                % the starting angle. 0 represents "up",
                                % along the y-axis
    
    % First Hit Position
    first_hit_x = 0;
    first_hit_y = 0;
    first_hit_angle = 0;
    
    % Velocity
    velocity = 0.15;
    angular_vel = 0.1;
    
    % Thresholds
    hit_threshold = 0.2;
   
    
    % Init State
    state = 1; 
    i = 1;
    hit   = zeros(1,20);
    leave = zeros(1,20);    

    % Plot X and Y
    figure(2);

    X = [0];
    Y = [0];
%     THETA = [0];
%     RHO   = [1];
%     count = 2;
            
    %% Main Loop
    
    while 1
        fprintf('%.6f',mod(glob_theta,2*pi)*180/pi);
        fprintf('\n');
        
        %% Odometry
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);
        Wall    = WallSensorReadRoomba(port);                % Poll for Wall Sensor
        d_dist  = DistanceSensorRoomba(port);                % Poll for Distance delta
        d_theta = AngleSensorRoomba(port);                   % Poll for Angle delta
        
        % Keep tracking the position and angle before the first hit
        prev_glob_x = glob_x;
        prev_glob_y = glob_y;
        prev_glob_theta = glob_theta;
        
        glob_theta = glob_theta + d_theta;
        
        glob_x     = glob_x - sin(glob_theta) * d_dist;
        glob_y     = glob_y + cos(glob_theta) * d_dist;                    
        
        % Keep tracking the position and angle after the first hit
        first_hit_angle = first_hit_angle + d_theta;
        first_hit_x     = first_hit_x + sin(first_hit_angle) * d_dist;
        first_hit_y     = first_hit_y + cos(first_hit_angle) * d_dist;

        % Directional Booleans
        after_goal   = (glob_y > goal_y);
        before_goal  = ~after_goal; 
        mglob_theta = mod(glob_theta,2*pi);
        facing_left = (0 < mglob_theta) && (mglob_theta < pi);        
        facing_right  = ~facing_left;
        
        hit_distance = sqrt(first_hit_x^2 + first_hit_y^2);        

        
        %% Plotting function
        
        X = [X,glob_x];
        Y = [Y,glob_y];
%         THETA = [THETA,glob_theta];        
%         RHO = [RHO,count];
%         
%         count = count + 1;
        
        figure(2);
        plot(X,Y);
        xlim([-5,5]);
        ylim([-1,10]);
        set(gca,'xtick',-5:5);
        set(gca,'ytick',-1:10);
        grid;
        axis square;
        
        drawnow;
                
        %% State 
        
        switch state
            
            case 0 % turn to new_angle
                turnAngle(port,0.15,90);
                
                theta = mod(glob_theta,2*pi);
                prev_theta = mod(prev_glob_theta,2*pi);
                if ( (theta <= new_angle && prev_theta > new_angle) || (theta >= new_angle && prev_theta < new_angle) )
                    SetFwdVelAngVelCreate(port, velocity, 0 );
                    state = 1;
                end 
            
            % Move Forward
            case 1
                                                
                SetFwdVelAngVelCreate(port, velocity, 0);
                
%                 if HitBoundarySquare(glob_x,glob_y,glob_theta,boundary) % reached a boundary
%                     state = 0;

                if HitBoundary(glob_x,glob_y,glob_theta,boundary)
                   if toc(bumptime)>0.4

                       theta = mod(glob_theta,2*pi)*180/pi;

                       % If you're square  
                        cur_dir = Direction(glob_theta);
                        if cur_dir ~= 'x'

                            fprintf('Hit Boundary.  cur_dir = %s\n',cur_dir);
%                             m_direct = ~m_direct;
    %                         if cur_dir == 'u'
    %                             temp_m = glob_y;
    %                         elseif cur_dir == 'l'
    %                             temp_m = glob_x;
    %                         elseif cur_dir == 'd'
    %                             temp_m = glob_y;
    %                         elseif cur_dir == 'r'                        
    %                             temp_m = glob_x;
    %                             boundary = boundary + roomba_d; 
    %                         end
    %                         turnAngle(port,0.15,90);
                        end
                        if cur_dir~='l' && cur_dir~='r'
                            if glob_y>boundary
                                fprintf('glob_y: %.2f\n',glob_y);
                                fprintf('boundary: %.2f\n',boundary);
                                
                                fprintf('turn to the left\n');
                                turnAngle(port,0.15,90-theta)
                                temp_m = glob_y;
                                m_direct = 0;
                                bumptime = tic;
                            elseif glob_y<-boundary
                                fprintf('turn to the right\n');
                                turnAngle(port,0.15,270-theta)
                                temp_m = glob_y;
                                m_direct = 0;
                                bumptime = tic;
                            end
                        end
                        if cur_dir~='u' && cur_dir~='d'

                            if glob_x>boundary
                                fprintf('turn up\n');
                                turnAngle(port,0.15,-theta)
                                boundary = boundary + roomba_d;
                                temp_m = glob_x;
                                m_direct = 1;
                                bumptime = tic;
                            elseif glob_x<-boundary
                                fprintf('turn down\n');
                                turnAngle(port,0.15,180-theta)
                                temp_m = glob_x;
                                m_direct = 1;
                                bumptime = tic;
                            end

%                             if cur_dir == 'r'
%                                 boundary = boundary + roomba_d;
%                             end
                        end
                   end
                end  
                
                if (BumpRight || BumpLeft || BumpFront)
                    state = 2; % -> Wall Follow
                    first_hit_angle = 0;
                    first_hit_x = 0;
                    first_hit_y = 0; 
                    
                    fprintf('HIT #%i\n',i);

                    hit(i) = glob_y;
                end
            
            % Wall Follow (Before leaving the threshold of the hit point)
            case 2
                WallFollow(velocity, angular_vel, BumpLeft, BumpFront, BumpRight, Wall);
                if (hit_distance > hit_threshold)
                    state = 3; % Leave threshold
                end
            
            % Wall Follow (After leaving the threshold of the hit point)
            case 3
                WallFollow(velocity, angular_vel, BumpLeft, BumpFront, BumpRight, Wall);

                
                if HitBoundary(glob_x,glob_y,glob_theta,boundary)
                    state = 1;
                    continue;
                end
                
                if m_direct
                    crossed = (glob_x <= temp_m && prev_glob_x > temp_m) || (glob_x >= temp_m && prev_glob_x < temp_m);
                else
                    crossed = (glob_y <= temp_m && prev_glob_y > temp_m) || (glob_y >= temp_m && prev_glob_y < temp_m);
                end
                
                if crossed
                    
                    fprintf('ENCOUNTERED M-LINE\n');
                    
%                     % Have you reached the goal?
%                 	if (abs(glob_y - goal_y) < goal_threshold)
%                         state = 'final';
                    
                    % Else, are you closer than the current hit?
                    if (glob_y - hit(i) > 0)
                        fprintf('facing left: %.f\n',facing_left);
                        fprintf('facing right: %.f\n',facing_right);
                        fprintf('after_goal: %.f\n',after_goal);
                        fprintf('before_goal: %.f\n',before_goal);
                        
                        
                        if (after_goal && facing_left)
                            fprintf('Facing Left, Unobstructed\n');
                        elseif (after_goal && facing_right)
                            fprintf('Facing Right, Obstructed\n');
                        end
                        
                        if (before_goal && facing_right)
                            fprintf('Facing Right, Unubstructed\n');
                        elseif (before_goal && facing_left)
                            fprintf('Facing Left, Obstructed\n');
                        end
                            
                        % And the path is unimpeded?
                        if ((after_goal && facing_left) || (before_goal && facing_right))                               
                            
                            leave(i) = glob_y;
                            fprintf('LEAVE #%i\n',i);
                            
                            i = i+1;                            
                            
                            state = 4; % Turn to the m-line
                        else
                            fprintf('PATH OBSTRUCTED\n');
                        end
                        
                    % You are back at the previous hit point
                    elseif ( abs(glob_y - hit(i)) < hit_threshold )                        
                        state = 'failure';
                    end
                    
                end
            % Turn to face the M-Line    
            case 4  
                
                if (before_goal)
                    turnAngle(port, angular_vel, -glob_theta);
                    
                    if ( (glob_theta <= 0 && prev_glob_theta > 0) || (glob_theta >= 0 && prev_glob_theta < 0) )
                        SetFwdVelAngVelCreate(port, velocity, 0 );
                        state = 1;
                    end 
                    
                elseif (after_goal)
                    
                    prev_angle = mod(prev_glob_theta,2*pi);
                    angle = mod(glob_theta,2*pi);
                    
                    turnAngle(port, angular_vel, pi-angle);
                    if ( (angle <= pi && prev_angle > pi) || (angle >= pi && prev_angle < pi) )
                        SetFwdVelAngVelCreate(port, velocity, 0 );
                        state = 1;
                    end 
                    
                end
            
            % Fail State: M-Line is unreachable    
            case 'failure'
                SetFwdVelAngVelCreate(port, 0, 0 );
                fprintf('ERROR: Unable to reach goal\n');
                
                figure(3);
                polar(THETA,RHO);                
                
                return;
            
            % Final State: Reached the goal
            case 'final'
                SetFwdVelAngVelCreate(port, 0, 0 );
                OccupancyGrid(BUMP_X, BUMP_Y);
                
                % Plot the orientation over time. Rho is time, theta is the
                % angle
%                 figure(3);
%                 polar(THETA,RHO);
                
                return;
                
        end
        
    end
    
end

function returnval = HitBoundarySquare(cur_x,cur_y,glob_theta,boundary)
    theta = mod(glob_theta,2*pi);
    
    d = Direction(theta);
    
    if d == 'u' || d == 'd'
        if -boundary < cur_y && cur_y < boundary
            returnval = 0;
        else
            returnval = 1;
        end
    elseif d == 'l' || d == 'r'
        if -boundary < cur_x && cur_x < boundary
            returnval = 0;
        else
            returnval = 1;
        end
    end
    
end

function returnval = HitBoundary(cur_x,cur_y,glob_theta,boundary)
%     theta = mod(glob_theta,2*pi);
    
    if -boundary < cur_y && cur_y < boundary && -boundary < cur_x && cur_x < boundary
        returnval = 0;
    else
        returnval = 1;
    end
    
end

function direction = Direction(glob_theta)
    theta = mod(glob_theta,2*pi)*180/pi;
    if 85 < theta && theta <= 95
        direction = 'l';
    elseif 175 < theta && theta <= 185
        direction = 'd';
    elseif 265 < theta && theta <= 275
        direction = 'r';
    elseif (0 <= theta && theta < 5) || (355 < theta && theta <= 360)
        direction = 'u';
    else
        direction = 'x';
    end
end



%% Wall Following Function, copied directly from the TA Solution
% Wall follow functionality is not as accurate in practice as in the
% simulation.
function WallFollow(velocity, angular_vel, BumpLeft, BumpFront, BumpRight, Wall)

    global port;

    % Angle Velocity for different bumps
    w_bumpleft  =  2 * angular_vel;
    w_bumpfront =  3 * angular_vel;
    w_bumpright =  4 * angular_vel;
    w_nowall    = -4 * angular_vel;
    
    
    if BumpLeft || BumpFront || BumpRight
        v = 0;                              % Set Velocity to 0
    elseif ~Wall
        v = 0.25 * velocity;                % Set Velocity to 1/4 of the default
    else
        v = velocity;                       % Set Velocity to the default
    end

    
    if BumpLeft
        w = w_bumpleft;                   % Set Angular Velocity to w_bumpleft
    elseif BumpFront
        w = w_bumpfront;                  % Set Angular Velocity to w_bumpfront
    elseif BumpRight
        w = w_bumpright;                  % Set Angular Velocity to w_bumpright
    elseif ~Wall
        w = w_nowall;                     % Set Angular Velocity to w_nowall
    else
        w = 0;                            % Set Angular Velocity to 0
    end
    
    SetFwdVelAngVelCreate(port, v, w);
    
end