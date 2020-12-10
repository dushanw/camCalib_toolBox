
function [Xhat XhatADU] = f_simulateIm_emCCD(X0,pram)
  
  Xdark   = pram.dXdt_dark * pram.t_exp;             % [e-]    Dark noise
  Xhat    = poissrnd(X0 + Xdark);                    % [e-]    Poisson shot noise  

  if pram.useGPU ==1
    Xhat  = gpuArray(Xhat);
  end
  
  fprintf('%0.4d/%0.4d',0,pram.N_gainStages)
  for i=1:pram.N_gainStages 
    fprintf('\b\b\b\b\b\b\b\b\b%0.4d/%0.4d',i,pram.N_gainStages)
    Xhat  = Xhat + binornd(Xhat,pram.Brnuli_alpha);               % [e-]    Add binomial noise due to each step in the Em process
  end
  Xhat    = Xhat + normrnd(0,pram.sigma_rd); 

  XhatADU = Xhat * pram.ADCfactor + pram.bias;        % [ADU]   simulated image in ADU
  
end