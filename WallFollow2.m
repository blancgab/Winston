function [ runtime ] = WallFollow2( serPort )
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

% Global constants

    global maxRuntime port time speed radius step turnangle scan_freq ...
        glob_theta rad2deg;
    
    maxRuntime = 12000; 
    port = serPort;
    time = tic;
    speed = 0.1;
    radius = -0.3;
    step = 0.05;
    turnangle = 120;
    scan_freq = 20;
    glob_theta = 90;
    rad2deg = 180/pi;
    
    followObjectClockwise();
end

function followObjectClockwise()

    global maxRuntime port time radius speed step turnangle scan_freq ...
        glob_theta rad2deg;

    count = 0;
    
    v = 0.5;
    w = 0;
    SetFwdVelAngVelCreate(port,v,w);
        
    while toc(time) < maxRuntime
        
       count = count +1; 
  
       [front, left, right] = bumpCheck();
               
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
        
        calculatePosition();
        
        pause(step);

    end
end

function calculatePosition()

    global port step glob_theta rad2deg;

    d_theta = AngleSensorRoomba(port)*rad2deg;
    glob_theta = mod(glob_theta + d_theta,360);
            
    if d_theta
        fprintf('Global Angle: %.2f\n',glob_theta);   
    end

end


function turn(d)
    global port glob_theta;
    
    fprintf('Global Angle (before turn): %.2f\n',glob_theta);   
    
%     glob_theta = mod(glob_theta + d,360);
%  
%     fprintf('Global Angle (after turn):  %.2f\n',glob_theta);   
    
    v = 0;
    w = pi/2;
    SetFwdVelAngVelCreate(port,v,w);
    pause(d/90);
    
    return;
end

function [BumpFront, BumpLeft, BumpRight] = bumpCheck()
    global port;

    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
end
