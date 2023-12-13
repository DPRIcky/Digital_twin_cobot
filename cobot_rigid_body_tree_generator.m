% Ts = 0.001;
robot = importrobot('cobot_reassembled.urdf');

config = homeConfiguration(robot);

anglesJ = [ 0 0 0 0 0 0];


% % cobot_tree = interactiveRigidBodyTree(robot);
% % cobot_tree.MarkerPose = cobot_tree.MarkerPose*eul2tform*([pi/2 0 0]);
% % 
% % base_rotation = eye(4);
% % 
% % join1_rotation = eye(4);
% % 
% % join2_rotation = [0 0 -1 0
% %     0 1 0 0
% %     1 0 0 0
% %     0 0 0 1];
% % 
% % join3_rotation = [0 0 -1 0
% %     0 1 0 0
% %     1 0 0 0
% %     0 0 0 1];
% % 
% % join4_rotation = [0 0 -1 0
% %     0 1 0 0
% %     1 0 0 0
% %     0 0 0 1];
% % 
% % join5_rotation = [1 0 0 0
% %     0 0 -1 0
% %     0 1 0 0
% %     0 0 0 1];
% % 
% % ee = [1 0 0 0
% %     0 0 1 0
% %     0 -1 0 0
% %     0 0 0 1];
% % 
% % platform = collisionBox(1,1,0.02);
% % platform.Pose = trvec2tform([ 0 0 -0.04]);
% % 
% % robot.Base.addVisual("Mesh","meshes\base_link.STL",base_rotation)
% % robot.Bodies{1}.addVisual("Mesh","meshes\link1.STL",join1_rotation)
% % robot.Bodies{2}.addVisual("Mesh","meshes\link2.STL",join2_rotation)
% % robot.Bodies{3}.addVisual("Mesh","meshes\link3.STL",join3_rotation)
% % robot.Bodies{4}.addVisual("Mesh","meshes\link4.STL",join4_rotation)
% % robot.Bodies{5}.addVisual("Mesh","meshes\link5.STL",eye(4))
% % robot.Bodies{6}.addVisual("Mesh","meshes\link6.STL",join5_rotation)
% % 
% % 
% % 
% % currconfig = homeConfiguration(cobot_tree.RigidBodyTree);
% 
% s = size(r);
% for i = 1:s(1,1)
%     t_x = r(i,1);
%     t_y = r(i,2);
%     t_z = 45;
%     pitch = 90;
%     roll = 45;
%     yaw = 180;
%     plot3(t_x,t_y,t_z)
%     hold on
%     % currconfig(1:6) = [t_x,t_y,45,pitch,roll,yaw];
%     % cobot_tree.Configuration = currconfig;
%     % show(cobot_tree,currconfig)
% end
% 
% 
% % currconfig(1:6) = [115 62 45 90 45 180];
% % 
% % cobot_tree.Configuration = currconfig;
% 
% plot3(x_cords,y_cords,Z_cords)

config(4).JointPosition = -pi/2;
config(5).JointPosition = -pi;
ax = show(robot,config);
x = r(:,1);
y = r(:,2);

cumulative_distance = [0; cumsum(sqrt(diff(x).^2 + diff(y).^2))];

t = cumulative_distance/cumulative_distance(end);
ts = linspace(0,1,21);

x_interp = interp1(t,x,ts,'spline');
y_interp = interp1(t,y,ts,'spline');

x = x_interp/500;
y = y_interp/500;

s = size(y_interp);
z = 45*ones(s)/500;
pitch = 0*ones(s)/500;
roll = 0*ones(s)/500;
yaw = 0*ones(s)/500;

trajectory = [x' y' z' pitch' roll' yaw'];

N = size(trajectory,1);

for i=1:N
    [j1,j2,j3,j4,j5,j6] = cobot_IK(trajectory(i,1),trajectory(i,2),trajectory(i,3));
    anglesJ = [anglesJ; j1 j2 j3 j4 j5 j6]
end

angleNew = double(anglesJ);

hold on
plot3(x,y,z,'-r','LineWidth',2,'Parent',ax)
hold off

waypointTimes = 0:1:height(trajectory);
ts = 0.5;
trajTimes = 0:ts:waypointTimes(end);
% close