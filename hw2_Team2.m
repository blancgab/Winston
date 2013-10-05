% HW2 - Team #1

% Adam Reis - ahr2127

% Gabriel Blanco - gab2135

%%
function hw2_Team2(serPort)

    % Comments comments comments
    % Comments comments comments
    % Comments comments comments

    %% Variable Declaration
    
    clc;
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

    % Current Position
    glob_x     = 0;
    glob_y     = 0;
    glob_angle = 0;
    
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
    
    %% State
    
    % 1 -> Move Forward, 
    % 2 -> Wall Follow | Haven't left the threshold of the hit point
    % 3 -> Wall Follow | Left the threshold of the hit point
    % 4 -> Go Back to Start Position  
    % 5 -> Stop and Orient at Start Position
    
    state = 1;  
    
    %% Main Loop
    
    while 1
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        Wall       = WallSensorReadRoomba(serPort);                % Poll for Wall Sensor
        dist_temp  = DistanceSensorRoomba(serPort);                % Poll for Distance delta
        angle_temp = AngleSensorRoomba(serPort);                   % Poll for Angle delta
        
    end

end


%%
function WallFollow(velocity, angular_vel, BumpRight, BumpLeft, BumpFront, Wall, serPort)
    % Angle Velocity for different bumps
    av_bumpright =  4 * angular_vel;
    av_bumpleft  =  2 * angular_vel;
    av_bumpfront =  3 * angular_vel;
    av_nowall    = -4 * angular_vel;
    
    if BumpRight || BumpLeft || BumpFront
        v = 0;                              % Set Velocity to 0
    elseif ~Wall
        v = 0.25 * velocity_val;            % Set Velocity to 1/4 of the default
    else
        v = velocity_val;                   % Set Velocity to the default
    end

    if BumpRight
    av = av_bumpright;                      % Set Angular Velocity to av_bumpright
    elseif BumpLeft
        av = av_bumpleft;                   % Set Angular Velocity to av_bumpleft
    elseif BumpFront
        av = av_bumpfront;                  % Set Angular Velocity to av_bumpfront
    elseif ~Wall
        av = av_nowall;                     % Set Angular Velocity to av_nowall
    else
        av = 0;                             % Set Angular Velocity to 0
    end
    SetFwdVelAngVelCreate(serPort, v, av );
end