%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0. rc_demand.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Settings
% 2. Simulate Data
% 3. Data Structure, Instruments and Weighting Matrix
% 4. Linear Estimation
% 5. NFP

% Hannes Ullrich, June 2014
% Based on code by Mathias Reynaert (2013)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Settings Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
       
% 1.1. TRUE PARAMETER VALUES

% Size/index of dataset
% number of markets
nmkt = 250;
% number of brands per market
nbrn = 10;
% number of observations
nobs=nmkt*nbrn;
% marketnumber for each obs
cdid = kron((1:nmkt)',ones(nbrn,1));
% dummies for each market
dummarket=dummyvar(cdid);
keyboard
% Single-product firm ownership matrix
owner=repmat(diag(ones(nbrn,1)),nmkt,1);
% Say, firms 1 & 2 merge:
% Change ownership structure so that firm 1 produces products j=1,2
%for i=1:nmkt
%    owner((i-1)*nbrn+1:(i-1)*nbrn+2,1:2)=[1 1;1 1];
%end

% True model parameter values
% mean tastes on constant, x, p
betatrue = [2 2 -2]';
% random coefficient standard deviation
rc_true = 1;
% parameters of the model
thetatrue = [betatrue;rc_true];

% Number of parameters
% linear parameters
nlin=length(betatrue);
% instruments
ninst = 3;

% Price Equation Parameters
zparamtrue=[0+ones(ninst,1);0.7*ones(nlin-1,1)];

% Degree of endogeneity
% covariance in share and price eq. errors
truecovomegksi=[1 0.7; 0.7 1];
mu=zeros(nobs,2);

% Individual unobserved heterogeneity
% Integration of market shares using 
% pseudo Monte Carlo integration (1)
% MLHS (2)
% Scrambled Halton (3)
% Quadrature Rule (4)
drawsintegration=4;
% MC: Draws, Quadrature: Precision (KPN, Reynaert: 7)
ndraws = 7;

% Draw v or choose nodes/weights
[qv, qweight] = mdraws(drawsintegration,1,ndraws);

nodes=length(qweight);

% make row vector and duplicate nobs times
qv=ones(nobs,1)*qv';
qweight=ones(nobs,1)*qweight';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Simulate Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Seed
rng(1)

% Unobserved characteristics: omeg and Ksi
omegksi=mvnrnd(mu,truecovomegksi); 
ksi=omegksi(:,1);
omeg=omegksi(:,2);

% Constant and One Product Attribute, U(1,2)
A = 1+rand(nobs,nlin-2);
A = [ones(nobs,1) A];

% Cost Shifters, U(0,1)
z =  rand(nobs,ninst);

% X-Matrices for Estimation - part I
Xrandom=A(:,2); % Random coefficient X vector
Data.nrc=1; % one nonlinear parameter
xv=(Xrandom*ones(1,nodes)).*qv;

% Price with perfect competition
% a function of z, A and omeg(ksi) = mc
price = [z A]*zparamtrue + omeg;

% Price with imperfect competition
% Compute equilibrium
PData.nmkt=nmkt;PData.nbrn=nbrn;
PData.cdid=cdid;PData.dummarket=dummarket;
PData.nodes=nodes;PData.qweight=qweight;PData.xv=xv;
PData.A=A;PData.ksi=ksi;
PData.betatrue=betatrue;PData.rc_true=rc_true;
PData.owner=owner;PData.mc=price;

options=optimset('Display','iter',...
    'TolFun',1e-6,'TolX',1e-6);
aneqprice = @(price)eqprice(price,PData);
[eprice,fval,exitflag] = ...
    fsolve(aneqprice,price,options);
keyboard

% X-Matrices for Estimation - part II
Xexo=[A eprice]; % RHS X vector

% Make parts for market share calculation
deltatrue=Xexo*betatrue+ksi;

% Calculate the True/Observed Market shares
[share,~,~] = ShareCalculation(rc_true,deltatrue,PData);
logobsshare=log(share);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Data Structure, Instruments,
%% and Weighting Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%
% Market share integration for estimation.
% pseudo Monte Carlo integration (1)
% MLHS (2)
% Scrambled Halton (3)
% Quadrature Rule (4)
drawsintegration=4;
% MC: Draws, Quadrature: Precision (KPN, Reynaert: 7)
ndraws = 7;

[qv, qweight] = mdraws(drawsintegration,1,ndraws);

nodes=length(qweight);

% make row vector and duplicate nobs times
qv=ones(nobs,1)*qv';
qweight=ones(nobs,1)*qweight';

% Compute individual specific contribution x*mu
xv=(Xrandom*ones(1,nodes)).*qv;

%%%%%%%%%%%%%%%%%%%%%

Data.nmkt=nmkt;Data.nbrn=nbrn;Data.cdid=cdid;
Data.dummarket=dummarket;Data.owner=owner;
Data.nlin=nlin;
Data.nodes=nodes;Data.qweight=qweight;
Data.logobsshare=logobsshare;
Data.share=share;Data.xv=xv;
Data.qv=qv;Data.nobs=nobs;

% Create sum of rival characteristics
% Sum of characteristics per market:
xcomp=dummarket'*A(:,2);
xcomp=xcomp(cdid,:);
xcomp=xcomp-A(:,2);
keyboard

for i=1:2

% Choose set of instruments
if i==1
    Z=[A A(:,2).^2 xcomp];
elseif i==2
    Z=[A A(:,2).^2 z xcomp];
end
% 2SLS Weighting Matrix
norm=mean(mean(Z'*Z),2);
W=inv((Z'*Z)/norm)/norm;

% Some Data to speed up computations
% Demand
xzwz=Xexo'*Z*W*Z';
Data.xzwz=xzwz;
xzwzx=xzwz*Xexo;
locnorm=mean(mean(xzwzx),2);
Data.invxzwzx=inv(xzwzx/locnorm)/locnorm;

Data.Z = Z;
Data.W = W;
Data.Xrandom=Xrandom;
Data.Xexo = Xexo;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Linear Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OLS
ou=1-sum(reshape(share,nbrn,nmkt),1)';
y=log(share)-log(ou(cdid,:));
bols=(Xexo'*Xexo)\(Xexo'*y);
est=y-Xexo*bols;
dgf=(size(Xexo,1)-size(Xexo,2));
ser=(est'*est)./dgf;
sst=inv(Xexo'*Xexo);
seols=sqrt(ser*diag(sst));
%2SLS
mid=Z*W*Z';
btsls=(Xexo'*mid*Xexo)\(Xexo'*mid*y);
xi=y-Xexo*btsls;
sst=inv(Xexo'*mid*Xexo);
ser=(xi'*xi)./dgf;
setsls=sqrt(ser*diag(sst));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. NFP algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Pass Data into gmm using anonymous functions
theta20=abs(randn(1,1));
angmm = @(theta20)gmm_d(theta20,Data);

options = ...
    optimset( 'Display','iter',...
              'GradObj','off','TolCon',1E-6,...
              'TolFun',1E-6,'TolX',1E-6,...
              'Hessian', 'off','DerivativeCheck','off');    

t1 = cputime;
[theta, fval, exitflag, output, lambda] = ...
fminunc(angmm, theta20, options);

load bet bet;
th12gmm=[bet; theta];
se12gmm=seblp(th12gmm,Data);
cputimegmm=cputime-t1;

fprintf('Instrument set %d \n', i);
disp('----------------------------------');
disp('OLS, constant (2) - observable (2) - price (-2)')
disp([bols seols]);
disp('Linear IV')
disp([btsls setsls]);
disp('BLP, constant (2) - observable (2) - price (-2) - sigma (1)')
disp([th12gmm se12gmm]);

end % End loop over instrument sets
