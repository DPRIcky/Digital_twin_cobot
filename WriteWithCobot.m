function WriteWithCobot(coboturdf, letter, port)
    global x y z n robot
    factor = 0.05;
    xy = factor * getLetterWaypoints(letter);
    x1 = xy(:,1);
    y1 = xy(:,2) + factor*5;
    n1 = size(xy,1);
    z1 = zeros(n1,1) + 0.03;
    wps = [x1 y1 z1];
    
    robot = importrobot(coboturdf);
    robot.DataFormat = 'column';
    RunMyCobot(robot, wps, port);
   
end