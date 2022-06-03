function [llf] = rustllfhm(b,Data)
% This computes the Hotz-Miller pseudo likelihood function

d=Data.d;xt=Data.xt;beta=Data.beta;
dvec1=Data.dvec1;vec1=Data.vec1;vec0=Data.vec0;
phat=Data.phat;x=Data.x;eul=Data.eul;

% choice-specific flow utilities
u1 = ufun(vec1,b,x); % 11 x 1
u0 = ufun(vec0,b,x); % 11 x 1

% ex ante value function
vbar = ( eye(Data.nx) - beta * Data.tmat ) \ ...
		( (vec1-phat) .* (u0 + eul - log(vec1-phat)) + phat .* (u1 + eul - log(phat)) );

% predicted replacement probability
enum1 = exp( u1(xt+1) + beta * Data.T1( xt+1,:) * vbar );
prd1 = enum1 ./ (...
    exp( u0(xt+1) + beta * Data.T0( xt+1,:) * vbar) + enum1 );

% pseudo log-likelihood
llhm = log( d .* prd1 + ...
    (dvec1-d) .* (dvec1-prd1) );

llf=-mean(llhm);
