clc;
clear;
close all;

global mainFigure clickColorID boxColorsStr boxColors boxDatas frameID objectIds

frameID = 1;

boxDatas = readtable('yolov3-training_all.csv', 'HeaderLines', 2);

% sort video frames in ascending order to ensure consistent ordering
boxDatas = sortrows(boxDatas, 'Var1', 'ascend');

boxColors = {'blue', [255,165,0]/255, 'yellow'};
boxColorsStr = {'Blue', 'Orange', 'Yellow'};
objectIds = [0, 1, 2];

mkdir('./output')

mainFigure = figure('units','normalized');
clickColorID = 0;
hold on
disableDefaultInteractivity(gca)
set(mainFigure,'KeyPressFcn',@hotKeyFunc);
updateClickColor();

loadImage(frameID);

return

function loadImage(ii)
    global boxDatas rectangs fileName objectIds boxColorsStr boxColors
    fileName = boxDatas(ii,1);
    boundStrings = boxDatas(ii, 6:end);
    
    frame = imread(['./YOLO_Dataset/', fileName.(1){1}]);
    
    cla;
    imshow(frame, 'parent', gca);
    title(fileName.(1){1}, 'Interpreter', 'none');
    xlim([1 size(frame,2)]);
    ylim([1 size(frame,1)]);
    
    rectangs = {};

    for jj = 1:numel(boundStrings)
        boundString = boundStrings.(jj){1}; % X0, Y0, H0, W0
        
        if numel(boundString) < 1
            break;
        end
        
        boundBox = str2num(boundString);
        
        crop = frame(boundBox(2) + (1:boundBox(3)), ...
                     boundBox(1) + (1:boundBox(4)), :);
                  
%         crop = crop(:, (-1:1) + floor(size(crop,2)/2), :);
%         crop = crop(floor(size(crop,1)/2):end, :, :);
        
%         crop_HSV = rgb2hsv(crop);
        
        colorCount = [0, 0, 0];
        
        % Blue
        [mask, ~] = createMaskBlue(crop); % RGB masking
        colorCount(1) = sum(mask, 'all');
        
        % Orange
        [mask, ~] = createMaskOrange(crop);
        colorCount(2) = sum(mask, 'all');
        
        % Yellow
        [mask, ~] = createMaskYellow(crop);
        colorCount(3) = sum(mask, 'all');

        coneColorID = objectIds(colorCount == max(colorCount));
        coneColor = boxColors(colorCount == max(colorCount));
        
        rectangs{jj} = images.roi.Rectangle(gca, 'Position', boundBox([1 2 4 3]), 'Color', coneColor{1}, 'InteractionsAllowed', 'translate');
        addlistener(rectangs{jj},'ROIClicked',@allevents);

        Xc = (boundBox(1) + boundBox(4)/2)/size(frame, 2);
        Yc = (boundBox(2) + boundBox(3)/2)/size(frame, 1);
        H = (boundBox(3))/size(frame, 1);
        W = (boundBox(4))/size(frame, 2);
        
        rectangs{jj}.UserData = {coneColorID, Xc, Yc, H, W};
    end
end

function allevents(src,evt)
    global clickColorID boxColors
    evname = evt.EventName;
    switch(evname)
        case{'ROIClicked'}
            src.UserData{1} = clickColorID;
            src.Color = boxColors{clickColorID+1};
    end
end

function saveOutputFile()
    global rectangs fileName
    temp = fileName.(1){1};
    
    outputFile = fopen(['./output/', temp(1:end-3), 'txt'], 'w');
    
    for ii = 1:numel(rectangs)
        boundData = rectangs{ii}.UserData;
        fprintf(outputFile, '%d %0.6f %0.6f %0.6f %0.6f\n', boundData{1}, ... 
                                                            boundData{2}, ... 
                                                            boundData{3}, ... 
                                                            boundData{4}, ...
                                                            boundData{5});
    end
    
    fclose(outputFile);
end

function hotKeyFunc(src,event)
    global clickColorID frameID
    switch(event.Key)
        case('1')
            clickColorID = 0;
            updateClickColor();
        case('2')
            clickColorID = 1;
            updateClickColor();
        case('3')
            clickColorID = 2;
            updateClickColor();
%         case('q')
%             saveOutputFile()
%             
%             if frameID > 1
%                 frameID = frameID - 1;
%                 loadImage(frameID);
%             end
        case('e')
            saveOutputFile()
            frameID = frameID + 1;
            loadImage(frameID);
    end
    
end

function updateClickColor()
    global mainFigure boxColorsStr clickColorID
    figure(mainFigure);
    xlabel(boxColorsStr{clickColorID+1});
end