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
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);

    % Goal Distance
    goal_y    = 8;
    
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
    goal_threshold = 0.2;    
    
    % Init State
    state = 1; 
    i = 1;
    hit   = zeros(1,20);
    leave = zeros(1,20);    

    % Plot X and Y
    figure(2);

    X = [0];
    Y = [0];
    THETA = [0];
    RHO   = [1];
    count = 2;
            
    %% Main Loop
    
    while 1
        %% Odometry
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);
        Wall    = WallSensorReadRoomba(port);                % Poll for Wall Sensor
        d_dist  = DistanceSensorRoomba(port);                % Poll for Distance delta
        d_theta = AngleSensorRoomba(port);                   % Poll for Angle delta
        
        % Keep tracking the position and angle before the first hit
        prev_glob_x = glob_x;
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
        facing_right = -pi < glob_theta && glob_theta < 0;        
        facing_left  = ~facing_right;
        
        hit_distance = sqrt(first_hit_x^2 + first_hit_y^2);        

        
        %% Plotting function
        
        X = [X,glob_x];
        Y = [Y,glob_y];
        THETA = [THETA,glob_theta];        
        RHO = [RHO,count];
        
        count = count + 1;
        
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
            
            % Move Forward
            case 1
                                                
                SetFwdVelAngVelCreate(port, velocity, 0);
                
                if (abs(glob_y - goal_y) < goal_threshold)
                    state = 'final';
                elseif (BumpRight || BumpLeft || BumpFront)
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

                % If you cross the m-line
                if ( (glob_x <= 0 && prev_glob_x > 0) || (glob_x >= 0 && prev_glob_x < 0) )
                    
                    fprintf('ENCOUNTERED M-LINE\n');
                    
                    % Have you reached the goal?
                	if (abs(glob_y - goal_y) < goal_threshold)
                        state = 'final';
                    
                    % Else, are you closer than the current hit?
                    elseif (glob_y - hit(i) > 0)

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
                    elseif ( abs(glob_y - hit(i)) < goal_threshold )                        
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
                fprintf('SUCCESS: arrived at goal\n'); 
                
                % Plot the orientation over time. Rho is time, theta is the
                % angle
                figure(3);
                polar(THETA,RHO);
                
                return;
                
        end
        
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