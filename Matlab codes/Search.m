cam1 = webcam(1);
%preview(cam1)
img = snapshot(cam1);
imwrite(img,'11.jpg');


cam2 = webcam(3);
%preview(cam2)
img = snapshot(cam2);
imwrite(img,'22.jpg')

load('calibrationSession5.mat');
J1=imread('11.jpg');
J2=imread('22.jpg');
J1=imrotate(J1,90);
J2=imrotate(J2,90);

[I1,I2] = rectifyStereoImages(J1,J2,calibrationSession.CameraParameters);
I1=rgb2gray(I1);
I2=rgb2gray(I2);

imtool(stereoAnaglyph(I1,I2))

 r1=2;
   r2=4;
  % Left-hand side motors:
   l1=7;
   l2=8;
  
   dist =15; % distance of obstacle to avoid in cm

  % Analog signal for motors speed:
   m1=10;
   m2=3;
   m3=6;
   m4=9;
   dly = 1500;

 % Ultrasonic code:
   trigPin = 11;    % Trigger
   echoPin = 12;    % Echo
  
   
   

a = arduino('COM4', 'Uno', 'Libraries', 'JRodrigoTech/HCSR04');
%a = arduino('COM4');
sensor = addon(a, 'JRodrigoTech/HCSR04', 'D11', 'D12');

  a.pinMode(r1, 'output');
  a.pinMode(r2, 'output');
  a.pinMode(l1, 'output');
  a.pinMode(l2, 'output');
  a.pinMode(m1, 'output');
  a.pinMode(m2, 'output');
  a.pinMode(m3, 'output');
  a.pinMode(m4, 'output');  


  
  a.pinMode(trigPin, 'output');
  a.pinMode(echoPin, 'input');
  
  analogWrite(a,m1,255);
  analogWrite(a,m2,233);
  analogWrite(a,m3,230);
  analogWrite(a,m4,255);
  
  
  
  
    digitalWrite(a,r1,1);
    digitalWrite(a,r2,0);
    digitalWrite(a,l1,0);
    digitalWrite(a,l2,1);
    pause(0.25);
    digitalWrite(a,r1,0);
    digitalWrite(a,r2,0);
    digitalWrite(a,l1,0);
    digitalWrite(a,l2,0);

  