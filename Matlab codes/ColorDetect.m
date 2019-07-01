clear
close all

obj=videoinput('winvideo',3);
obj.ReturnedColorspace = 'rgb';
B=getsnapshot(obj);

framesAcquired = 0;
while (framesAcquired <= 3)
    
    data = getsnapshot(obj);
    data=imrotate(data,90);
    framesAcquired = framesAcquired + 1;
    
    %       data=imread('pic.jpg');
    
    data = imcrop(data,[0 380 480 640]);
    
    %RED:
    diff_imR = imsubtract(data(:,:,1), rgb2gray(data));
    diff_imR = medfilt2(diff_imR, [3 3]);
    diff_imR = imbinarize(diff_imR,'adaptive','Sensitivity',0.5);
    %stats = regionprops(diff_imR, 'BoundingBox', 'Centroid');
    % Remove all those pixels less than 300px
    diff_imR = bwareaopen(diff_imR,1500);
    % Label all the connected components in the image.
    red = bwlabel(diff_imR, 8);
    
    %GREEN:
    diff_imG = imsubtract(data(:,:,2), rgb2gray(data));
    diff_imG = medfilt2(diff_imG, [3 3]);
    diff_imG= imbinarize(diff_imG,'adaptive','Sensitivity',0.5);
    %stats = regionprops(diff_imG, 'BoundingBox', 'Centroid');
    % Remove all those pixels less than 300px
    diff_imG = bwareaopen(diff_imG,1500);
    % Label all the connected components in the image.
    green = bwlabel(diff_imG, 8);
    
    
    %BLUE:
    diff_imB = imsubtract(data(:,:,3), rgb2gray(data));
    diff_imB = medfilt2(diff_imB, [3 3]);
    diff_imB = imbinarize(diff_imB,'adaptive','Sensitivity',0.5);
    %stats = regionprops(diff_imB, 'BoundingBox', 'Centroid');
    % Remove all those pixels less than 300px
    diff_imB = bwareaopen(diff_imB,1500);
    % Label all the connected components in the image.
    blue = bwlabel(diff_imB, 8);
    
    %Finding what background I should erase
    datagray=rgb2gray(data);
    background=datagray<150;
    background=double(background);
    %Erasing
    red=red.*background;
    green=green.*background;
    blue=blue.*background;
    
    %Selecting the biggest area of colors
    ccRED = bwconncomp(red,4);
    ccGREEN = bwconncomp(green,4);
    ccBLUE = bwconncomp(blue,4);
    
    statsRED = regionprops(ccRED, 'basic');
    statsGREEN = regionprops(ccGREEN, 'basic');
    statsBLUE = regionprops(ccBLUE, 'basic');
    
    red_areas = [statsRED.Area];
    green_areas = [statsGREEN.Area];
    blue_areas = [statsBLUE.Area];
    
    [min_areaRED, idxR] = max(red_areas);
    [min_areaGREEN, idxG] = max(green_areas);
    [min_areaBLUE, idxB] = max(blue_areas);
    
    red = false(size(red));
    red(ccRED.PixelIdxList{idxR}) = true;
    
    green = false(size(green));
    green(ccGREEN.PixelIdxList{idxG}) = true;
    
    blue = false(size(blue));
    blue(ccBLUE.PixelIdxList{idxB}) = true;
    
    red=double(red);
    green=double(green);
    blue=double(blue);
    
    
    
    
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    statsRED = regionprops(red, 'basic');
    statsGREEN = regionprops(green, 'basic');
    statsBLUE = regionprops(blue, 'basic');
    
    % Display the image
    imshow(data)
    
    hold on
    
    %This is a loop to bound the red objects in a rectangular box.
    for objectRED= 1:length(statsRED)
        bbRED = statsRED(objectRED).BoundingBox;
        bcRED = statsRED(objectRED).Centroid;
        rectangle('Position',bbRED,'EdgeColor','r','LineWidth',2)
        plot(bcRED(1),bcRED(2), '-m+')
        a=text(bcRED(1)+15,bcRED(2), strcat('X: ', num2str(round(bcRED(1))), '    Y: ', num2str(round(bcRED(2))), '    Color: Red'));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'red');
    end
    
    
    for objectGREEN = 1:length(statsGREEN)
        bbGREEN = statsGREEN(objectGREEN).BoundingBox;
        bcGREEN = statsGREEN(objectGREEN).Centroid;
        rectangle('Position',bbGREEN,'EdgeColor','g','LineWidth',2)
        plot(bcGREEN(1),bcGREEN(2), '-m+')
        a=text(bcGREEN(1)+15,bcGREEN(2), strcat('X: ', num2str(round(bcGREEN(1))), '    Y: ', num2str(round(bcGREEN(2))), '    Color: Green'));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'green');
    end
    
    
    for objectBLUE = 1:length(statsBLUE)
        bbBLUE = statsBLUE(objectBLUE).BoundingBox;
        bcBLUE = statsBLUE(objectBLUE).Centroid;
        rectangle('Position',bbBLUE,'EdgeColor','b','LineWidth',2)
        plot(bcBLUE(1),bcBLUE(2), '-m+')
        a=text(bcBLUE(1)+15,bcBLUE(2), strcat('X: ', num2str(round(bcBLUE(1))), '    Y: ', num2str(round(bcBLUE(2))), '    Color: Blue'));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'blue');
    end
    
    hold off
    
end

% [i,j]=size(red);
% for c=1:i
%     for v=1:j
%         if red(c,v)==0 else
%             red(c,v)=255;
%         end if green(c,v)==0 else
%             green(c,v)=255;
%         end if blue(c,v)==0 else
%             blue(c,v)=255;
%         end
%     end
% end
% red1=imsubtract(red,green); red1=imsubtract(red1,blue);
% green1=imsubtract(green,red); green1=imsubtract(green1,blue);
% blue1=imsubtract(blue,green); blue1=imsubtract(blue1,red);





figure,imshow(red)
figure,imshow(green)
figure,imshow(blue)

lines=red+green+blue;
figure,imshow(lines)
% [i,j]=size(dataaa);

% for c=1:i
%     for v=1:j
%
%         if dataaa(c,v)==0
%         else
%             dataaa(c,v)=255;
%         end
%
%     end
% end


% red2=imsubtract(red1,dataaa);
% green2=imsubtract(green1,dataaa);
% blue2=imsubtract(blue1,dataaa);
%
%
% figure,imshow(red2)
% figure,imshow(green2)
% figure,imshow(blue2)

% clear all
