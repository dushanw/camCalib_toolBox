% This function pre-processes EmCCD image by removing the bias and deviding
% by the Em-gain and ADCfactor-gain (= 1/k-gain).
% i/p : (1) Experimental Images from an EmCCD.
%       (2) Emccd camera parameters
% o/p : Input image to the emRegister but with noise.
%
% Use this code to preprocess images before feeding to dabbaMu trained with
% simulated data

function Yhat_preProc = f_preProc_emCCD(Yhat,pram)

  Yhat_preProc = (Yhat - pram.bias)/(pram.EMgain*pram.ADCfactor);

end