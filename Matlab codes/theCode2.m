clear all
cam1 = webcam(1);
% preview(cam1)
img = snapshot(cam1);
imwrite(img,'11.jpg');

cam2 = webcam(3);
% preview(cam2)
img = snapshot(cam2);
imwrite(img,'22.jpg')


load('calibrationSession5.mat');
J1=imread('11.jpg');
J2=imread('22.jpg');
J1=imrotate(J1,90);
J2=imrotate(J2,90);
%disparityMap = disparityBM(I1,I2)
%disparityMap = disparity(I1,I2);
% [J1,J2] = rectifyStereoImages(I1,I2,stereoParams);
% I1=J1;
% I2=J2;
[I1,I2] = rectifyStereoImages(J1,J2,calibrationSession.CameraParameters);
I1=rgb2gray(I1);
I2=rgb2gray(I2);
% I1=255-I1;
% I2=255-I2;
% I1=imnoise(I1,'salt & pepper',0.02);
% I2=imnoise(I2,'salt & pepper',0.02);
% 
figure;
disparityRange = [0 128]; % arbitrary number and divisable by 8
disparityMap = disparity(I1,I2,'BlockSize', 15,'DisparityRange',disparityRange);
% disparityMap = imgaussfilt(disparityMap,2);
imshow(disparityMap,disparityRange);
title('Disparity Map');
colormap(gca,jet) 
colorbar
%disparityMap = disparity(J1,J2);
% figure, imshow(stereoAnaglyph(I1,I2));
imtool(stereoAnaglyph(I1,I2));

disparityMapNums=uint8(disparityMap);
disparityMapU8 = uint8(disparityMap*255/80); % to convert the disparityMap as uint8 the save it as a file
imwrite(disparityMapU8,'disparityImage.jpg'); %the range will be from 0 to 255 and needs to be converted back to 0 - 80
dispa= imread('disparityImage.jpg');
% 
% rgb=imread('11.jpg');
% rgb=imrotate(rgb,90);

[center1,radius1] = imfindcircles(I1,[10 100],'ObjectPolarity','dark', 'Sensitivity',0.8);
center1=center1(1,:);
radius1=radius1(1,:);
figure,imshow(I1)
title('Left Camera Picture')
h1 = viscircles(center1,radius1);

[center2,radius2] = imfindcircles(I2,[10 100],'ObjectPolarity','dark', 'Sensitivity',0.8);
center2=center2(1,:);
radius2=radius2(1,:);
figure,imshow(I2)
title('Right Camera Picture')

h2 = viscircles(center2,radius2);


theCenter=(center1+center2)/2;

x=floor(theCenter(1));
y=floor(theCenter(2));

f=846;
b=9.6;

Z=f*b/disparityMap(y,x);
disp('the distance is:')
Z