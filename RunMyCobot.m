function RunMyCobot(robot, waypoints, port)
    
    ax = show(robot,'Frames','on');
    ZYX = [pi, pi/2, pi/3];
    %% 
    % Specify a robot trajectory. These _xyz_-coordinates draw an N-shape in front 
    % of the robot.
    global x y z n
    x = waypoints(:,1);
    y = waypoints(:,2);
    z = waypoints(:,3);
    dims = size(x);
    n = dims(1);
    %% Add gripper and pen offsets
    eeoffset=0.06
    ee_body = robotics.RigidBody('ee_gripper')
    setFixedTransform(ee_body.Joint, trvec2tform([0 -eeoffset -0.03]))
    %addBody(robot, ee_body,'link')
    robot.showdetails()
    robot.addBody(ee_body,'ee')
    robot.showdetails()
    show(robot,'Frames','on');
    %% setup serial communication with MyCobot
    % mycobot = serialport(port,115200);
    global cobot_enabled speed
    if cobot_enabled
        mycobot = serialport(port,115200);
        send_angles(mycobot, [0,0,0,0,0,0], speed)
    end
    %%
    global cobot_urdf_dir
    open_system('sm_ik_trajectory.slx')
    %%  
    % Run the simulation. The model should generate the robot configurations (|configs|) 
    % that follow the specified trajectory for the end effector.
    sim('sm_ik_trajectory.slx')
   
    %% 
    % Loop through the robot configurations and display the robot for each time 
    % step. Store the end-effector positions in |xyz|.    
    tformIndex = 1;
    fprintf("num of configs = %f", numel(configs.Data));
    xyz = zeros(numel(configs.Data)/6, 3);
    for i = 1:10:numel(configs.Data)/6
        currConfig = configs.Data(1:6,1,i);
        
        show(robot,currConfig,'Frames', 'on');
        if cobot_enabled
            send_angles(mycobot, currConfig, speed);            
        end
        drawnow        
        xyz(tformIndex,:) = tform2trvec(getTransform(robot,currConfig,'ee'));
        tformIndex = tformIndex + 1;
    end
    %% 
    % Draw the final trajectory of the end effector as a black line. The figure 
    % shows the end effector tracing the N-shape originally defined  (red dotted line). 
    show(robot,configs.Data(:,1,end), 'Frames','on');    
    
    hold on
    plot3(x,y,z,'-k','LineWidth',3);
    plot3(x,y,z,'--b','LineWidth',3);
    hold off
    %% 
    % Copyright 2018-2021 The MathWorks, Inc.
end
function angles_deg = convertToDegrees(angles)    
    mult = [1,-1,-1,-1,1,1];
    disp("radians = ");
    disp(angles);
    angles_deg = zeros(1,6);
    for i = 1:6
        angles_deg(i) = (angles(i) / pi) * 180;
    end
    angles_deg = angles_deg .* mult;
    disp("Angles = ");
    disp(angles_deg);  
end
function send_angles(cobot, angles, speed)
    global wait_time   
    mult = [1,-1,-1,-1,1,1];
    angles_deg = convertToDegrees(angles);
    cobotCommand = get_all_angles_command(angles_deg, speed);
    write(cobot,cobotCommand,"uint8");
    pause(wait_time)
end

function [h,l] = bytes_conversion_angles(a)
    t= a*100;
    binaryRepresentation = dec2bin(int32(t), 16) ;
    highByteBinary = binaryRepresentation(1:8);
    lowByteBinary = binaryRepresentation(9:16);
    highByte = bin2dec(highByteBinary);
    lowByte = bin2dec(lowByteBinary);
    highByte = dec2hex(highByte, 2);
    lowByte = dec2hex(lowByte, 2);
    h=hex2dec(highByte);
    l=hex2dec(lowByte);
end

function [h,l] = bytes_conversion_cords(a)
    t= a*10;
    binaryRepresentation = dec2bin(int32(t), 16) ;
    highByteBinary = binaryRepresentation(1:8);
    lowByteBinary = binaryRepresentation(9:16);
    highByte = bin2dec(highByteBinary);
    lowByte = bin2dec(lowByteBinary);
    highByte = dec2hex(highByte, 2);
    lowByte = dec2hex(lowByte, 2);
    h=hex2dec(highByte);
    l=hex2dec(lowByte);
end

function data = get_all_coords(cord)
    data=zeros(1,19);
    cmd_identifier = [0xFE, 0xFE, 0x10, 0x25];
    last_frame = [speed, 1, 0xFA];
    curIdx = 1;
    data(curIdx:curIdx + length(cmd_identifier)-1) = cmd_identifier;
    curIdx = curIdx + length(cmd_identifier);
    for i = 1:6
        [a, b] = bytes_conversion_angles(angles(i));
        data(curIdx) = a;
        data(curIdx + 1) = b;
        curIdx = curIdx + 2;
    end
    data(curIdx:curIdx + length(last_frame)-1) = last_frame;
end

function angles = read_all_angles(cobot)    
    data = [0xFE, 0xFE, 0x02, 0x20, OXFA];
    write(cobot,cobotCommand,"uint8");
    read_data = read(cobot, 17, "uint8");
    angles = [];
    for i = 5:2:16
        temp = read_data(i) + read_data(i+1) * 256;
        if (temp > 33000)
            angle = [temp - 65536]   
        else
            angle = temp
        end
        angle = angle / 100
        angles = [angles angle];
    end
end

function data = get_all_angles_command(angles, speed)
    data=zeros(1,19);
    cmd_identifier = [0xFE, 0xFE, 0x0F, 0x22];
    last_frame = [speed, 0xFA];
    curIdx = 1;
    data(curIdx:curIdx + length(cmd_identifier)-1) = cmd_identifier;
    curIdx = curIdx + length(cmd_identifier);
    for i = 1:6
        [a, b] = bytes_conversion_angles(angles(i));
        data(curIdx) = a;
        data(curIdx + 1) = b;
        curIdx = curIdx + 2;
    end
    data(curIdx:curIdx + length(last_frame)-1) = last_frame;
end