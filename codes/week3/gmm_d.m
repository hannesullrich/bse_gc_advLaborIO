% The function gmm is used to calculate 
% the GMM estimator
% Written by Mathias Reynaert (2013)
% Original Source: Aviv Nevo (2000)

function f = gmm_d(theta,BLPdata)

%% Contraction Mapping
d=delta(theta,BLPdata);
%% GMM
if max(isnan(d)) == 1
 f = 1e10;	  
else 
% Use relationship between linear 
% and non-linear parameters from step 4,
% resulting from the FOC's
    bet = BLPdata.invxzwzx*(BLPdata.xzwz*d);
    csi = d-BLPdata.Xexo*bet;
	f = csi'*BLPdata.Z*BLPdata.W*BLPdata.Z'*csi;
    % Estimated beta vector to be loaded in main file
    save bet bet;
end

