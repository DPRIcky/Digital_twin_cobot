clear all;
clc;

%  90, 45, 180]

pitch = 90;
roll = 45;
yaw = 180;

device = serialport('COM21',115200);

discard = [1397,2];

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

for i = 19:19
    filename = "alphabets_figs\images\"+num2str(i)+".jpg";
    image = imread(filename);  
    if size(image, 3) == 3
        grayImage = rgb2gray(image);
    else
        grayImage = image;
    end
    
    threshold = 0.5;  
    binaryImage = imbinarize(grayImage, threshold);
    
    boundaries = bwboundaries(binaryImage);
    
    figure;
%     imshow(image);
    hold on;
    x_cords = zeros(1,1);
    y_cords = zeros(1,1);


    for k = 1:numel(boundaries)
        boundary = boundaries{k};
        
        if size(boundary) == [1397,2]
            continue
        end
        
        
        x = boundary(:, 2);
        y =   boundary(:, 1);
        x_cords =[x_cords; x];
        y_cords = [y_cords; y];
        s_x = size(x_cords);
        s_y = size(y_cords);

%         plot(x,y, 'r', 'LineWidth', 2);
%         scatter(x, y, 7, 'blue');
    end
    
    x_cords = x_cords(2:end);
    y_cords = y_cords(2:end);

    y_cords = 350 - y_cords;
    
    interval = 18;
    x_cords = x_cords(interval:interval:end);
    y_cords = y_cords(interval:interval:end);
    
    x_cords = r_w_x_ratio*x_cords;
    y_cords = r_w_y_ratio*y_cords;
    s_x = size(x_cords);
    s_y = size(y_cords);
    x_cords = x_cords + dx;
    y_cords = y_cords + dy;
    r=[x_cords,y_cords];
%     r=r*z;
    
    
%     close all
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
    close all;
    
    s=size(r)
    for i=1:s(1,1)
        t_x = r(i,1);
        t_y = r(i,2);
        test_cord = [t_x,t_y,45,pitch,roll,yaw]
        k=send_cords(test_cord);
        write(device,k,"uint8");
        if(i==1)
            pause(7)
        else
            pause(1)
        end
    end
end
    clear device;

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