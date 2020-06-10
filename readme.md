# YoloColorParse

This repository contains the codes and instructions for reviewing the automatically generated colour labels. Since the original MIT dataset does not contain colour labels for their traffic cone data, it was decided add these labels in so that the object detector algorithms can split the cones into different classes based on the labelled colours.

* MATLAB script uses a simple threshold-based approach to automate the colour labels.
* However, this is not always accurate and would have incorrect labels if the video frames are captured during dawn or dusk.
* Now this is where you come in! We need your help to review and correct any mislabeled cones.

In this readme, we will go through the required setup so that you can start reviewing the labelled images in no time.



## Prerequisites

* `MATLAB` (Local Installation or Online)
* `YOLO_Dataset`

Put ``YOLO_Dataset`` and ``yolov3-training_all.csv`` in root folder. 

The `YOLO_dataset` files can be downloaded from the MIT repository [here](https://github.com/cv-core/MIT-Driverless-CV-TrainingInfra/tree/master/CVC-YOLOv3#download-manually-optional), or you can use the direct link for [`YOLO_dataset`](https://storage.cloud.google.com/mit-driverless-open-source/YOLO_Dataset.zip?authuser=1)/[`yolov3-training_all.csv`](https://storage.cloud.google.com/mit-driverless-open-source/yolov3-training/all.csv?authuser=1) which should initiate the download. The dataset is about 1.6GB in size.

Note that the output text files are saved to to ``output/`` directory.

## Manual Usage
* Change Line 7, ``startingFrameID = 1;`` for starting frame.
* Press `1`, `2`, `3` for Blue, Orange, Yellow to select the colour that you want to assign.
* Left-click bounding box to change colour.
* Right-click bounding box to zoom in.
* Right-click or press `R` to revert zoom.
* Press `E` to advance frame.
* Press `Q` to go back one frame.
* Press `F` to tag a frameID as an "error", tagged labels will be in `./errorFrames.txt`.

Note that if you use the back-button `Q` you would re-write the previous text label, which means that you are essentially starting from scratch.

~~In addition, moving or modifying the bounding box anchor actually does not change the results at all. All we are changing here is the traffic cone colour label.~~ (Changed rectangle interface, should no longer be moveable.)

## Review Instructions

Please see the Wiki for more instructions on how to review the images.

## Submitting the Reviewed Labels

Once you have finished reviewing, you can make a pull request with all the labelled text files. For instance, if you were assigned with the first 500 images (ID from 1 to 500), then you should have 500 output text files, each corresponding to a video frame.

Alternatively, for those who are doing this on a one-off basis, you can zip up the output text files to either Andrew or Steven. Note that the pull request approach is preferred.

## Contact

If there is any questions, problems or issues regarding this, please contact either Andrew or Steven on the MUR Driverless Slack. DM or posting on the `spatial-perception` channel are both fine.

## Todo
- [x] Renable `Q` to reverse in frames.
- [x] Include the MIT labels `.csv` files in this repository so that people would only have to download the images. Split the labelling into `train` and `validation` groups, since the `validation` set requires extra attention and quality control.
- [ ] Script currently rewrites output textfile, textfile preview tbd
- [ ] Add support for reviewing bounding boxes by reading the text files.
