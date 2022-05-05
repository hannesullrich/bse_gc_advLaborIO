% The function ShareCalculation
% calculates the predicted market share vectors 
% for given parameters and data
% for the logit demand model with homogenous preferences.

function [share] = ...
    ShareCalculation_simple(delta,data)

%% Unpack
cdid=data.cdid;dummarket=data.dummarket;

%% Market Share
numer1 = exp(delta);
sumMS=(dummarket'*numer1);
denom1=1+sumMS(cdid,:);
share=(numer1./denom1);
