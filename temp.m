% temp code trying to analyise new high gain brain tissue data

%% 
clc; clear all; close all
% load('/Volumes/GoogleDrive/My Drive/_Data/DEEP-TFM/2020-11-19/dmd_exp_tfm_mouseBrain_20201119_noCrop.mat')
load('/Volumes/GoogleDrive/My Drive/_Data/DEEP-TFM/2020-09-25_Cheng_8-4-3patternedBeads/dmd_exp_tfm_beads_20200925_noCrop.mat')

X3d       = Data.beads2_wf;
X3d       = double(X3d);

% [temp cr] = imcrop(X3d(:,:,1)*100);
% X3d       = X3d(cr(2):cr(2)+cr(4),cr(1):cr(1)+cr(3),:);

fun_var   = @(block_struct) var(block_struct.data(:));
fun_mean  = @(block_struct) mean(block_struct.data(:));

blaocksize = [5 5];
var_Xc    = blockproc(X3d,blaocksize,fun_var);
mu_Xc     = blockproc(X3d,blaocksize,fun_mean);

scatter(mu_Xc(:),var_Xc(:),'.');
% ylim([-200 1000])
% yticks(-200:50:1000)
set(gca,'yscale','log')

% B = 303.1325;
% x = mu_Xc(:) - B;
% y = var_Xc(:);

inds  = find(mu_Xc<1000 & var_Xc< 5000 & mu_Xc>305);
x     = mu_Xc(inds);
y     = var_Xc(inds);
scatter(x,y,'.');
% set(gca,'yscale','log')

B = 0;
x = x(:) - B;
y = y(:);

%cftool
% Fit
[xData, yData] = prepareCurveData( x, y );
ft = fittype( 'poly1' );                          % Set up fittype and options.
[fitresult, gof] = fit( xData, yData, ft );       % Fit model to data.

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'y vs. x', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'x', 'Interpreter', 'none' );
ylabel( 'y', 'Interpreter', 'none' );
grid on

%% 2020-11-28 

%imagesc(squeeze(xx_last{1}))
figure; hold on
for i = 1:length(xx_last)
  plot(squeeze(mean(xx_last{i},3)))
  leg_text{i} = num2str(i);
end
legend(leg_text);
  
figure; hold on
for i = 1:length(xx_last)
  hist(double(xx_last{i}(:)),250:350)
  alpha(.1)
  mu(i)     = mean(double(xx_last{i}(:)));
  sigSq(i)  = var (double(xx_last{i}(:)));
end

sigma_rd_e = 3;
figure;
subplot(1,3,1);plot(mu);ylabel('Bias [ADU]')
subplot(1,3,2);plot(sqrt(sigSq));ylabel('\sigma_{rd} [ADU]')
subplot(1,3,3);plot(sigma_rd_e/sqrt(sigSq));ylabel('g [e-/ADU]')
set(gca,'fontsize',24);

%% 2020-12-08 emccd paper: The Noise Performance of Electron Multiplying Charge-Coupled Devices

% figure 8 inset
M     = 1000;                     % [AU]    mean Em_gain
S_in  = 1:5;                      % [e-]    input signal (mean) 
x     = repmat(S_in,[1e4,1]);     
xhat  = poissrnd(x);              % [e-]    op signal in the absense of any F^2 variation (this is the inset of Fig8)

figure;hold on
clear h inds
for i = S_in
  [h(i,:) inds] = hist(xhat(:,i)*M,0:M:max(S_in)^2*M);
end
plot(inds,h)

%% 2020-12-09 Figure 8
M       = 100;                        % [AU]    mean Em_gain
S_in    = 1:5;                        % [e-]    input signal (mean) 
x       = repmat(S_in,[1e4,1]);     

alpha   = 0.01;                       % [AU]    bernuli success probability 
Ng      = round(log(M)/log(1+alpha)); %         Number of Em-gain stages

tic
xhat    = poissrnd(x);                % [e-]    op signal in the absense of any F^2 variation (this is the inset of Fig8)
xhat    = x;                          % [e-]    op signal in the absense of any F^2 variation (this is the inset of Fig8)
for i=1:Ng
  i
  xhat  = xhat + binornd(xhat,alpha);
