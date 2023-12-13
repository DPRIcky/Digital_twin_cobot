clear all;
clc;

pitch = 90;
roll = 45;
yaw = 180;

% device = serialport('COM12',115200);
% 
% discard = [1397,2];

real_world_width = 100;
real_world_height = 100;

r_w_x_ratio = real_world_width/350;
r_w_y_ratio = real_world_height/350;

z=[cos(-pi/2), -sin(-pi/2);
    sin(-pi/2), cos(-pi/2)];
a=[2;0];
a=z*a;
dx = 50;
dy = 50;

waypoints = getLetterWaypoints_test('z');

for i = waypoints:waypoints

    filename = "alphabet_images\"+num2str(i)+".png";
    image = imread(filename);

    % Convert the image to grayscale (if not already)
    if size(image, 3) == 3
        grayImage = rgb2gray(image);
    else
        grayImage = image;
    end
    
    % Apply Canny edge detection
    edgeImage = edge(grayImage, 'Canny');
    
    % Find contours using bwboundaries
    boundaries = bwboundaries(edgeImage);
    
    % Display the original image and the extracted contours
    figure;
    subplot(1, 2, 1);
    imshow(image);
    title('Original Image');
    subplot(1, 2, 2);
    imshow(edgeImage);
    title('Extracted Contours');
    
    % Display the contours on the original image (optional)
    hold on;
    
    x_cords = zeros(1,1);
    y_cords = zeros(1,1);
    
    for k = 1 : length(boundaries)
        boundary = boundaries{k};
        plot(boundary(:, 2), boundary(:, 1), 'r', 'LineWidth', 2);
    end

     x = boundary(:, 2);
     y =   boundary(:, 1);
    
     x_cords =[x_cords; x];
     y_cords = [y_cords; y];
     s_x = size(x_cords);
     s_y = size(y_cords);
    
    hold off;
    
    x_cords = x_cords(2:end);
    y_cords = y_cords(2:end);
    
    y_cords = 350 - y_cords;
    
    interval = 25;
    x_cords = x_cords(interval:interval:end);
    y_cords = y_cords(interval:interval:end);

    x_cords = r_w_x_ratio*x_cords;
    y_cords = r_w_y_ratio*y_cords;
    s_x = size(x_cords);
    s_y = size(y_cords);
    x_cords = x_cords + dx;
    y_cords = y_cords + dy;
    
    r=[x_cords,y_cords];
    x_val = r(:,1);
    y_val = r(:,2);
    z_val = 45*ones(size(x_val));
    dimention = size(x_val);
    lins = dimention(1);


    plot(x_cords,y_cords, 'r', 'LineWidth', 2);
    scatter (x_cords,y_cords,5, 'blue');
    xlim([0, 350]);  
    ylim([0, 350]);
    title('Boundaries of the Letter');
    hold off;

    figure;
    hold on;
    plot(r(:,1),r(:,2), 'r', 'LineWidth', 2);
    xlim([-350, 350]);  
    ylim([-350, 350]);
    title('real world Boundaries of the Letter');
    hold off;
    % close all;

%     s=size(r)
%     for i=1:s(1,1)
%         t_x = r(i,1);
%         t_y = r(i,2);
%         test_cord = [t_x,t_y,45,pitch,roll,yaw]
%         k=send_cords(test_cord);
%         write(device,k,"uint8");
%         if(i==1)
%             pause(7)
%         else
%             pause(1)
%         end
%     end
end
%     clear device;

% FUNCTION CODE STARTS
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

function data = send_cords(cord)
data=zeros(1,19);
data(1)=0xFE;
data(2)=0xFE;
data(3)=0x10;
data(4)=0x25;
   [a,b]=bytes_conversion_cords(cord(1));
    data(5)=a;
    data(6)=b;
[a,b]=bytes_conversion_cords(cord(2));
    data(7)=a;
    data(8)=b;
[a,b]=bytes_conversion_cords(cord(3));
    data(9)=a;
    data(10)=b;
   [a,b]=bytes_conversion_angles(cord(4));
    data(11)=a;
    data(12)=b;
[a,b]=bytes_conversion_angles(cord(5));
    data(13)=a;
    data(14)=b;
[a,b]=bytes_conversion_angles(cord(6));
    data(15)=a;
    data(16)=b;
        data(17)=50;
    data(18)=1;
    data(19)=0xFA;
 
end