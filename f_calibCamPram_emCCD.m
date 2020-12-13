
function [pram Y_preProc] = f_calibCamPram_emCCD(Y,pram,figName)
  % ref1 : robbins2003noise

  Y           = double(Y);

  %% calibrate for bias using the last row that's empty
  Y_bias          = reshape(Y(end,:,:),1,[]);
  pram.bias       = mean(Y_bias);  
  % pram.ADCfactor  = sqrt(var(Y_bias)/((pram.EMgain^2)*(pram.ENF^2)*(pram.sigma_dark.^2)+pram.sigma_rd^2));  
  % pram.bias       = mean(Y_bias) - pram.X_dark*pram.EMgain*pram.ADCfactor;
  
  %% calculate the ADCfactor
  Y           = Y(1:end-1,:,:);
  f_var       = @(block_struct) var(block_struct.data(:));
  f_mean      = @(block_struct) mean(block_struct.data(:));
  
  blaocksize  = [1 1];
  var_Xc      = blockproc(Y,blaocksize,f_var);
  mu_Xc       = blockproc(Y,blaocksize,f_mean);
  
%  inds        = find(mu_Xc<pram.upperTh_mu & var_Xc< pram.upperTh_var & mu_Xc>pram.lowTh_mu);  
  inds        = find(mu_Xc>pram.lowTh_mu);  
  %inds        = 1:length(mu_Xc(:));
  
  x           = mu_Xc(inds);
%  x           = mu_Xc(inds)- pram.bias;  
  y           = var_Xc(inds);

  [xData, yData]    = prepareCurveData( x, y );
  ft                = fittype( 'poly1' );                         % Set up fittype and options.
  [fitresult, gof]  = fit( xData, yData, ft );                    % Fit model to data.

  % Plot fit with data.
  if ~(isempty(figName))
    figure( 'Name', figName );
%     subplot(2,2,1); imagesc(mean(Y,3));axis image;colorbar;
%     subplot(2,2,2); imagesc(mu_Xc)    ;axis image;colorbar;
%     subplot(2,2,3); imagesc(var_Xc)   ;axis image;colorbar;
%     subplot(2,2,4);
                    rnd_inds = randi(length(xData),[1 1000]);
                    h = plot( fitresult,xData(rnd_inds), yData(rnd_inds));    
                    legend( h, 'y vs. x', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
                    xlabel( 'x', 'Interpreter', 'none' );
                    ylabel( 'y', 'Interpreter', 'none' );
                    grid on
  end
  % parameters
  m               = fitresult.p1;                 % to estimated ADCfactor  
% b               = fitresult.p2;                 % do not use this value as it's too sensitive to the fit    
  pram.ADCfactor  = m/(pram.EMgain*pram.ENF^2);   % from Eq 10 in ref1
  
  %% simulate to shot noised image
  Y_preProc       = (Y - pram.bias)/(pram.EMgain*pram.ADCfactor);
end







