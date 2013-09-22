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

    % Constants
    maxRuntime = 12000;    % Maximum runtime (s)

    % Variables
    t = tic;        % Time start
    v = 0.3;        % Forward velocity (m/s)
    w = 0;          % Angular velocity (rad/s)
    
    % Start robot moving
    SetFwdVelAngVelCreate(serPort,v,w);

    while toc(t) < maxRuntime
        
        bumped = bumpCheck(serPort);
        
        if bumped
            
            v = -0.1;
            w = 0;
            SetFwdVelAngVelCreate(serPort,v,w);
            BeepRoomba(serPort);
            pause(0.1);
            
            v = 0;
            w = pi/2;
            SetFwdVelAngVelCreate(serPort,v,w);
            pause(2);
            
            v= 0.3;
            w = 0;
            SetFwdVelAngVelCreate(serPort,v,w);
            
        end
        pause(.05)
        runtime = toc(t);
%         output = 1;
    end
end
 
function bumped = bumpCheck(serPort)


    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(serPort);
    
    bumped = BumpRight || BumpLeft || BumpFront;
    
end