clc;
clear;
close all;

global mainFigure clickColorID boxColorsStr boxColors boxDatas frameID objectIds startingFrameID

startingFrameID = 1;

outputFolderName = './output';

%% Do not touch
frameID = startingFrameID;
boxDatas = readtable('yolov3-training_all.csv', 'HeaderLines', 3, 'Format', 'auto');

% sort video frames in ascending order to ensure consistent ordering
boxDatas = sortrows(boxDatas, 'Var1', 'ascend');

boxColors = {'blue', [255,165,0]/255, 'yellow', 'red'};
boxColorsStr = {'Blue', 'Orange', 'Yellow', 'False Positive'};
objectIds = [0, 1, 2, 3];

if ~exist(outputFolderName, 'dir')
    % Folder does not exist so create it.
    mkdir(outputFolderName);
end

mainFigure = figure('units','normalized', 'WindowButtonDownFcn',@drawingMode);
clickColorID = 0;
hold on
disableDefaultInteractivity(gca)
set(mainFigure,'KeyPressFcn',@hotKeyFunc);
updateClickColor();

loadImage(frameID);

return

function loadImage(ii)
    global boxDatas rectangs fileName objectIds boxColorsStr boxColors frame
    fileName = boxDatas(ii,1);
    boundStrings = boxDatas(ii, 6:end);
    
    frame = imread(['./YOLO_Dataset/', fileName.(1){1}]);
    
    cla;
    dispImage = imshow(frame, 'parent', gca);
    set(dispImage, 'ButtonDownFcn', @axisEvents);
    title([fileName.(1){1}, ', frameID: ', num2str(ii)], 'Interpreter', 'none');
    xlim([1 size(frame,2)]);
    ylim([1 size(frame,1)]);
    
    rectangs = {};

    for jj = 1:numel(boundStrings)
        boundString = boundStrings.(jj){1}; % X0, Y0, H0, W0
        
        % before extracting bounding box locations, remove any double
        % quotes inside boundString, otherwise str2num may return an error
        boundString = strrep(boundString, '"', '');
        
        if numel(boundString) < 1
            break;
        end
        
        % before extracting bounding box locations, remove any double
        % quotes inside boundString, otherwise str2num may return an error
        boundString = strrep(boundString, '"', '');
        
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
        
        % Event that no color is detect or multiple colors is detected,
        % take first
        coneColorID = coneColorID(1);
        coneColor = coneColor(1);

        rectangs{jj} = rectangle('Position', boundBox([1 2 4 3]), ...
        'linewidth', 1, ...
        'EdgeColor', coneColor{1}, ...
        'FaceColor', [0, 0, 0, 0.01], ...
        'ButtonDownFcn', @rectEvents);

        Xc = (boundBox(1) + boundBox(4)/2)/size(frame, 2);
        Yc = (boundBox(2) + boundBox(3)/2)/size(frame, 1);
        H = (boundBox(3))/size(frame, 1);
        W = (boundBox(4))/size(frame, 2);
        
        rectangs{jj}.UserData = {coneColorID, Xc, Yc, H, W};
    end
end

function axisEvents(src,evt)
    evname = evt.EventName;
    selectType = src.Parent.Parent.SelectionType;
    
    if strcmp(evname, 'Hit') && strcmp(selectType, 'alt')
        xlim([1 size(src.CData,2)]);
        ylim([1 size(src.CData,1)]);
    end
end

function drawingMode(src,evt)
    src.WindowButtonMotionFcn = @wbmcb;
    src.WindowButtonUpFcn = @wbucb;
    
    function wbmcb(src,callbackdata)
        global rectangs clickColorID boxColors
        
        cpt = get(gca,'CurrentPoint');
        mousePos = cpt(1,1:2);
        
        for ii = 1:numel(rectangs)
            rectang = rectangs{ii};
            rectPos = rectang.Position;
            
            xCheck = (rectPos(1) < mousePos(1)) & (mousePos(1) < (rectPos(1) + rectPos(3)));
            yCheck = (rectPos(2) < mousePos(2)) & (mousePos(2) < (rectPos(2) + rectPos(4)));
            
            if xCheck && yCheck
                rectang.UserData{1} = clickColorID;
                rectang.EdgeColor = boxColors{clickColorID+1};
            end
        end
    end

    function wbucb(src,callbackdata)
      src.WindowButtonMotionFcn = '';
      src.WindowButtonUpFcn = '';
    end
end

function rectEvents(src,evt)
    global clickColorID boxColors frame
    evname = evt.EventName;
    
    % Parent is axis, Parent.Parent is figure
    selectType = src.Parent.Parent.SelectionType;
    if strcmp(evname, 'Hit')
        if strcmp(selectType, 'normal')
            src.UserData{1} = clickColorID;
            src.EdgeColor = boxColors{clickColorID+1};
        elseif strcmp(selectType, 'alt')
            boxDim = [src.UserData{2:5}];
            
            xlim(size(frame,2) * (boxDim(1) + boxDim(4) .* [-1, 1]));
            ylim(size(frame,1) * (boxDim(2) + boxDim(3) .* [-1, 1]));
        end
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
    global clickColorID frameID startingFrameID frame
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
        case('4')
            clickColorID = 3;
            updateClickColor();
        case('q')
            saveOutputFile()
            
            if frameID > startingFrameID
                frameID = frameID - 1;
                loadImage(frameID);
            end
        case('e')
            saveOutputFile()
            frameID = frameID + 1;
            loadImage(frameID);
        case('r')
            xlim([1 size(frame,2)])
            ylim([1 size(frame,1)])
        case('f')
            saveDisp(frameID);
    end
    
end

function saveDisp(frameID)
    outputFile = fopen('./errorFrames.txt', 'a+');
    fprintf(outputFile, '%d\n', frameID);
    fclose(outputFile);
end

function updateClickColor()
    global mainFigure boxColorsStr clickColorID
    figure(mainFigure);
    xlabel(boxColorsStr{clickColorID+1});
end