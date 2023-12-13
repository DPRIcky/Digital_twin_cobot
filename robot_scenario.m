scenario = robotScenario(UpdateRate=1,StopTime=10);
addMesh(scenario,"Plane",Size=[3 3],Color=[0.7 0.7 0.7]);
waypoint = [ r Z_cords]/100;
toa = linspace(0,1,length(waypoint));
traj = waypointTrajectory("Waypoints",waypoint, ...
                          "TimeOfArrival",toa, ...
                          "ReferenceFrame","ENU");

robotRBT = importrobot("cobot_reassembled.urdf");

platform = robotPlatform("robot",scenario, ...
                      RigidBodyTree=robotRBT);

updateMesh(platform,"RigidBodyTree",Object=robotRBT);

% ins = robotSensor("INS",platform,insSensor("RollAccuracy",0), ...
%                   UpdateRate=scenario.UpdateRate);

[ax,plotFrames] = show3D(scenario);
axis equal
hold on

count = 1;
while ~isDone(traj)
    [Position(count,:),Orientation(count,:),Velocity(count,:), ...
     Acceleration(count,:),AngularVelocity(count,:)] = traj();
    count = count+1;
end

trajPlot = plot3(nan,nan,nan,"Color",[1 1 1],"LineWidth",2);
trajPlot.XDataSource = "Position(:,1)";
trajPlot.YDataSource = "Position(:,2)";
trajPlot.ZDataSource = "Position(:,3)";

setup(scenario)

for idx = 1:count-1
    show3D(scenario,FastUpdate=true,Parent=ax);
    % Refresh all plot data and visualize.
    refreshdata
    drawnow limitrate
    advance(scenario);
end
hold off

% 
% scenario = robotScenario(UpdateRate=1,StopTime=10);
% robotRBT = importrobot("cobot_reassembled.urdf");
% robot = robotPlatform("Robot",scenario, ...
%                       RigidBodyTree=robotRBT);
% updateMesh(platform,"RigidBodyTree",Object=robotRBT);
% 
% ax = show3D(scenario,Collisions="on");
% view(79,36)
% light

% tpts = 0:4;
% sampleRate = 20;
% tvec = tpts(1):1/sampleRate:tpts(end);
% numSamples = length(tvec);
% 
% waypoint = [ r Z_cords]/100;
% frankaSpaceWaypoints = transpose(waypoint);
% frankaTimepoints = linspace(tvec(1),tvec(end),53);
% [pos,vel] = minjerkpolytraj(frankaSpaceWaypoints,frankaTimepoints,numSamples);
% 
% rng(0) % Seed the RNG so the inverse kinematics solution is consistent
% ik = inverseKinematics(RigidBodyTree=robot);
% ik.SolverParameters.AllowRandomRestart = false;
% q = zeros(9,numSamples);
% weights = [0.2 0.2 0.2 1 1 1]; % Prioritize position over orientation
% initialGuess = [0, 0, 0, -pi/2, 0, 0, 0, 0.01, 0.01]'; % Choose an initial guess within the robot joint limits
% for i = 1:size(pos,2)
%     targetPose = trvec2tform(pos(:,i)')*eul2tform([0, 0, pi]);
%     q(:,i) = ik("link6",targetPose,weights,initialGuess);
%     initialGuess = q(:,i); % Use the last result as the next initial guess
% end
% 
% figure
% set(gcf,"Visible","on")
% show(robot);