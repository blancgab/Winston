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
    v = 0.3;               % Forward velocity (m/s)
    w = 0;          % Angular velocity (rad/s)
    
    % Start robot moving
    SetFwdVelAngVelCreate(serPort,v,w);

       
    while 1
        bumped = bumpCheck(serPort);       
        if bumped
            fprintf('BUMPY!\n');
            
            SetFwdVelAngVelCreate(serPort,-0.1,w);
            
%             BeepRoomba(serPort);
            pause(0.1);
            
            fprintf('about to turn\n');
            SetFwdVelAngVelCreate(serPort,0,pi/2);
            
            fprintf('turning\n');
            pause(2);
            v= 0.3;
            w = 0;
            SetFwdVelAngVelCreate(serPort,v,w);
        end
        pause(.05)
        
    end
    
    output = 1;
end
 
function bumped = bumpCheck(serPort)


    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(serPort);
    
    bumped = BumpRight || BumpLeft || BumpFront;
    
end