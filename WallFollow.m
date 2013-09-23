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


    global t maxRuntime p port speed radius glob_theta glob_x glob_y hits;
    
    % Global constants
    maxRuntime = 12000;    % Maximum runtime (s)
    t = tic;        % Time start
    p = 0.05;       % Pause time
    port = serPort;
    speed = 0.2;
    radius = -0.4;
    glob_theta = 90;
    glob_x = 0;
    glob_y = 0;
    hits = 0;
    
    followObjectClockwise();
        
end

function followObjectClockwise()
    global t maxRuntime p radius glob_x glob_y port;
    
    % Start robot moving
    v = 0.5;
    w = 0;
    SetFwdVelAngVelCreate(port,v,w);
        
    while toc(t) < maxRuntime
        [front, left, right] = bumpCheck();
       
        if front
            fprintf('both\n');
            back_up();
            update_position();
            turn(180); %120
            arc(radius);
            continue;
        elseif left
            fprintf('left\n');
            back_up();
            update_position(); 
            turn(180+30);
            arc(radius);
            continue;
        elseif right
            fprintf('right\n');
            back_up();
            update_position();
            turn(180-30);
            arc(radius);
            continue;
        end
        pause(p)
    end
end

function update_position()
    global start_arc radius speed glob_theta glob_x glob_y hits;
    hits = hits + 1;
    
    if hits < 2
        fprintf('%f, [%f,%f]\n',glob_theta,glob_x,glob_y);
        return;
    end
    
    r = radius;
    v = speed;
    w = v/r;
    
    dt = toc(start_arc);
    dx = abs(r)*(1-cos(w*dt));
    dy = -abs(r)*(sin(w*dt));
    
    % or is it?
    % dy = abs(r)*(1-cos(w*dt));
    % dx = -abs(r)*(sin(w*dt));
    
    dtheta = atan(dy/dx)*(180/pi);
   
    rot = [cosd(glob_theta-90), -sind(glob_theta-90);... 
           sind(glob_theta-90), cosd(glob_theta-90)];
    delta_coords = rot*[dx;dy];
    
    glob_x = glob_x + delta_coords(1);
    glob_y = glob_y + delta_coords(2);
%   glob_theta = glob_theta - dtheta;
    glob_theta = mod(glob_theta + dtheta,360); % wrong formula, can't just add
    
    fprintf('Global Angle:   %.1f\n',glob_theta);
    fprintf('Movement Angle: %.1f\n',dtheta);
    
    fprintf('[%.2f, %.2f] %.2f sec (dx,dy,dt)\n[%.2f, %.2f] (net x,y)\n[%.2f, %.2f] %.2f deg (global theta, x & y)\n\n',dx,dy,dt,delta_coords(1),delta_coords(2),glob_x,glob_y,glob_theta);
end

function back_up()
    global port
    % Back up slightly   
    v = -0.05;
    w1 = 0;
    SetFwdVelAngVelCreate(port,v,w1);
    pause(0.1);
    SetFwdVelAngVelCreate(port,0,0);
end

function turn(d)
   global port glob_theta;
   glob_theta = mod(glob_theta + d,360);
    
    % Turn left d degrees
    v = 0;
    w = pi/2;
    SetFwdVelAngVelCreate(port,v,w);
    pause(d/90)
end

function arc(r)
    global port speed start_arc;
    start_arc = tic;
    % Turn forward to right with radius
    v = speed;
    SetFwdVelRadiusRoomba(port,v,r);
    
end

function [BumpFront, BumpLeft, BumpRight] = bumpCheck()
    global port;

    % Check bump sensors (ignore wheel drop sensors)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(port);
    
end