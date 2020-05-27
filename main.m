clc;
clear;
close all;

boxDatas = readtable('yolov3-training_all.csv', 'HeaderLines', 2);
boxDatas = sortrows(boxDatas, 'Var1', 'ascend');

boxColors = {'blue', '#ffa500', 'yellow'};
objectIds = [0, 1, 2];

drawImages = 1;

mkdir('./output')

figure(1)
for ii = 200:400
    fileName = boxDatas(ii,1);
    boundStrings = boxDatas(ii, 6:end);
    
    frame = imread(['./YOLO_Dataset/', fileName.(1){1}]);
    outputFile = fopen(['./output/', fileName.(1){1}(1:end-3), 'txt'], 'w');
    
    if drawImages
        figure(1)
        imshow(frame);
        hold on
    end

    for jj = 1:numel(boundStrings)
        boundString = boundStrings.(jj){1}; % X0, Y0, H0, W0
        
        if numel(boundString) < 1
            break;
        end
        
        % before extracting bounding box locations, remove any double
        % quotes inside boundString, otherwise str2num may return an error
        boundString = strrep(boundString, '"', '');
        
        boundBox = str2num(boundString);
        
        crop = frame(boundBox(2) + (1:boundBox(3)), ...
                     boundBox(1) + (1:boundBox(4)), :);
                 
%         figure
%         imshow(crop);
                  
%         crop = crop(:, (-1:1) + floor(size(crop,2)/2), :);
%         crop = crop(floor(size(crop,1)/2):end, :, :);
        
        crop_HSV = rgb2hsv(crop);
        
        colorCount = [0, 0, 0];
        
        % Blue
%         channel1Min = 0.533;
%         channel1Max = 0.804;
%         colorCount(1) = sum((channel1Min <= crop_HSV(:,:,1)) & (crop_HSV(:,:,1) <= channel1Max), 'all');
        [mask, ~] = createMaskBlue(crop); % RGB masking
        colorCount(1) = sum(mask, 'all');
        
        % Orange
%         channel1Min = 0.016;
%         channel1Max = 0.134;
%         colorCount(3) = sum((channel1Min <= crop_HSV(:,:,1)) & (crop_HSV(:,:,1) <= channel1Max), 'all');
        [mask, ~] = createMaskOrange(crop);
        colorCount(2) = sum(mask, 'all');
        
        % Yellow
%         channel1Min = 0.128;
%         channel1Max = 0.181;
%         colorCount(2) = sum((channel1Min <= crop_HSV(:,:,1)) & (crop_HSV(:,:,1) <= channel1Max), 'all');
        [mask, ~] = createMaskYellow(crop);
        colorCount(3) = sum(mask, 'all');

        coneColorID = objectIds(colorCount == max(colorCount));
        coneColor = boxColors(colorCount == max(colorCount));
        
%         figure(ehh)
        if drawImages
            rectangle('Position', boundBox([1 2 4 3]), 'EdgeColor', coneColor{1});
%             pause(0.1)
        end
%         images.roi.Rectangle(gca, 'Position', boundBox([1 2 4 3]), 'Color', coneColor{1}, 'InteractionsAllowed', 'none');

        Xc = (boundBox(1) + boundBox(4)/2)/size(frame, 2);
        Yc = (boundBox(2) + boundBox(3)/2)/size(frame, 1);
        H = (boundBox(3))/size(frame, 1);
        W = (boundBox(4))/size(frame, 2);
        
        fprintf(outputFile, '%d %0.6f %0.6f %0.6f %0.6f\n', coneColorID, Xc, Yc, W, H);
    end
    
    fclose(outputFile);
end