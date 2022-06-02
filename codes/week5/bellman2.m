function [EV,V01,numiter] = bellman2(theta,Data)
% Computes bellman equation
% Iteration over conditional value function V01

% Unpack
eul=Data.eul;beta=Data.beta;lmd=Data.lmd;
vec0=Data.vec0;vec1=Data.vec1;nx=Data.nx;
tolbel=Data.tolbel;x=Data.x;

V01 = zeros(nx,2); % allocate choice-specific V (choice set: 0,1)
numiter=0;
difval=10;

while difval>tolbel
  % No replacement
  nv01(:,1)=ufun(vec0,theta,x) + ...
      beta * ( ...
      lmd * ( eul + log(exp([V01(2:nx,1);V01(nx,1)]) + exp([V01(2:nx,2);V01(nx,2)])) ) + ...
      (1-lmd) * ( eul + log(exp(V01(:,1))+exp(V01(:,2))) ) );

  % Replacement
  nv01(:,2)=ufun(vec1,theta,x) + ...
      beta * ( ...
      lmd * ( eul + log(vec1*(exp(V01(2,1))+exp(V01(2,2)))) ) + ...
      (1-lmd) * ( eul + log(vec1*(exp(V01(1,1))+exp(V01(1,2)))) ) );
  difval = max(max(abs((nv01-V01)./nv01)));
  V01=nv01;
  numiter=numiter+1;
end

% Emax
EV = eul + log( exp(nv01(:,1)) + exp(nv01(:,2)) );
