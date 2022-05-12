% The function gmm is used to calculate 
% the GMM estimator including supply side moments
% Written by Mathias Reynaert (2013)
% Original Source: Aviv Nevo (2000)
% Adapted by Hannes Ullrich (2014)

function f = gmm_s(theta,BLPdata)

%% Contraction Mapping
d=delta(theta,BLPdata);

%% GMM
if max(isnan(d)) == 1
 f = 1e10;	  
else 
    % Demand
    bet = BLPdata.invxzwzx*(BLPdata.xzwz*d);
    csi = d-BLPdata.Xexo*bet;
    % Supply-side markup
    mc=mcost(theta,d,bet(length(bet)),BLPdata);
    gam = BLPdata.invwwzwzww*(BLPdata.wwzwz*mc);
    omeg = mc-BLPdata.Az*gam;
    % Stack moment conditions
	f = ones(1,2)*...
        [csi'*BLPdata.Z*BLPdata.W*BLPdata.Z'*csi;...
        omeg'*BLPdata.Z*BLPdata.W*BLPdata.Z'*omeg];
    % Estimated beta and gamma vectors 
    % to be loaded in main file
    save bet bet;save gam gam;
end

