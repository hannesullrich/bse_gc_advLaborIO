function [llf] = rustllf(b,Data)
% This computes the likelihood function

d=Data.d;xt=Data.xt;
dvec1=Data.dvec1;belemax=Data.belemax;

if belemax
    % Solve using Emax method. 
    % Produces V01 (choice-specific value function)
    [~,V01,~] = bellman1(b,Data);
else
    % solve using alternative specific method
    % Produces V01 (choice-specific value function)
    [~,V01,~] = bellman2(b,Data);
end

prd1 = exp( V01(xt+1,2) ) ./ ...
    ( exp( V01(xt+1,1) ) + exp( V01(xt+1,2) ) );

save V01 V01;

llfi = log( d .* prd1 + ...
    (dvec1-d) .* (dvec1-prd1) );

llf=-mean(llfi);
