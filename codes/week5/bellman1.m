function [EV,V01,numiter] = bellman1(theta,Data)
% Computes bellman equation
% Iteration over EXPECTED value function EV, Emax

% Unpack
eul=Data.eul;beta=Data.beta;lmd=Data.lmd;
vec0=Data.vec0;vec1=Data.vec1;nx=Data.nx;
tolbel=Data.tolbel;x=Data.x;

% NX - size of state space
% EV, V01 start as zero vectors
EV = zeros(nx,1);  % allocate Emax function (expected V)
V01 = zeros(nx,2); % allocate choice-specific V (choice set: 0,1)
numiter = 0;
difval = 10;

while difval>tolbel
  % If no replacement, starting from given state
  % current u + discount factor * ( trans prob (shift) * EV (shift) + trans prob (no shift) * EV (no shift) )
  vd0 = ufun(vec0,theta,x) + ...
      beta * ( ...
      lmd*[EV(2:nx);EV(nx)] + ...
      (1-lmd)*EV );
  % If replacement, starting from new state 0
  % current u + discount factor * ( trans prob (shift) * EV (shift) + trans prob (no shift) * EV (no shift) )
  vd1 = ufun(vec1,theta,x) + ...
      beta * ( ...
      lmd*EV(2) + ...
      (1-lmd)*EV(1) );
  % Expected maximum utility, given extreme value assumption
  nev = eul + log( exp(vd0) + exp(vd1) ); % Log-sum

  difval = max(abs((nev-EV)./nev));
  EV = nev;
  numiter = numiter + 1;
end

V01(:,1) = ufun(vec0,theta,x) + ...
      beta * ( lmd*[EV(2:nx);EV(nx)] + (1-lmd)*EV );
V01(:,2) = ufun(vec1,theta,x) + ...
      beta * ( lmd*vec1*EV(2) + (1-lmd)*vec1*EV(1) );