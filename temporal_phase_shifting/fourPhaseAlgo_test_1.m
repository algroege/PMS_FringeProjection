%% 4-Phasen Algorithmus
% Evaluate screen size
p = get(0, "MonitorPositions");
size_u = p(2,3);
size_v = p(2,4);

A = 0.0 * rand(size_v,size_u); % average Intensity
B = 1; % fringe modulation

field_x = 40; % mm
projectorResolution = size_u/field_x; % <-- 48 px/mm (aka sampling frequency)
t_ = (1:size_u);
t = ones(size_v,1) * t_;

%% 1. High Frequency Fringe Pattern
% Erzeuge Streifenmuster mit x lp/mm
T_h_mm = 1;
T_h = 50; % periode in px
% T_h = T_h_mm*projectorResolution;
phi_h = 2*pi*t/T_h;
% phase shifted Frames
I_1_h = A + B*cos(phi_h-2*pi*0/4);
I_2_h = A + B*cos(phi_h-2*pi*1/4);
I_3_h = A + B*cos(phi_h-2*pi*2/4);
I_4_h = A + B*cos(phi_h-2*pi*3/4);
% calc wrapped phase
phi_h_ = atan2((I_4_h - I_2_h),(I_3_h - I_1_h));
% remove offset
phi_h_ = phi_h_ - phi_h_(1,1);

%% 1. Low Frequency Fringe Pattern
T_l = size_u; % periode in pixel
phi_l = 2*pi*t/T_l;
% phase shifted Frames
I_1_l = A + B*cos(phi_l-2*pi*0/4);
I_2_l = A + B*cos(phi_l-2*pi*1/4);
I_3_l = A + B*cos(phi_l-2*pi*2/4);
I_4_l = A + B*cos(phi_l-2*pi*3/4);
% calc wrapped phase
PHI_l = atan2((I_4_l - I_2_l),(I_3_l - I_1_l));
% remove offset
PHI_l = PHI_l - PHI_l(1,1);

%% calculate k
k = round((T_l/T_h*PHI_l-phi_h_)/(2*pi));

PHI_h = phi_h_ + k*2*pi;
%% plot
figure(10)
subplot(2,2,1)
colormap gray
imagesc(I_1_l)
title('Niederfrequente Intensitätsmuster 1 von 4')

subplot(2,2,2)
colormap gray
imagesc(I_1_h)
title('Intensitätsmuster 2 von 4')

subplot(2,2,3)
colormap gray
imagesc(phi_h)
title('Ursprüngliche Phase phi')

subplot(2,2,4)
colormap gray
imagesc(phi_h_)
title('Berechnete Phase phi')

figure(11)
plot(phi_h(1,:))
hold on
% plot(phi_h_(1,:))
plot(PHI_h(1,:))
% plot(k(1,:))
hold off

%% Plot on Beamer
p = get(0, "MonitorPositions");
f = figure(1);
f.Position = p(2, :);
colormap gray
axes(f,"Units","normalized","Position",[0 0 1 1])
f.WindowState = "maximized";
f.MenuBar = "none";
f.ToolBar = "none";
f.NumberTitle = "off";

WindowAPI(f, 'position', 'full')
WindowAPI(f, 'clip');
%%

imagesc(I_1_h)
axis off
pause(0.2)
imagesc(I_2_h)
axis off
pause(0.2)
imagesc(I_3_h)
axis off
pause(0.2)
imagesc(I_1_h)
axis off

%% 
% 1. Project low frequency pattern
for ii=0:4-1
    I = A + B*cos(phi_l-2*pi*ii/4);
    imagesc(I)
    axis off
    pause(0.1)
end

% 2. Project high frequency pattern
for ii=1:4
    I = A + B*cos(phi_h-2*pi*ii/4);
    imagesc(I)
    axis off
    pause(0.1)
end

%%
i2_h_fft = fft(I_1_h(1,:));
figure(5)
colormap gray
plot((projectorResolution/size_u*(0:size_u-1)),abs((i2_h_fft)))
% image(abs(i2_h_fft))


%%
% Pseudo Topografie
Topog = zeros(detectorSize);
helpVec = (1:300)*600/300+5;
helpVec2 = ones(500,1);
helpMat = helpVec2 * helpVec;
Topog(300:800-1,500:800-1) = helpMat;
Topog(300:800-1,800:1100-1) = 500+5-helpMat;
% figure(3)

% Allocate Projector Window
p = get(0, "MonitorPositions");
f = figure(1);
f.Position = p(2, :);
colormap gray
axes(f,"Units","normalized","Position",[0 0 1 1])
WindowAPI(f, 'position', 'full')
WindowAPI(f, 'clip');
% f.WindowState = "maximized";
% f.MenuBar = "none";
% f.ToolBar = "none";
% f.NumberTitle = "off";
N = 4; % 4-Phase Algorithm
% detectorSize = [2050 2448];
detectorSize = [1080 1920];
imagesLowFreq = zeros(detectorSize(1),detectorSize(2),N);
imagesHighFreq = zeros(detectorSize(1),detectorSize(2),N);
noiseAmp = 0.001;
% Low Frequency
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
% High Frequency
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
k = ((T_l/T_h*phi_l_w-phi_h_w)/(2*pi));
% k_ = round(k);
%
PHI_h = phi_h_w + k*2*pi;

figure(3)
colormap gray
imagesc(PHI_h)
figure(4)
plot(phi_h_w(500,:))
hold on
plot(k(500,:)*2*pi)
hold off
%% Config CAM
delete(imaqfind);
v = videoinput('gige', 1, 'Mono8');
s = v.Source;

% Determine optimum streaming parameters as described in the
% "GigE Vision Quick Start Configuration Guide"
s.PacketSize = 9000;
% s.PacketDelay =

% Specify total number of frames to be acquired
% One frame is acquired for each external signal pulse.
numFrames = 1;
v.FramesPerTrigger = 1;
v.TriggerRepeat = numFrames - 1;

% Specify 'hardware' videoinput trigger type
triggerconfig(v, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
%triggerconfig(v, 'manual');

% This requires setting the TriggerSelector first; once a TriggerSelector
% value is selected, setting a trigger property (for example,
% TriggerMode to 'on') applies only to the specified trigger mode (FrameStart).
s.TriggerSelector = 'FrameStart';
s.TriggerSource = 'Line1';
s.TriggerActivation = 'RisingEdge';
s.TriggerMode = 'on';

% Specify a constant exposure time for each frame
s.ExposureMode = 'Timed';
s.ExposureTime = 500;

delete(v);
delete(imaqfind);

%% Load Measurement Data
try
    cam = gigecam('15148');
catch 
    clear cam;
    cam = gigecam('15148');
end

while(1)
    %tic
    try
        [A, ts] = snapshot(cam);
    catch 
        break
    end
    % Show aquired image
    figure(1)
    colormap(gray(256));
    imagesc(A);

        
    %% Save Image Files
    % imageFileName = datestr(now,'yymmddHHMMSSFFF');
    % baseFileName = [imageFileName, '_raw.bmp'];
    % fullFileName = fullfile(currentFolder, baseFileName);
    % imwrite(A, fullFileName);

    %% Save FFT Image Files
    % baseFileName = [imageFileName, '_fft.bmp'];
    % fullFileName = fullfile(currentFolder, baseFileName);
    %imwrite(uint8(FA), fullFileName);
    % i = i + 1;
%     pause(0.01);
    %toc
end
clear cam;

%%
Topog = zeros(detectorSize);
Topog(300:800,900:1200) = 1;
figure(3)
imagesc(Topog)