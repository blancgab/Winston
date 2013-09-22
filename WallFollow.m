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

<<<<<<< HEAD
    
=======

    global t maxRuntime p port;
>>>>>>> c7a409c050448f3df25e7c670aa5d22da94a1b0a
    
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
    
    BeepRoomba(port);
        
end
 
function forwardToMeetWall()
    global t maxRuntime p port;
    v = 0.5;
    w = 0;
    % Start robot moving
    SetFwdVelAngVelCreate(port,v,w);
    while toc(t) < maxRuntime
        bumped = bumpCheck();
        if bumped
            return
        end
        pause(p)
    end
end

function followObjectClockwise()
    global t maxRuntime p port;
    
    arc(-0.3, 36);
        
    while toc(t) < maxRuntime
        bumped = bumpCheck();
        
        if bumped
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

    % Turn left 60 degrees
    v = 0;
    w = (pi/180)*d/.4;
    SetFwdVelAngVelCreate(port,v,w);
    pause(0.4)
    
    % Turn forward to right with radius
    v = 0.2;
    SetFwdVelRadiusRoomba(port,v,r);
    
end

function bumped = bumpCheck()
    global port;

    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
    bumped = BumpRight || BumpLeft || BumpFront;
    
end