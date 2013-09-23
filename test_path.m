%  Initialize communication 
[serialObject] =  RoombaInit(1)
 
% Read distance sensor (provides baseline)
InitDistance = DistanceSensorRoomba(serialObject);
 
%sets forward velocity 1 m/s and turning radius 2 m
SetFwdVelRadiusRoomba(serialObject, 1, 2);
 
%wait 1 second
pause(1)
 
% stop the robot
SetFwdVelRadiusRoomba(serialObject, 0, 1);
 
% read the distance senor.  
% returns dist since last reading in meters
Distance = DistanceSensorRoomba(serialObject)
