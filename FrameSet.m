classdef FrameSet < handle
    properties (SetAccess = immutable)
        imageFolderPath
        textFolderPath
    end
    
    properties (Constant, Access = public)
        boxColors = {'blue', [255,165,0]/255, 'yellow'};
        boxColorsStr = {'Blue', 'Orange', 'Yellow'};
    end
    
    properties (Access = public)
        cImageName
        cImage
        previewList
        previewID
    end
    
    properties (Access = private)
        rectangs
    end
    
    methods
        function frameSet = FrameSet(imageFolderPath, textFolderPath)
            frameSet.imageFolderPath = imageFolderPath;
            frameSet.textFolderPath = textFolderPath;
        end
        
        function image = getImage(obj, imageName)
            image = imread(fullfile(obj.imageFolderPath, [imageName, '.jpg']));
        end
        
        function setPreviewList(obj, previewList)
            obj.previewList = previewList;
            obj.previewID = 1;
            
            obj.previewRects(obj.previewList{obj.previewID});
        end
        
        function saveOutputFile(obj)
            boundingBoxes = zeros(numel(obj.rectangs), 5);
            
            for ii = 1:numel(obj.rectangs)
                boundingBoxes(ii,:) = obj.rectangs{ii}.UserData;
            end
            
            writeFile = fopen(fullfile(obj.textFolderPath, [obj.cImageName, '.txt']), 'w');
            
            % Writes column by column, need to transpose boundingBoxes
            fprintf(writeFile, '%d %6f %6f %6f %6f\n', boundingBoxes');
            fclose(writeFile);
        end
        
        function previewRects(obj, imageName)            
            cFig = gcf;
            obj.cImageName = imageName;
            
            obj.cImage = obj.getImage(imageName);
            imshow(obj.cImage);
            title(imageName, 'Interpreter', 'none');
            imW = size(obj.cImage,2);
            imH = size(obj.cImage,1);
            hold on
            
            cFig.UserData.cColor = 0;
            cFig.KeyPressFcn = @(s,e) hotKeyFunc(s,e,obj);
            updateClickColor();
            
            try
                boundingBoxes = dlmread(fullfile(obj.textFolderPath, [imageName, '.txt']), ' ');
            catch
                fprintf("Failed to read %s.txt, File may be empty\n", imageName);
                return;
            end
            
            obj.rectangs = {};
            
            for ii = 1:size(boundingBoxes,1)
                boundColorID = boundingBoxes(ii,1);
                boundBox = boundingBoxes(ii,2:5);
                boundBox_m = boundBox([1 2 4 3]) - [0.5 0.5 0 0] .* boundBox([4 3 4 3]);
                boundBox_m = [imW, imH, imW, imH] .* boundBox_m;
                
                obj.rectangs{ii} = rectangle('Position', boundBox_m, ...
                    'linewidth', 1, ...
                    'EdgeColor', obj.boxColors{boundColorID+1}, ...
                    'FaceColor', [0, 0, 0, 0.01], ...
                    'ButtonDownFcn', @(s,e) rectEvents(s,e,obj));
                
                obj.rectangs{ii}.UserData = [boundColorID, boundBox];
            end
        end
    end
end

function rectEvents(src, evt, obj)
    evname = evt.EventName;
    % Parent is axis, Parent.Parent is figure
    selectType = src.Parent.Parent.SelectionType;
    if strcmp(evname, 'Hit')
        if strcmp(selectType, 'normal')
            src.UserData(1) = src.Parent.Parent.UserData.cColor;
            src.EdgeColor = FrameSet.boxColors{src.Parent.Parent.UserData.cColor+1};
        elseif strcmp(selectType, 'alt')
            boxDim = src.UserData(2:5);

            xlim(size(obj.cImage,2) * (boxDim(1) + boxDim(4) .* [-1, 1]));
            ylim(size(obj.cImage,1) * (boxDim(2) + boxDim(3) .* [-1, 1]));
        end
    end
end

function hotKeyFunc(src, event, obj)
    switch(event.Key)
        case('1')
            src.UserData.cColor= 0;
            updateClickColor();
        case('2')
            src.UserData.cColor = 1;
            updateClickColor();
        case('3')
            src.UserData.cColor = 2;
            updateClickColor();
        case('q')
            if numel(obj.previewList) > 0
                if obj.previewID > 1
                    obj.previewID = obj.previewID - 1;
                    obj.previewRects(obj.previewList{obj.previewID});
                end
            end
            obj.saveOutputFile();
        case('w')
            obj.saveOutputFile();
        case('e')
            if numel(obj.previewList) > 0
                if obj.previewID < numel(obj.previewList)
                    obj.previewID = obj.previewID + 1;
                    obj.previewRects(obj.previewList{obj.previewID});
                end
            end
            obj.saveOutputFile();
        case('r')
            resetImage(obj);
    end
end

function resetImage(obj)
    gcf;
    xlim([1 size(obj.cImage,2)])
    ylim([1 size(obj.cImage,1)])
end

function updateClickColor()
    cFig = gcf;
    xlabel(FrameSet.boxColorsStr{cFig.UserData.cColor+1});
end