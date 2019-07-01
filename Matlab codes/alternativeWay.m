cam1 = videoinput('winvideo',2);
triggerconfig(cam1, 'manual');
cam1.FramesPerTrigger = inf;
java.lang.Thread.sleep(50);

cam2 = videoinput('winvideo',2);
triggerconfig(cam2, 'manual');
cam2.FramesPerTrigger = inf;
java.lang.Thread.sleep(50);

%cam1 taking a picture:
start(cam1);
trigger(cam1)
img = getdata(cam1,1);  %left camera image
imwrite(img,'picLeft.jpg');

stop(cam1);
java.lang.Thread.sleep(50);

%cam2 taking a picture:
start(cam2);
trigger(cam2)
img2 = getdata(cam2,1);%right camera image
imwrite(img2,'picRight.jpg');
stop(cam2);
java.lang.Thread.sleep(50);
