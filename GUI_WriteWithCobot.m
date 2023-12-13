global x y z n robot cobot_enabled speed time_step wait_time
time_step = 0.05;
wait_time = 1;
cobot_enabled = true;
speed = 50;
global cobot_urdf_dir
cobot_urdf_dir = './cobot3/urdf';
filename = 'cobot3.urdf';
global cobot_urdf_file;  
cobot_urdf_file = append(cobot_urdf_dir, '/', filename);
init_GUI();

function init_GUI()
    global cobot_enabled
    % Create a blank GUI
    fig = figure('Name', 'Letter Digitization', 'Position', [100, 100, 800, 600]);

    % Create a "Text Input" field
    textInputField = uicontrol('Style', 'edit', 'Position', [10, 10, 150, 30]);
 
    % Create a "Generate Text" button
    generateTextButton = uicontrol('Style', 'pushbutton', 'String', 'Generate Text', ...
        'Position', [170, 10, 100, 30], 'Callback', @generateText);

    % Create a "Send to Robot" button
    sendToRobotButton = uicontrol('Style', 'pushbutton', 'String', 'Send to SimRobot', ...
        'Position', [280, 10, 120, 30], 'Callback', @sendToRobot);

    enableCobotBox = uicontrol('Style', 'checkbox', 'String', 'Enable MyCobot', ...
        'Position', [410, 10, 120, 30], 'Callback', @enableCobotCheckBox);    
    enableCobotBox.Value = cobot_enabled

    serialPorts = serialportlist("all");
    disp('Available Serial Ports:');
    disp(serialPorts);

    port_menu = uicontrol("Style",'popupmenu',"String", serialPorts, 'Position',[170, 30, 100, 30])
    %set(port,serialPorts)
    
    % Create axes for drawing
    axesHandle = axes('Parent', fig, 'Position', [0.1, 0.3, 0.8, 0.6]);

    % Create a uicontrol to display current X and Y coordinates
    coordDisplay = uicontrol('Style', 'text', 'Position', [10, 50, 150, 100]);

    % Initialize arrays to store X and Y coordinates
    xCoordinates = {};
    yCoordinates = {};

    % Callback function to generate and display text
    function generateText(~, ~)
        % Get the text input
        textInput = get(textInputField, 'String');

        % Clear the previous drawing
        cla(axesHandle);

        % Display the text in the drawing area
        %text(0.5, 0.5, textInput, 'FontSize', 48, 'Parent', axesHandle);
        factor = 0.05
        xy = factor * getLetterWaypoints(textInput(1))
        x1 = xy(:,1);
        y1 = xy(:,2) - factor*6;
        n1 = size(xy,1);
        z1 = zeros(1,n1) + 0.05;
        wps = [x1 y1 z1'];
        hold on
        plot3(wps(:,1)', wps(:,2)',wps(:,3)','-b','LineWidth',3)
        hold off
    end

    % Callback function to send the coordinates to the robot
    function sendToRobot(~, ~)
        % Implement your code to send coordinates to the robot via serial communication here
        % Use xCoordinates and yCoordinates to send the drawing coordinates to the robot
        global x y z n robot
        textInput = get(textInputField, 'String');
        % port = port_menu.String{port_menu.Value};
        % disp(port)
        global cobot_urdf_file
        WriteWithCobot(cobot_urdf_file, textInput, 'COM11')
    end
    function enableCobotCheckBox(~, ~)
        % Implement your code to send coordinates to the robot via serial communication here
        % Use xCoordinates and yCoordinates to send the drawing coordinates to the robot        
        cobot_enabled = enableCobotBox.Value
    end
end
