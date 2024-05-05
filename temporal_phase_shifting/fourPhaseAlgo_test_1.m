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
T_h = 2; % periode in px
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

