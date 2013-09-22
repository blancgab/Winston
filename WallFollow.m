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


    global t maxRuntime p port;
    
    % Global constants
    maxRuntime = 12000;    % Maximum runtime (s)
    t = tic;        % Time start
    p = 0.05;       % Pause time
    port = serPort;
    
    % Variables
    v = 0.5;        % Forward velocity (m/s)
    w = 0;          % Angular velocity (rad/s)
    
    
    forwardToMeetWall();    
    followObjectClockwise();
            
end
 
function forwardToMeetWall()
    global t maxRuntime p port;
    v = 0.5;
    w = 0;
    % Start robot moving
    SetFwdVelAngVelCreate(port,v,w);
    while toc(t) < maxRuntime
        if bumped()
            return
        end
        pause(p)
    end
end

function followObjectClockwise()
    global t maxRuntime p port;
    
    arc(-0.3, 36);
        
    while toc(t) < maxRuntime        
        
        switch bumped()
            case 'r'
                arc(-0.3, 50);
            case 'l'
                arc(-0.3, 130);
            case 'f'
                arc(-0.3, 36);
        end
        pause(p)
    end
end

function arc(r, d)
    global t maxRuntime p port;
        
    % Back up slightly   
    v = -0.1;
    w1 = 0;
    SetFwdVelAngVelCreate(port,v,w1);
    pause(0.1);

    % Turn left "d" degrees
    v = 0;
    w = 1.57;
    rotationTime = (pi/180)*d/w;
    SetFwdVelAngVelCreate(port,v,w);
    pause(rotationTime)
    
    % Turn forward to right with radius
    v = 0.2;
    SetFwdVelRadiusRoomba(port,v,r);
    
end

function bump = bumped()
    global port;

    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
    bump = 0;
    
    if BumpRight
        bump = 'r';
    end
    
    if BumpLeft
        bump = 'l';
    end
    
    if BumpFront
        bump = 'f';
    end
    
end

function bump = bumpedRight()
    global port;

    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, ~, ~, ~, ~, ~] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
    bump = BumpRight;
    
end

function bump = bumpedLeft()
    global port;

    % Check bump sensors (ignore wheel drop sensors)
    [~, BumpLeft, ~, ~, ~, ~] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
    bump = BumpLeft;
    
end

function bump = bumpedFront()
    global port;

    % Check bump sensors (ignore wheel drop sensors)
    [~, ~, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
    bump = BumpFront;
    
end
