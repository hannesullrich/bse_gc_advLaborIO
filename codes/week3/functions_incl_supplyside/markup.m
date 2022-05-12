% This function computes 
% equilibrium markups
% Written by Hannes Ullrich (2014)

function mark_up = markup(theta,delta,alpha,data)

owner=data.owner;

[share, sij,~]=...
    ShareCalculation(theta,delta,data);

dsdp = dsdpfn_s(sij,alpha,data);

mark_up = - share./sum((owner.*dsdp),2);