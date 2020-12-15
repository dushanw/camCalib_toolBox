

function pram = f_praminit_nuvu()
  % ref1 : https://www.nuvucameras.com/wp-content/uploads/2020/02/nuvucameras_hnu512.pdf
  % ref2 : https://www.nuvucameras.com/emccd-tutorial/
  
  pram.Digitization   = 16;                     % [bits]      Number of bits per pixel
  pram.eMpxWellDepth  = 800e3;                  % [e-]        ??  
  pram.ADCfactor      = 1/16.6;                 % [AU/e-]     ADU counts per e- in ADC conversion (calibrated by Cheng)                             
  pram.bias           = 300;                    % [ADU]       Camera bias, 300 is a close approximation

  pram.sigma_rd       = 3;                      % [e-]        Read noise      
  pram.dXdt_dark      = 0.005;                  % [e-/px/s]   Dark current
  pram.t_exp          = 100 * 1e-3;             % [s]         Nominal value
  pram.X_dark         = pram.dXdt_dark * pram.t_exp;
                                                % [e-]        Dark signal mean
  pram.sigma_dark     = sqrt(pram.X_dark);      % [e-]        Assuming that dark signal Poisson
  
    
  pram.EMgain         = 500;                    % [AU]        EM gain, 50 is a nominal value
  pram.Brnuli_alpha   = 0.01;                   %             Probability of a multiplication event in an Em gain stage (=1-2% in Ref2)
  pram.N_gainStages   = round(log(pram.EMgain)/log(1+pram.Brnuli_alpha)); 
                                                %             Number of Em-gain stages
  pram.ENF            = sqrt( (1/pram.EMgain)*(2*pram.EMgain+pram.Brnuli_alpha-1)/(pram.Brnuli_alpha+1) );
                                                
  pram.dataPath       = '/Volumes/GoogleDrive/My Drive/_Data/DEEP-TFM/2020-09-25_Cheng_8-4-3patternedBeads/';
  pram.datafName      = 'dmd_exp_tfm_beads_20200925_noCrop.mat';
  pram.dataMatName    = 'beads2_wf';

  pram.upperTh_var    = 1000;
  pram.upperTh_mu     = 1000;
  pram.lowTh_mu       = 305;  
  
  pram.useGPU         = parallel.gpu.GPUDevice.isAvailable;
end