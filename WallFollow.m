function output = WallFollow(serPort)
% Autonomous control program for the iRobot Create. When it collides with
% an object, it will "hug" that objects contour until it returns to its
% original starting position.
%
% Input:
% serPort - Serial port object, used for communicating over bluetooth
%
% Output:
% output - TBD

% WallFollow.m
% Gabriel Blanco and Adam Reis 2013

    % Variables
    v = 10;               % Forward velocity (m/s)
    w = 0;          % Angular velocity (rad/s)
    while 1
        bumped = bumpCheck(serPort);
        
        if bumped
            BeepRoomba(serPort);
            v= -1;
            w= 0;
            SetFwdVelAngVelCreate(serPort,v,w);
            pause(1);
            break;
        end
        
        % Start robot moving
        SetFwdVelAngVelCreate(serPort,v,w);
    end

    output = 1;
end
 
function bumped = bumpCheck(serPort)


    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(serPort);
    
    bumped = BumpRight || BumpLeft || BumpFront;
    
end