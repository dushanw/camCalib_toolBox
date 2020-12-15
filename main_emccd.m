% <2020-12-15 | work in progress>

load('./_Datasets/tfm_mouseBrain_20201119/mouseBrain_20201119_reg3_100um_wf.mat','Yhat');
name_stem = 'mouseBrain_20201119_reg3_100um_wf';
Yhat  = double(Yhat(250:270,100:120,:));

pram  = f_praminit_nuvu();
Xhat  = f_preProc_emCCD(Yhat,pram);

Xs    = mean(Xhat,3);
Xexp  = Xhat(:,:,randi(size(Xhat,3)));
      
tic
[Xsynth Xsynth_ADU]   = f_simulateIm_emCCD(Xs,pram);
toc
figure;imagesc([Xsynth Xexp Xs]);axis image;colorbar; 
title(sprintf('Bias ~ %d | k-gain ~ %d | Em-gain ~ %d\n Simulated(Left), Experimental(Middle), GT(Right)',...
               round(pram.bias),round(1/pram.ADCfactor),round(pram.EMgain)));

savepath = ['./_results/' datestr(now,'yyyy-mm-dd') '/' name_stem '/'];
mkdir(savepath)
save([savepath 'synth_exp_s.mat'],'Xsynth','Xexp','Xs')
