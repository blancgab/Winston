% HW4 - Team #1

% Adam Reis - ahr2127
% Sophie Chou - sbc2125
% Gabriel Blanco - gab2135

%%
function hw4_Team1_Gabe(serPort)
    
    global port;    
    port = serPort;

    %% Generate Path

    clc;
    % system('python path_finder.py input3');
    outputFileID = fopen('output_test');
    A = textscan(outputFileID, '%f %f');
    fclose(outputFileID);
    
    pathX = cell2mat(A(1));
    pathY = cell2mat(A(2));

    for i = 1:length(pathX),
        fprintf('(%.2f, %.2f)\n',pathX(i), pathY(i));
    end

    %% Variable Declaration
    
    glob_x = pathX(1);
    glob_y = pathY(1);
    glob_theta = pi/2; % Start facing +x, +y
    
    %% Main Loop
    
    while 1
        
        
        
    end
    
end

%% Wall Following Function, copied directly from the TA Solution
% Wall follow functionality is not as accurate in practice as in the
% simulation.
function WallFollow(velocity, angular_vel, BumpLeft, BumpFront, BumpRight, Wall)

    global port;

    % Angle Velocity for different bumps
    w_bumpleft  =  2 * angular_vel;
    w_bumpfront =  3 * angular_vel;
    w_bumpright =  4 * angular_vel;
    w_nowall    = -4 * angular_vel;
    
    
    if BumpLeft || BumpFront || BumpRight
        v = 0;                              % Set Velocity to 0
    elseif ~Wall
        v = 0.25 * velocity;                % Set Velocity to 1/4 of the default
    else
        v = velocity;                       % Set Velocity to the default
    end

    
    if BumpLeft
        w = w_bumpleft;                   % Set Angular Velocity to w_bumpleft
    elseif BumpFront
        w = w_bumpfront;                  % Set Angular Velocity to w_bumpfront
    elseif BumpRight
        w = w_bumpright;                  % Set Angular Velocity to w_bumpright
    elseif ~Wall
        w = w_nowall;                     % Set Angular Velocity to w_nowall
    else
        w = 0;                            % Set Angular Velocity to 0
    end
    
    SetFwdVelAngVelCreate(port, v, w);
    
end
