clear

disp(['This program estimates Rust (1987) model of bus engine ' ...
      'replacement']);

%%% Simulate fake Rust data
% - mileage at t (x_t)
% - replacement decision at t (i_t), choice set: 0,1
% - mileage at t+1 (x_{t+1})

%%% -------------- PARAMETERS ----------------
Data.eul=0.57721;    % Euler constant
x=(0:10)';Data.x=x; % Allocate state variable
% Tolerance for V convergence. eps: machine precision
Data.tolbel = eps;
% E[max(...)] (1) or V01 (0) iteration
belemax = 0;
% True values for theta
% \theta_1 - marginal cost of engine maintenance
% \theta_2 - square term on maintenance cost
% \theta_3 - replacement cost
thetatrue = [ -0.13 0.004 -3.10 ]';
% Discount factor
beta = 0.95;
% Transition probability
lmd = 0.82;
% Size of state space
nx = length(x);Data.nx=nx;
% No. of observations
nd = 1000;
% Choice per state and observation
Data.vec0 = zeros(nx,1);Data.vec1 = ones(nx,1);
Data.dvec0 = zeros(nd,1);Data.dvec1 = ones(nd,1);

% Problem 1.
%%% -------------- SIMULATE RUST DATA ----------------

% Info to pass along to Bellman
SData.x=Data.x;SData.nx=Data.nx;SData.tolbel=Data.tolbel;
SData.vec0=Data.vec0;SData.vec1=Data.vec1;
SData.beta=beta;SData.eul=Data.eul;SData.lmd=lmd;

% Solving DP problem given parameters
if belemax
  [EV,V01,iter] = bellman1(thetatrue,SData); % iterate over Emax (ex ante value function / logsum)
else
  [EV,V01,iter] = bellman2(thetatrue,SData); % iterate over alternative specific
end

% Probability of replacement for each state
% With ad hoc parameters theta
% CCP (conditional choice probability)
prd1=exp(V01(:,2))./(exp(V01(:,1))+exp(V01(:,2)));

disp('True parameters:');
disp(thetatrue)
% Reporting results
if belemax
  disp('Contraction computed using E[max...] formulation');
else
  disp('Contraction computed using d-specific V-functions');
end
disp(['Bellman converged in ',num2str(iter,'%5d'),' iterations']);
disp('Results');
disp('State -- Value function (0,1) -- Replacement prob');
disp([x,V01,prd1])

% Extreme value type I error term, scale parameter normalized to 1, such that variance: (pi^2)/6
rng(1)
e = random('ev',0,1,[nd,2]);
% e = -1.*evrnd(0,1,nd,2);
% Inverse of CDF F(x) = exp(-exp(-x))
% e = -log(-log(rand(nd,2)));

% Mileage transition draws
xup = random('bino',ones(nd,1),lmd);

% Optimal replacement decisions and resulting mileage resets
xt=zeros(nd,1);xt1=zeros(nd,1);d=zeros(nd,1);
for i = 1:nd
    % Choice
    d(i,1) = ( (V01(xt(i)+1,2) + e(i,2)) > ...
              (V01(xt(i)+1,1) + e(i,1)) );
    % State transition
    xt1(i,1) = (1-d(i,1))*min(xt(i,1)+xup(i,1),10) + d(i,1)*xup(i,1);
    if i<nd
        xt(i+1,1) = xt1(i,1);
    end
end

% Problem 2.
%----------- ESTIMATION ---------------
% Load data, set parameters and starting values
Data.xt=xt;Data.xt1=xt1;Data.d=d;
Data.belemax = 1;
Data.beta = 0.95;
theta = [ -0.1 0.01 -4.0 ]';

tic

% Estimating \lambda - transition probabilities
disp('');
% Frequency of x_t = x_t+1 = 10
numbound = sum((xt==10 & xt1==10));
% Mileage up with d=0
numup_d0 = sum((d==0) & (xt1-xt==1));
% Mileage up with d=1
numup_d1 = sum((d==1) & (xt1==1));

% numbound=0; % If forgotten to account for boundary state
% Transition prob, net of boundary states
lmd = (numup_d0+numup_d1)/(nd-numbound);
Data.lmd=lmd;

disp(['Lambda = ',num2str(lmd,'%5.5f')]);

% Estimate parameters
anrustllf = @(theta)rustllf(theta,Data);
[rustbhat,fval,flag] = fminsearch(anrustllf,theta);
disp('Estimation results:');
disp(rustbhat)

disp(['min f-val: ',num2str(fval,'%5.6f')]);
if flag
  disp('Flag: Normal convergence');
else
  disp('Flag: Error');
end

% Report conditional replacement probabilities
load V01 V01;
prd1=exp(V01(:,2))./(exp(V01(:,1))+exp(V01(:,2)));
disp('State -- Value function (0,1) -- Replacement prob');
disp([x,V01,prd1])
toc

