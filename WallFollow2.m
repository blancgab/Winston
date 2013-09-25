
% HW1 - Team #1

% Adam Reis - ahr2127

% Gabriel Blanco - gab2135
function hw1_Team1( serPort )
% Autonomous control program for the iRobot Create. When it collides with
% an object, it will circumnavigate the object then returns to its
% original starting position.
%
% serPort - Serial port object, used for communicating over bluetooth


    % Global constants
    global maxRuntime port time speed radius step turnangle glob_theta ...
        rad2deg bumps;
    
    maxRuntime = 12000;     % maximum Runtime*
    port = serPort;         % serial Port to connect to
    time = tic;             % for timing purposes*
    speed = 0.07;           % speed of the iRobot
    radius = -0.3;          % turn radius for each arc
    step = 0.07;            % time step for each while loop
    turnangle = 120;        % angle iRobot turns after bump
    glob_theta = 90;        % sets the initial angle at 90 (straight up)
    rad2deg = 180/pi;       % conversion factor for radians to degrees
    bumps = 0;              % initializes the bump count
    
    followObjectClockwise();

end

function followObjectClockwise()

    global port radius speed step turnangle glob_x glob_y last_meas ...
        bumps start_x start_y calib;
    
    w = 0;
    calib = 0;
    glob_x = 0;
    glob_y = 0;
    AngleSensorRoomba(port);
    last_meas = tic;
    SetFwdVelAngVelCreate(port,speed,w);
        
    while 1
       [front, left, right] = bumpCheck();
        
        if left || right || front
            bumps = bumps+1;
            fprintf('bumps: %d\n',bumps);
            
            if bumps==1
                start_x = glob_x;
                start_y = glob_y;
                calib = -.0134;
            end
                        
            if front
                turn(turnangle);
                SetFwdVelRadiusRoomba(port,speed,radius);
                continue;
            elseif left
                turn(turnangle+40);
                SetFwdVelRadiusRoomba(port,speed,radius);
                continue;
            elseif right
                turn(turnangle-40);
                SetFwdVelRadiusRoomba(port,speed,radius);
                continue;
            end
        end
        
        calculatePosition();
        
        dist_to_start = abs(pdist([glob_x,glob_y;start_x,start_y],'euclidean'));
        %dist to start varies on time
        fprintf('distance to starting point: %f\n',dist_to_start);
        if bumps>4 && dist_to_start<.6
            fprintf('CLOSE\n');
            break;
        end
        
        pause(step);

    end
    SetFwdVelAngVelCreate(port,0,0);
    goToOrigin();
end

function goToOrigin()
    global glob_x glob_y glob_theta port speed bumps calib;
    calib = 0;
    
    if (glob_x>=0) %1st/4th quadrant
        theta = mod(180+atand(glob_y/glob_x),360);
        
    elseif (glob_x<0) % 2nd/3rd
        theta = atand(glob_y/glob_x);
    end
    
    turn(theta-glob_theta);
    
    travelDist(port, speed, abs(pdist([glob_x,glob_y;0,0],'euclidean')));
    
    turn(90-glob_theta);
    
    fprintf('%f [0,0]\n',glob_theta);
    fprintf('bumps: %d\n',bumps);
end

function calculatePosition()
    % Calculates the position of the iRobot in [x,y] based on the angle of
    % the machine (glob_theta) and the known linear velocity (speed)

    global port glob_theta rad2deg glob_x glob_y speed last_meas calib;
    
    dt = toc(last_meas);
    last_meas = tic;
    glob_x = glob_x + cosd(glob_theta)*speed*dt;
    glob_y = glob_y + sind(glob_theta)*speed*dt;
    
    glob_theta = mod(glob_theta + AngleSensorRoomba(port)*rad2deg+calib,360); %.0134 is calibration
           
    fprintf('%f [%f,%f]\n',glob_theta, glob_x, glob_y);  
    
end


function turn(d)
    % Turns iRobot by d degrees, then calculates the new global angle

    global port glob_theta rad2deg last_meas;
    
    turnAngle(port,0.15,d);
    glob_theta = mod(glob_theta + AngleSensorRoomba(port)*rad2deg,360);
    last_meas = tic;
end


function [BumpFront, BumpLeft, BumpRight] = bumpCheck()
    % Checks all bump sensors to see if they have been pushed

    global port;

    [BumpRight,BumpLeft,~,~,~,BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
end
