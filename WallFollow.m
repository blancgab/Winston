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
    v = 0;               % Forward velocity (m/s)
    w = v2w(v);          % Angular velocity (rad/s)
    
    % Start robot moving
    SetFwdVelAngVelCreate(serPort,v,w);
    
    % DO STUFF
    bumped = bumpCheck(serPort);
    
    if bumped
        BeepRoomba(serPort);
    end

    output = 1;
end
 
function bumped = bumpCheck(serPort)


    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(serPort);
    
    bumped = BumpRight || BumpLeft || BumpFront;
    
end