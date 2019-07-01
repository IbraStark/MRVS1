
cam1 = webcam(1);
%preview(cam1);
img = snapshot(cam1);
imwrite(img,'11.jpg');

cam2 = webcam(3);
%preview(cam2);
img = snapshot(cam2);
imwrite(img,'22.jpg')
Pic1 = rgb2gray(imread('11.jpg'));
Pic2 = rgb2gray(imread('22.jpg'));

I1 = imrotate(Pic1,90);
I2 = imrotate(Pic2,90);

imshow(I1)
figure,imshow(I2)


% I1 = rgb2gray(imread('11.jpg'));
% I2 = rgb2gray(imread('22.jpg'));

load('calibrationSession5.mat');
[I1,I2] = rectifyStereoImages(I1,I2,calibrationSession.CameraParameters);

ptsOriginal =  detectSURFFeatures(I1, 'MetricThreshold', 1000);
ptsDistorted = detectSURFFeatures(I2, 'MetricThreshold', 1000);

[featuresOriginal,   validPtsOriginal]  = extractFeatures(I1,  ptsOriginal);
[featuresDistorted, validPtsDistorted]  = extractFeatures(I2, ptsDistorted);

indexPairs = matchFeatures(featuresOriginal, featuresDistorted,'MatchThreshold',1,'MaxRatio',.7);%,'Metric', 'SAD',  'MatchThreshold', 7);

matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));
figure;
[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(matchedDistorted, matchedOriginal, 'affine','MaxDistance',2);
showMatchedFeatures(I1,I2, inlierOriginal(1:10,1), inlierDistorted(1:10,1),'montage');
f=849;
b=10;
A=inlierOriginal.Location;
B=inlierDistorted.Location;

CC=[A B];
cnew=sortrows(CC);
pts1=cnew(:,1:2)';
pts2=cnew(:,3:4)';

d=abs(pts1(:,1:10)-pts2(:,1:10));
Z=f*b/mean(d(1,:));

clear