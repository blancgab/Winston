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
    radius = -0.3;
    glob_theta = 90;
    glob_x = 0;
    glob_y = 0;
    hits = 0;
    
%     followObjectClockwise();
    
    arc(1);
    pause(7.8539);
    update_position();
    SetFwdVelAngVelCreate(port,0,0);
    pause(2);
    
    arc(1);
    pause(7.8539);
    update_position();
    SetFwdVelAngVelCreate(port,0,0);
    pause(2);
    
    arc(1);
    pause(7.8539);
    update_position();
    SetFwdVelAngVelCreate(port,0,0);
    pause(2);
    
    arc(1);
    pause(7.8539);
    update_position();
    SetFwdVelAngVelCreate(port,0,0);
    pause(2);
    
    
    BeepRoomba(port);
        
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
            turn(120);
            arc(radius);
            continue;
        elseif left
            fprintf('left\n');
            back_up();
            update_position(); 
            turn(170);
            arc(radius);
            continue;
        elseif right
            fprintf('right\n');
            back_up();
            update_position();
            turn(75);
            arc(radius);
            continue;
        end
        pause(p)
    end
end

function update_position()
    global start_arc radius speed glob_theta glob_x glob_y hits;
    hits = hits+1;
    
    if hits<2
        fprintf('%f, [%f,%f]\n',glob_theta,glob_x,glob_y);
        return;
    end
    
    dt = toc(start_arc);
    dx = abs(radius)*(sind((180*speed*dt)/(pi*abs(radius)))+1);
    dy = abs(radius)*cosd((180*speed*dt)/(pi*abs(radius)));
            
    rot = [cosd(glob_theta), -sind(glob_theta);... 
           sind(glob_theta), cosd(glob_theta)];
    delta_coords = rot*[dx;dy];
            
    glob_x = glob_x + delta_coords(1);
    glob_y = glob_y + delta_coords(2);
    glob_theta = glob_theta - (speed*dt*180)/(pi*radius);
    glob_theta = mod(glob_theta,360);
    fprintf('dt:%f, dx:%f, dy:%f, \nnet_x:%f, net_y:%f, net_theta:%f\nnew:[%f,%f]\n\n',dt,dx,dy,delta_coords(1),delta_coords(2),glob_theta,glob_x,glob_y);
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
    global port glob_theta
    
    glob_theta = glob_theta + d;
    glob_theta = mod(glob_theta,360);
    
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