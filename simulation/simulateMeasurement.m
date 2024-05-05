%% Allocate Projector Window
p = get(0, "MonitorPositions");
f = figure(1);
f.Position = p(2, :);
colormap gray
axes(f,"Units","normalized","Position",[0 0 1 1])
WindowAPI(f, 'position', 'full')
WindowAPI(f, 'clip');

%% Basic Parameters
% Geometric
projectorSize_u = p(2,3);
projectorSize_v = p(2,4);
detectorSize = [1080 1920];
field_x = 40; % mm
projectorResolution = projectorSize_u/field_x; % <-- 48 px/mm (aka sampling frequency)

% Methodical
N = 4; % 4-Phase Algorithm
T_l = projectorSize_u+1; % Periode of low frequency fringe pattern in px
T_h = 50; % Periode of high frequency fringe pattern in px

%% Define spatial vars
t_ = (1:projectorSize_u);
t = ones(projectorSize_v,1) * t_;

%% Define Object Topografie
Topog = zeros(detectorSize);
helpVec = (1:300)*600/300+5;
helpVec2 = ones(500,1);
helpMat = helpVec2 * helpVec;
Topog(300:800-1,500:800-1) = helpMat;
Topog(300:800-1,800:1100-1) = 600+5-helpMat;
% figure(3); colormap gray; imagesc(Topog)

%% Define noise signal
noiseAmp = 0.20;

%% Allocate memory for frames to capture
imagesLowFreq = zeros(detectorSize(1),detectorSize(2),N);
imagesHighFreq = zeros(detectorSize(1),detectorSize(2),N);

%% Perform Measurement
% 1. Low Frequency
phi_l = 2*pi*(t+Topog)/T_l;
for ii=0:N-1
    % 1. Project low freq pattern
    I = cos(phi_l-2*pi*ii/N);
    imagesc(I)
    axis off
    pause(0.1)
    % 2. record image
    % [A, ts] = snapshot(cam);
    A = I + noiseAmp * rand(detectorSize);
    imagesLowFreq(:,:,ii+1) = A;
end
% 2. High Frequency
phi_h = 2*pi*(t+Topog)/T_h;
for ii=0:N-1
    % 1. Project high freq pattern
    I = cos(phi_h-2*pi*ii/N);
    imagesc(I)
    axis off
    pause(0.1)
    % 2. record image
    % [A, ts] = snapshot(cam);
    A = I + noiseAmp * rand(detectorSize);
    imagesHighFreq(:,:,ii+1) = A;
end
figure(2)
colormap gray
imagesc(A)
% Calculate wrapped Phase
% calc wrapped phase
phi_l_w = atan2(imagesLowFreq(:,:,4) - imagesLowFreq(:,:,2), imagesLowFreq(:,:,3) - imagesLowFreq(:,:,1));
phi_h_w = atan2(imagesHighFreq(:,:,4) - imagesHighFreq(:,:,2), imagesHighFreq(:,:,3) - imagesHighFreq(:,:,1));
% remove offset
% phi_l_w = phi_l_w - phi_l_w(1,1);
% phi_h_w = phi_h_w - phi_h_w(1,1);

% Unwrap Phase -> calculate k
k = round((T_l/T_h*phi_l_w-phi_h_w)/(2*pi));
PHI_h = phi_h_w + k*2*pi;

figure(3)
colormap gray
imagesc(PHI_h)
figure(4)
plot(phi_h_w(500,:))
hold on
plot(k(500,:)*2*pi)
hold off

%% Reconstruct and Plot 3D Topografie
phi_h_ref = 2*pi*(t)/T_h;
topo_measured = PHI_h - phi_h_ref;
figure(5)
colormap jet
set(gcf,'Color', 'black');
mesh(topo_measured(50:end-50,50:end-50))
ax = gca;
ax.Color = 'black';
ax.YColor = 'w';
ax.XColor = 'w';
ax.ZColor = 'w';
ax.GridColor = 'w';
ax.GridAlpha = 0.9;