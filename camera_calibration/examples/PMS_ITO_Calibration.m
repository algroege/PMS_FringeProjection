% Filename: SimpleOrthographicCalibration.m
% Description: calibration script using a number of checkerboard images
% (simple version)

%% Add path if needed
% addpath('../src/');

%% Read files
% Much better result if no degeneracy in calibration images
folder = "D:\ProMakroS\mit_Kipp\";
images = read_images(folder,'.bmp');

%% Find key Points
patch_width = 3.0; % Kantenlänge in mm
[v_param0, target_struct, batch_img_pts, homographies] = estimate_params(images, patch_width);


%% Run calibration
[calib_struct, target_struct]= calibrate(images, 3);

%% Calculate Reprojection Error
%1. worldPoints to ImagePoints: target struct --> image Coordinates
    % param_vec = [alpha, beta, gamma, u0, v0, k1, p1, p2, q1, q2, ra1, rb1, rc1, tx1,
    %   ty1, ..., ran, rbn, rcn, txn, tyn]
param_vec = calib_struct.vector;
pts_w = target_struct.w_coord;
pts_i = batch_forward_model_v1(param_vec, pts_w, 'distort_plane', 'normal', 'distort_model', 'none');

pts_w_test = [3 1.5];
pts_i_test = batch_forward_model_v1(param_vec, pts_w_test, 'distort_plane', 'normal', 'distort_model', 'none');



%% Visualize extrinsics
visualize_extrinsics(calib_struct.extrinsics, target_struct, 'z_offset', 100,...
    'origin', 'camera');


%% Correct for distortion and visualize
imgs_correct = correctDistortion(images, calib_struct.intrinsics);

%% Select Image
img_num = 1;

%% Calculate Reprojection Error
pts_w_test = [10*3 1.5];
pts_i_test = batch_forward_model_v1(param_vec, pts_w_test, 'distort_plane', 'normal', 'distort_model', 'rad_tan');

%% Plot Repro Error
% diff
reproError = batch_img_pts - pts_i;
mean_reproError = squeeze(mean(reproError,[1,2]));
% Plot all Repro Errors 
figure(2)
% legend_string = []
clf
for i=1:size(reproError,3)
    hold on 
    plot(reproError(:,1,i),reproError(:,2,i), 'x', 'DisplayName', ['Image ' num2str(i)])
end
hold off
legend show
axis equal
box on
grid on


%% Backward Projection from Pixel to World
 % Extract parameters
alpha = param_vec(1);
beta = param_vec(2);
gamma = param_vec(3);
u0 = param_vec(4);
v0 = param_vec(5);
v_distort = param_vec(4:10);
% Construct intrinsic matrix
K = [alpha 0 0; 0 beta 0; u0 v0 1];
if 0 % skew
    K(2,1) = gamma; % introduces dependency on gamma
end
if 0 % isotropic
    K(2,2) = alpha; % eliminates dependency on beta
end

% Loop over images
for k=img_num:img_num
    vRot = param_vec(5*k+6:5*k+8);
    vT = param_vec(5*k+9:5*k+10);
    % Convert rotation matrix
    R = rotationVectorToMatrix(vRot); % MATLAB defines rotation matrix with row vectors
    % Construct extrinsic matrix
    E = [R(1:2,1:2) [0;0]; vT 1];
end

%% Plot Calibration Image
img_num = 5;
I = imgs_correct{img_num};
I = insertMarker(I, batch_img_pts(:,:,img_num), 'o', 'Color', 'red', 'Size', 20);
I = insertMarker(I, pts_i(:,:,img_num), 'x', 'Color', 'green', 'Size', 20);
I = insertMarker(I, pts_i_test(:,:,img_num), 'x', 'Color', 'blue', 'Size', 20);

% E
vRot = [0 0 0];
vT = [0 0];
% Convert rotation matrix
R = rotvec2mat3d(vRot); % MATLAB defines rotation matrix with row vectors
% Construct extrinsic matrix
E = [R(1:2,1:2) [0;0]; vT 1];

f=figure(1);
set(f,'WindowButtonDownFcn',{@mytestcallback , E, K, I})
imshow(I);
title("Corrected image 1");
viscircles(batch_img_pts(:,:,img_num),max(abs(reproError(:,:,img_num)),[],2));


function mytestcallback(~,~,E,K,I)
    pt = get(gca,'CurrentPoint');
    pt = [pt(1,1),pt(1,2)];
    fprintf('Clicked: %d %d\n', pt(1,1),pt(1,2));
    pts_w = backward_core(K,E,pt);
    I_ = insertText(I, pt, num2str(pts_w(1,1:2)), FontSize=60);
    imshow(I_);
end
