load('calibrationSession4.mat');
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


disparityRange = [0 80]; % arbitrary number and divisable by 8
disparityMap = disparity(bw,bw2,'BlockSize', 15,'DisparityRange',disparityRange);
imshow(disparityMap,disparityRange);
title('Disparity Map');
colormap(gca,jet) 
colorbar
%disparityMap = disparity(J1,J2);
% figure, imshow(stereoAnaglyph(I1,I2));
imtool(stereoAnaglyph(bw,bw2));

disparityMapU8 = uint8(disparityMap*255/80); % to convert the disparityMap as uint8 the save it as a file
imwrite(disparityMapU8,'disparityImage.jpg'); %the range will be from 0 to 255 and needs to be converted back to 0 - 80

% Next I have to search for edge detection. correction: i have to use shape
% classifying to identify the objective by converting the image to binary
% (see classifying.m and classify.m) then get the location of the
% objective... after that i take the location to the disparity matrix and
% find it's value... the value is then used to get the distance Z Next I
% Search for Location finding
