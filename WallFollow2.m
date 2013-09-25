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
        glob_theta rad2deg bumps;
    
    maxRuntime = 12000; 
    port = serPort;
    time = tic;
    speed = 0.07;
    radius = -0.3;
    step = 0.07;
    turnangle = 120;
    scan_freq = 20;
    glob_theta = 90;
    rad2deg = 180/pi;
    bumps = 0;
    
    followObjectClockwise();
  
%     v = 0;
%     w = pi/2;
%     AngleSensorRoomba(port);
% %     t = tic;
%     for n=1:5
%         SetFwdVelAngVelCreate(port,v,w);
%         pause(2);
% %     while(glob_theta<(90+180*.96))
% %         glob_theta = mod(glob_theta + AngleSensorRoomba(port)*rad2deg, 360);
% %         fprintf('glob_theta: %f\n',glob_theta);
% %         pause(step);
% %     end
% %     fprintf('angle sensor: %f\n',AngleSensorRoomba(port));
%         SetFwdVelAngVelCreate(port,0,0);
%         pause(1);
%         dw = AngleSensorRoomba(port)*rad2deg;
%         glob_theta = mod(glob_theta + AngleSensorRoomba(port)*rad2deg, 360);
%         fprintf('dw: %f\n',dw);
%         pause(1);
%     end

%     AngleSensorRoomba(port);
%     turnAngle(port,1,180);
%     pause(1);
%     fprintf('angle sensor: %f\n',AngleSensorRoomba(port)*rad2deg);

%     AngleSensorRoomba(port);
%     SetFwdVelRadiusRoomba(port,speed,-1);
%     
%     while glob_theta>1
%         glob_theta = mod(glob_theta+AngleSensorRoomba(port)*rad2deg, 360);
%         fprintf('glob_theta: %f\n',glob_theta);
%         pause(step);
%     end
%     SetFwdVelAngVelCreate(port,0,0);
%     pause(1);
%     glob_theta = mod(glob_theta+AngleSensorRoomba(port)*rad2deg, 360);
%     fprintf('final glob_theta: %f\n',glob_theta);
    


end

function followObjectClockwise()

    global maxRuntime port time radius speed step turnangle scan_freq ...
        glob_theta rad2deg glob_x glob_y last_meas bumps start_x start_y calib;
    
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
            
%             backup();
            
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

function backup()
    global port speed glob_x glob_y glob_theta rad2deg;
    SetFwdVelAngVelCreate(port,0,0);
    backup_dist = -.005;
%     glob_theta = mod(glob_theta + AngleSensorRoomba(port)*rad2deg,360);
    travelDist(port, speed, backup_dist);
%     
%     glob_x = glob_x + cosd(glob_theta+180)*backup_dist;
%     glob_y = glob_y + sind(glob_theta+180)*backup_dist;
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

    global port step glob_theta rad2deg glob_x glob_y speed last_meas calib;
    dt = toc(last_meas);
    last_meas = tic;
    glob_x = glob_x + cosd(glob_theta)*speed*dt;
    glob_y = glob_y + sind(glob_theta)*speed*dt;
    
    glob_theta = mod(glob_theta + AngleSensorRoomba(port)*rad2deg+calib,360); %.0134 is calibration
           
    fprintf('%f [%f,%f]\n',glob_theta, glob_x, glob_y);  
    
    
end


function turn(d)
    global port glob_theta rad2deg last_meas;
    
    turnAngle(port,.15,d);
    glob_theta = mod(glob_theta + AngleSensorRoomba(port)*rad2deg,360);
    last_meas = tic;
end



function [BumpFront, BumpLeft, BumpRight] = bumpCheck()
    global port;

    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
end
