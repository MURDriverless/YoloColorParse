clc;
clear;
close all;

frameSet = FrameSet('./YOLO_Dataset', './output');

dinfo = dir('./output/*.txt');
tmp = cellfun(@(x) x(1:end-4), {dinfo.name}, 'UniformOutput', 0);
frameSet.setPreviewList(tmp);