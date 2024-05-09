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

%% Methodical
N = 4; % 4-Phase Algorithm
% Fundamental wavelengths in Pixel
lam_01 = 20;
lam_02 = 21.581;
lam_03 = 23.162;

% Schwebung 1.x
Lam_11 = lam_01 * lam_02 /(lam_02 - lam_01);
Lam_12 = lam_02 * lam_03 /(lam_03 - lam_02);
Lam_13 = lam_01 * lam_03 /(lam_03 - lam_01);
% Schwebung 2.x
Lam_21 = Lam_11 * Lam_12 /(Lam_12 - Lam_11);
Lam_22 = Lam_12 * Lam_13 /(Lam_13 - Lam_12);

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
noiseAmp = 0.2;

%% Allocate memory for frames to capture
imagesLam_01 = zeros(detectorSize(1),detectorSize(2),N);
imagesLam_02 = zeros(detectorSize(1),detectorSize(2),N);
imagesLam_03 = zeros(detectorSize(1),detectorSize(2),N);

%% Perform Measurement
% 1. Lambda 1
phi_01_true = 2*pi*(t+Topog)/lam_01;
for ii=0:N-1
    I = cos(phi_01_true-2*pi*ii/N);
    imagesc(I)
    axis off
    pause(0.1)
    % record image
    % [A, ts] = snapshot(cam);
    A = I + noiseAmp * rand(detectorSize);
    imagesLam_01(:,:,ii+1) = A;
end
% 2. Lambda 2
phi_02_true = 2*pi*(t+Topog)/lam_02;
for ii=0:N-1
    I = cos(phi_02_true-2*pi*ii/N);
    imagesc(I)
    axis off
    pause(0.1)
    % record image
    % [A, ts] = snapshot(cam);
    A = I + noiseAmp * rand(detectorSize);
    imagesLam_02(:,:,ii+1) = A;
end
% 3. Lambda 3
phi_03_true = 2*pi*(t+Topog)/lam_03;
for ii=0:N-1
    I = cos(phi_03_true-2*pi*ii/N);
    imagesc(I)
    axis off
    pause(0.1)
    % record image
    % [A, ts] = snapshot(cam);
    A = I + noiseAmp * rand(detectorSize);
    imagesLam_03(:,:,ii+1) = A;
end

% figure(2)
% colormap gray
% imagesc(A)

%% Calculate wrapped Phase
phi_01 = atan2(imagesLam_01(:,:,4) - imagesLam_01(:,:,2), imagesLam_01(:,:,3) - imagesLam_01(:,:,1));
phi_02 = atan2(imagesLam_02(:,:,4) - imagesLam_02(:,:,2), imagesLam_02(:,:,3) - imagesLam_02(:,:,1));
phi_03 = atan2(imagesLam_03(:,:,4) - imagesLam_03(:,:,2), imagesLam_03(:,:,3) - imagesLam_03(:,:,1));
% remove offset ?
phi_01 = phi_01 + pi;
phi_02 = phi_02 + pi;
phi_03 = phi_03 + pi;

% Schwebung 1.x: reines differenzsignal:
phi_11 = phi_01 - phi_02;
phi_12 = phi_02 - phi_03;
phi_13 = phi_01 - phi_03;
% Schwebung 1.x: phasenrichtiges Schwebungssignal:
phi_11(phi_11<0) = phi_11(phi_11<0) + 2*pi;
phi_12(phi_12<0) = phi_12(phi_12<0) + 2*pi;
phi_13(phi_13<0) = phi_13(phi_13<0) + 2*pi;
% Schwebung 1.x: Skaliere phi_1x auf gleiche Steigung wie phi_0x
phi_11_scaled = Lam_11/lam_01 * phi_11;
% % Schwebung 1.x: Streifenordnung O_phi(x)
% O_phi_11 = round((phi_11_scaled - phi_01)/(2*pi));

% Schwebung 2.1: reines differenzsignal
phi_21 = phi_11 - phi_12;
% Schwebung 2.1: phasenrichtiges Schwebungssignal:
phi_21(phi_21<0) = phi_21(phi_21<0) + 2*pi;
% Schwebung 2.1: Skaliere phi_21 auf gleiche Steigung wie phi_11
phi_21_scaled = Lam_21/Lam_11 * phi_21;
phi_22_scaled = Lam_21/Lam_12 * phi_21;
% Schwebung 2.1: Streifenordnung O_phi(x)
O_phi_21 = round((phi_21_scaled - phi_11)/(2*pi));
O_phi_22 = round((phi_22_scaled - phi_12)/(2*pi));

% Entfalte Schwebung 1.x:
PHI_11 = phi_11 + O_phi_21 * 2*pi;
PHI_12 = phi_12 + O_phi_22 * 2*pi;
% Mittelwert
PHI_1avg = 0.5*(PHI_11 + PHI_12*Lam_12/Lam_11);

% Entfalte Phasen 0.x:
% Skaliere steigung der Schwebung 2 auf Phase
PHI_1avg_01_scaled = Lam_11/lam_01 * PHI_1avg;
PHI_1avg_02_scaled = Lam_11/lam_02 * PHI_1avg;
PHI_1avg_03_scaled = Lam_11/lam_03 * PHI_1avg;
% Streifenordnung auf basis des Mittelwerts
O_phi_11 = round((PHI_1avg_01_scaled - phi_01)/(2*pi));
O_phi_12 = round((PHI_1avg_02_scaled - phi_02)/(2*pi));
O_phi_13 = round((PHI_1avg_03_scaled - phi_03)/(2*pi));
% Entfalte Schwebung 1.x:
PHI_01 = phi_01 + O_phi_11 * 2*pi;
PHI_02 = phi_02 + O_phi_12 * 2*pi;
PHI_03 = phi_03 + O_phi_13 * 2*pi;

% Mittelwert aller Phasen
PHI_0avg = 1/3*(PHI_01 + PHI_02*lam_02/lam_01 + PHI_03*lam_03/lam_01);

figure(3)
colormap gray
imagesc(PHI_0avg)
figure(4)
clf
hold on
plot(PHI_01(1,:),'DisplayName','1')
plot(PHI_02(1,:),'DisplayName','2')
plot(PHI_03(1,:),'DisplayName','3')
plot(PHI_0avg(1,:),'DisplayName','3')
hold off
legend 
return

%% Reconstruct and Plot 3D Topografie
phi_h_ref = 2*pi*(t)/lam_01;
topo_measured = PHI_0avg - phi_h_ref;
figure(5)
colormap jet
set(gcf,'Color', 'black');
mesh(topo_measured(150:end-150,150:end-50))
ax = gca;
ax.Color = 'black';
ax.YColor = 'w';
ax.XColor = 'w';
ax.ZColor = 'w';
ax.GridColor = 'w';
ax.GridAlpha = 0.9;