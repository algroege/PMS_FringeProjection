% Filename: SimpleOrthographicCalibration.m
% Description: calibration script using a number of checkerboard images
% (simple version)

%% Add path if needed
% addpath('../src/');

%% Read files
% Much better result if no degeneracy in calibration images
folder = "D:\ProMakroS\mit_Kipp\";
images = read_images(folder,'.bmp');

%% Run calibration
[calib_struct, target_struct]= calibrate(images, 3);

%% Visualize extrinsics
visualize_extrinsics(calib_struct.extrinsics, target_struct, 'z_offset', 100,...
    'origin', 'camera');

%% Correct for distortion and visualize
imgs_correct = correctDistortion(images, calib_struct.intrinsics);

%%
figure(1)
imshow(imgs_correct{4});
title("Corrected image 1");