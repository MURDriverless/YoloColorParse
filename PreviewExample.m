clc;
clear;
close all;

startID = 1;
endID = 500;

% give directory to image dataset and frames labels
frameSet = FrameSet('./YOLO_Dataset', '../YoloColorParse_Data/frames');

boxDatas = readtable('yolov3-training_all.csv', 'HeaderLines', 2);
boxDatas = sortrows(boxDatas, 'Var1', 'ascend');

frameNames = boxDatas.(1)(startID:endID);
dinfo = cellfun(@(x) x, frameNames, 'UniformOutput', 0)';

tmp = cellfun(@(x) x(1:end-4), dinfo, 'UniformOutput', 0);
frameSet.setPreviewList(tmp);