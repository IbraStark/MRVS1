


j=101;
beep
pause(2)
beep
pause(1)
beep
pause(0.25)
beep
pause(0.25)
beep
pause(2)

for i=1:20
    img = snapshot(cam1);
    img = imrotate(img,90);
    imwrite(img,sprintf('%d.jpg',i));

    img2 = snapshot(cam2);
    img2 = imrotate(img2,90);
    imwrite(img2,sprintf('%d.jpg',j));
    beep
    pause(3)
    j=j+1;
end 
beep 
pause(0.25)
beep
pause(0.25)
beep