RGB = imread('11.jpg');
RGB=imrotate(RGB,90);
figure,
imshow(RGB),
title('Original Image');


RGB2 = imread('22.jpg');
RGB2=imrotate(RGB2,90);
figure,
imshow(RGB2),
title('Original Image');

load('calibrationSession4.mat');
[RGB,RGB2] = rectifyStereoImages(RGB,RGB2,calibrationSession.CameraParameters);
imtool(stereoAnaglyph(RGB,RGB2));


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


%--------------------------------------------------------------------------


% Step 2: Convert image from rgb to gray 
GRAY2 = rgb2gray(RGB2);
figure,
imshow(GRAY2),
title('Gray Image');

% Step 3: Threshold the image Convert the image to black and white in order
% to prepare for boundary tracing using bwboundaries. 
threshold = graythresh(GRAY2);
BW2 = im2bw(GRAY2, threshold);
figure,
imshow(BW2),
title('Binary Image');

% Step 4: Invert the Binary Image
% BW2 = ~ BW2;
% figure,
% imshow(BW2),
% title('Inverted Binary Image');

%--------------------------------------------------------------------------
I1=uint8(BW);
I2=uint8(BW2);

disparityRange = [0 80]; % arbitrary number and divisable by 8
disparityMap = disparity(I1,I2,'BlockSize', 15,'DisparityRange',disparityRange);
figure;
imshow(disparityMap,disparityRange);
title('Disparity Map');
colormap(gca,jet) 
colorbar








