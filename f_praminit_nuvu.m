

function pram = f_praminit()
  % ref1 : https://www.nuvucameras.com/wp-content/uploads/2020/02/nuvucameras_hnu512.pdf
  % ref2 : https://www.nuvucameras.com/emccd-tutorial/
  
  pram.sigma_rd       = 3;                      % [e-]        Read noise      
  pram.dXdt_dark      = 0.005;                  % [e-/px/s]   Dark current
  pram.t_exp          = 100 * 1e-3;             % [s]         Nominal value
  pram.eMpxWellDepth  = 800e3;                  % [e-]        ??
  pram.ADCfactor      = 1;                      % [AU/e-]     ADU counts per e- in ADC conversion
  pram.bias           = 300;                    % [ADU]       Camera bias, 300 is a nominal value (note that its in ADU)
  
  pram.EMgain         = 10;                     % [AU]        EM gain, 50 is a nominal value
  pram.Brnuli_alpha   = 0.02;                   %             Probability of a multiplication event in an Em gain stage (=1-2% in Ref2)
  pram.N_gainStages   = round(log(pram.EMgain)/log(1+pram.Brnuli_alpha)); 
                                                %             Number of Em-gain stages
  
  pram.dataPath       = '/Volumes/GoogleDrive/My Drive/_Data/DEEP-TFM/2020-09-25_Cheng_8-4-3patternedBeads/';
  pram.datafName      = 'dmd_exp_tfm_beads_20200925_noCrop.mat';
  pram.dataMatName    = 'beads2_wf';

  pram.upperTh_var    = 1000;
  pram.upperTh_mu     = 1000;
  pram.lowTh_mu       = 305;  
  
  pram.useGPU         = parallel.gpu.GPUDevice.isAvailable;
end