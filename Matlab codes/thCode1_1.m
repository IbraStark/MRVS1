cam1 = webcam(1);
%preview(cam1);
img = snapshot(cam1);
imwrite(img,'11.jpg');

cam2 = webcam(3);
%preview(cam2);
img = snapshot(cam2);
imwrite(img,'22.jpg')


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



% Step 1: Read image Read in
RGB = %the clear objective peffered to be a circle ;
figure,
imshow(RGB),
title('Original Image');

% Step 2: Convert image from rgb to gray 
GRAY = rgb2gray(RGB);
figure,
imshow(GRAY),
title('Gray Image');

% Step 3: Threshold the image Convert the image to black and white in order
% to prepare for boundary tracing using bwboundaries. 
threshold = graythresh(GRAY);
BW = im2bw(GRAY, threshold);
figure,
imshow(BW),
title('Binary Image');

% Step 4: Invert the Binary Image
BW = ~ BW;
figure,
imshow(BW),
title('Inverted Binary Image');

% Step 5: Find the boundaries Concentrate only on the exterior boundaries.
% Option 'noholes' will accelerate the processing by preventing
% bwboundaries from searching for inner contours. 
[B,L] = bwboundaries(BW, 'noholes');

% Step 6: Determine objects properties
STATS = regionprops(L, 'all'); % we need 'BoundingBox' and 'Extent'

% Step 7: Classify Shapes according to properties
% Square = 3 = (1 + 2) = (X=Y + Extent = 1)
% Rectangular = 2 = (0 + 2) = (only Extent = 1)
% Circle = 1 = (1 + 0) = (X=Y , Extent < 1)
% UNKNOWN = 0

figure,
imshow(RGB),
title('Results');
hold on
for i = 1 : length(STATS)
  W(i) = uint8(abs(STATS(i).BoundingBox(3)-STATS(i).BoundingBox(4)) < 0.1);
  W(i) = W(i) + 2 * uint8((STATS(i).Extent - 1) == 0 );
  centroid = STATS(i).Centroid;
  switch W(i)
      case 1
          plot(centroid(1),centroid(2),'wO');
          x=floor(centroid(1));
          y=floor(centroid(2));

          f=862;
          b=10;

          Z=f*b/disparityMap(y,x);
          disp('the distance is:')
Z
      case 2
          plot(centroid(1),centroid(2),'wX');
      case 3
          plot(centroid(1),centroid(2),'wS');
  end
end