%% 4-Phasen Algorithmus
A = 0.5 * rand(100,100); % average Intensity
B = 1; % fringe modulation
t_ = linspace(1,100);
t = ones(length(t_),1) * t_;

%% 1. High Frequency Fringe Pattern
T_h = 2.6; % periode in pixel
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
T_l = 100; % periode in pixel
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

%%