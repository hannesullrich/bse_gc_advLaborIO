% The function ShareCalculation
% calculates the predicted market share vectors 
% for given parameters and data.
% The code accommodates Monte Carlo Integration and 
% Sparse Grid Integration (with weights) 
% Written by Hannes Ullrich (2014), based on Mathias Reynaert (2013)

function [sh,sij,wsij] = ...
    ShareCalculation(theta,delta,data)

%% Unpack
cdid=data.cdid;dummarket=data.dummarket;
xv=data.xv;qweight=data.qweight;
nodes=data.nodes;

%% Market Share

% Individual-specific term
mu = xv .* theta;
% Mean utility plus individual-specific term
mudel=kron(ones(1,nodes),delta) + mu;

% Compute product-level shares
numer1 = exp(mudel);
sumMS=(dummarket'*numer1);
denom1=1+sumMS(cdid,:);
sij=(numer1./denom1);
wsij=qweight.*sij;
sh=sum(qweight.*sij,2);

