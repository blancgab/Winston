% HW2 - Team #1

% Adam Reis - ahr2127

% Gabriel Blanco - gab2135

%%
function hw2_Team1(serPort)

    % Comments comments comments
    % Comments comments comments
    % Comments comments comments
    
    global port;
    
    port = serPort;

    %% Variable Declaration
    
    clc;
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);

    % Current Position
    glob_x     = 0;
    glob_y     = 0;
    glob_theta = 0;
    
    % First Hit Position
    first_hit_x = 0;
    first_hit_y = 0;
    first_hit_angle = 0;
    
    % Velocity
    velocity = 0.2;
    angular_vel = 0.1;
    
    % Distance
    dist_from_start = 0.3;
    dist_from_first_hit = 0.2;
    
    figure(2);

    X = [0];
    Y = [0];
    plot(X,Y);
        xlim([-5,5]);
        ylim([-5,5]);
        set(gca,'xtick',-5:5);
        set(gca,'ytick',-5:5);
        grid;
        axis square;
    
    %% State Definition
    
    % 1 -> Move Forward, 
    % 2 -> Wall Follow | Haven't left the threshold of the hit point
    % 3 -> Wall Follow | Left the threshold of the hit point
    % 4 -> Go Back to Start Position  
    % 5 -> Stop and Orient at Start Position
    
    state = 1;  
        
    %% Main Loop
    
    while 1
        %% Odometry
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(port);
        Wall    = WallSensorReadRoomba(port);                % Poll for Wall Sensor
        d_dist  = DistanceSensorRoomba(port);                % Poll for Distance delta
        d_theta = AngleSensorRoomba(port);                   % Poll for Angle delta
        
        % Keep tracking the position and angle before the first hit
        glob_theta = glob_theta + d_theta;               
        glob_x     = glob_x + sin(glob_theta) * d_dist;
        glob_y     = glob_y + cos(glob_theta) * d_dist;
        
        % Keep tracking the position and angle after the first hit
        first_hit_angle = first_hit_angle + d_theta;
        first_hit_x     = first_hit_x + sin(first_hit_angle) * d_dist;
        first_hit_y     = first_hit_y + cos(first_hit_angle) * d_dist;

        X = [X,glob_x];
        Y = [Y,glob_y];
        
        figure(2);
        plot(X,Y);
        xlim([-5,5]);
        ylim([-5,5]);
        set(gca,'xtick',-5:5);
        set(gca,'ytick',-5:5);
        grid;
        axis square;
        
        drawnow;
        
        start_distance = Distance(glob_x, glob_y);
        hit_distance   = Distance(first_hit_x, first_hit_y);
        
        %% State 
        
        switch state
            
            % Move Forward
            case 1
                display('Moving Forward');
                SetFwdVelAngVelCreate(port, velocity, 0);
                if (BumpRight || BumpLeft || BumpFront)
                    state = 2; % -> Wall Follow
                    first_hit_angle = 0;
                    first_hit_x = 0;
                    first_hit_y = 0;                    
                end
            
            % Wall Follow (Before leaving the threshold of the hit point)
            case 2
                WallFollow(velocity, angular_vel, BumpLeft, BumpFront, BumpRight, Wall);
                if (hit_distance > dist_from_first_hit)
                    state = 3; % Leave threshold
                end
            
            % Wall Follow (After leaving the threshold of the hit point)
            case 3
                WallFollow(velocity, angular_vel, BumpLeft, BumpFront, BumpRight, Wall);
                if(hit_distance < dist_from_first_hit)
                   state = 4; 
                end
            
            % Go Back to Start Position    
            case 4               
                turnAngle(port, angular_vel, glob_theta); %*(180/pi) );
                glob_theta = mod(glob_theta, pi) + pi;
                if (pi * 0.9 < glob_theta) && (glob_theta < pi * 1.1)
                    SetFwdVelAngVelCreate(port, velocity, 0 );
                    state = 5;
                end
            
            % Stop and Orient at Start Position    
            case 5
                if start_distance < dist_from_start
                    fprintf('Robot stopped to start point\n');
                    SetFwdVelAngVelCreate(port, 0, 0 );
                    fprintf('Turning to initial orientation\n');
                    turnAngle(port, angular_vel, 180);
                    fprintf('Robot returned to start position\n');
                    return;
                end
        end
        
    end
    
end


%% 
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

%% Distance Formula
function [dist] = Distance(x,y)

    dist = sqrt(x^2 + y^2);

end