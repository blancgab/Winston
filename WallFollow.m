function runtime = WallFollow(serPort)
% Autonomous control program for the iRobot Create. When it collides with
% an object, it will "hug" that objects contour until it returns to its
% original starting position.
%
% Input:
% serPort - Serial port object, used for communicating over bluetooth
%
% Output:
% runtime - Time elapsed since the iRobot Create began to move

% WallFollow.m
% Gabriel Blanco and Adam Reis 2013

    
    
    global t maxRuntime p;
    
    % Constants
    maxRuntime = 12000;    % Maximum runtime (s)
    t = tic;        % Time start
    p = 0.05;       % Pause time
    
    % Variables
    v = 0.5;        % Forward velocity (m/s)
    w = 0;          % Angular velocity (rad/s)
    
    
    forwardToMeetWall(serPort);
    
    followObjectClockwise(serPort);
  
end
 
function forwardToMeetWall(serPort)
    global t maxRuntime p;
    v = 0.5;
    w = 0;
    % Start robot moving
    SetFwdVelAngVelCreate(serPort,v,w);
    while toc(t) < maxRuntime
        bumped = bumpCheck(serPort);
        if bumped
            return
        end
        pause(p)
    end
end

function followObjectClockwise(serPort)
    global t maxRuntime p;

    % Back up slightly   
    v = -0.1;
    w = 0;
    SetFwdVelAngVelCreate(serPort,v,w);
    pause(0.1);

    % Turn left 45 degrees
    v = 0;
    w = pi/2;
    SetFwdVelAngVelCreate(serPort,v,w);
    pause(1)
    
    % Turn forward to right with radius
    v = 0.2;
    r = -0.3;
    SetFwdVelRadiusRoomba(serPort,v,r);
    
    while toc(t) < maxRuntime
        bumped = bumpCheck(serPort);
        
        if bumped
            % Back up slightly   
            v = -0.1;
            w = 0;
            SetFwdVelAngVelCreate(serPort,v,w);
            pause(0.1);
            
            % Turn left <45 degrees
            v = 0;
            w = pi/2;
            SetFwdVelAngVelCreate(serPort,v,w);
            pause(0.7)
            
            % Turn forward to right with radius
            v = 0.2;
            r = -0.3;
            SetFwdVelRadiusRoomba(serPort,v,r);
        end
        pause(p)
    end
    % output = 1;
end


function bumped = bumpCheck(serPort)


    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(serPort);
    
    bumped = BumpRight || BumpLeft || BumpFront;
    
end