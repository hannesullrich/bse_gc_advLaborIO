% Compute market share derivative 
% matrix with respect to price
function dsdpjj = dsdpfn_simple(sij,pcoeff)

dsdpjj=pcoeff.*sij.*(1-sij);
