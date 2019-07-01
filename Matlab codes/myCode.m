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
  
   
   


a = arduino('COM3', 'Uno', 'Libraries', 'JRodrigoTech/HCSR04')
sensor = addon(a, 'JRodrigoTech/HCSR04', 'D11', 'D12')

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

  
  %reading distance
val = readDistance(sensor);
sprintf('Current distance is %.4f meters\n', 340*t/2)







function strightAhead(delay1)
    digitalWrite(a,r1,1);
    digitalWrite(a,r2,0);
    digitalWrite(a,l1,1);
    digitalWrite(a,l2,0);
    pause(delay1/1000);
end

function reverse(delay2)
    digitalWrite(a,r1,0);
    digitalWrite(a,r2,1);
    digitalWrite(a,l1,0);
    digitalWrite(a,l2,1);
    pause(delay2/1000);
end

function turnLeft(delay3)
    digitalWrite(a,r1,1);
    digitalWrite(a,r2,0);
    digitalWrite(a,l1,0);
    digitalWrite(a,l2,1);
    pause(delay3/1000);
end

function turnRight(delay4)
    digitalWrite(a,r1,0);
    digitalWrite(a,r2,1);
    digitalWrite(a,l1,1);
    digitalWrite(a,l2,0);
    pause(delay4/1000);
end