end
toc
xhat_em = xhat;                       % [e-]    this is the signal output after Em-gain  

figure;hold on
clear h inds
for i = S_in
  xhat_i        = xhat(:,i);
  xhat_i        = xhat_i(xhat_i>0)
  [h(i,:) inds] = hist(xhat_i,0:5:max(S_in)*M*10);
end
plot(inds,h)
xlim([0 2000])
legend('1','2','3','4','5');

%% 2020-12-10 Try a forward simulation for Nuvu EMCCD
clc; clear all
pram              = f_praminit_nuvu();

pram.dataPath   = '/Volumes/GoogleDrive/My Drive/_Data/DEEP-TFM/2020-11-19/';
pram.datafName  = 'dmd_exp_tfm_mouseBrain_20201119_noCrop.mat';
load([pram.dataPath pram.datafName]);
% Yhat  = Data.reg1_sf;
% clear Data
load('./_Datasets/tfm_mouseBrain_20201119/mouseBrain_20201119_reg1_sf.mat')

%Y0   = Yhat(360:420 ,160:210, :);
Ymean    = Yhat(134:427 ,107:415, :);
X0    = (mean(Ymean,3)-pram.bias)/(pram.ADCfactor*pram.EMgain);
X0    = X0 - 10;

%X0   = double(imread('cameraman.tif'));

X0(X0(:)<0) = 0;
tic
[Xhat XhatADU]  = f_simulateIm_emCCD(X0,pram);
toc
imagesc([X0 Xhat/pram.EMgain]);axis image;colorbar

%% 2020-12-11 Try calibrate for ADCfactor and Bias to pre-process data
clc; clear all

% mouse brain
pram.dataPath     = '/Volumes/GoogleDrive/My Drive/_Data/DEEP-TFM/2020-11-19/';
pram.datafName    = 'dmd_exp_tfm_mouseBrain_20201119_reg_noCrop.mat';
load([pram.dataPath pram.datafName]);
Yhat  = double(Data.reg3_100um_wf);
clear Data

% beads 2020-09-25
pram.dataPath     = '/Volumes/GoogleDrive/My Drive/_Data/DEEP-TFM/2020-09-25_Cheng_8-4-3patternedBeads/';
pram.datafName    = 'dmd_exp_tfm_beads_20200925_noCrop.mat';
load([pram.dataPath pram.datafName]);
Yhat1 = double(Data.beads2_wf);
Yhat2 = double(Data.beads1_wf);
clear Data

%
Yhat              = Yhat1;
pram              = f_praminit_nuvu();
%[pram Y_preProc]  = f_calibCamPram_emCCD(Yhat,pram,'beads1');

Y                 = Yhat(360:420 ,160:210, :);
%Y                 = Yhat(313:373 ,225:286, :);
%Y                 = Yhat(340:370 ,225:255, :);

%pram.bias        = 300;
%pram.ADCfactor   = .25;
Y                 = Yhat(110:195 ,275:379, :);% beads 2

% Ymean             = mean(Y,3);
% Ymean             = Ymean - min(Ymean(:)) + pram.bias;
% Ymean             = (Ymean - pram.bias)/(pram.EMgain*pram.ADCfactor);

pram              = f_praminit_nuvu();
Y_preProc         = (Y - pram.bias)/(pram.EMgain*pram.ADCfactor);
Ymean             = mean(Y_preProc,3);
%Ymean             = mean(Ymean,3);
%Ymean(Ymean(:)==0)= 0;
tic
[Xhat XhatADU]   = f_simulateIm_emCCD(Ymean,pram);
toc
figure;imagesc([Xhat Y_preProc(:,:,randi(size(Yhat,3))) mean(Y_preProc,3)]);axis image;colorbar; 
title(sprintf('Bias ~ %d | k-gain ~ %d | Em-gain ~ %d\n Simulated(Left), Experimental(Middle), GT(Right)',...
               round(pram.bias),round(1/pram.ADCfactor),round(pram.EMgain)));
saveas(gcf,sprintf('beads-20200925_Bias_%d_k-gain_%d_Em-gain_%d.png',round(pram.bias),round(1/pram.ADCfactor),round(pram.EMgain)));













