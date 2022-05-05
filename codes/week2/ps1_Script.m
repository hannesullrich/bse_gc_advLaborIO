%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0. rc_demand.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Settings
% 2. Simulate Data
% 3. Data Structure, Instruments and Weighting Matrix
% 4. Linear Estimation

%% Question 1.a) 
% 1. Settings Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
       
% 1.1. TRUE PARAMETER VALUES

% Size/index of dataset
% number of markets
nmkt = 25;
% number of brands per market
nbrn = 10;
% number of observations
nobs=nmkt*nbrn;
% marketnumber for each obs
cdid = kron((1:nmkt)',ones(nbrn,1));
% dummies for each market
dummarket=dummyvar(cdid);

% True model parameter values
% mean tastes on constant, x, p
betatrue = [2 2 -2]';

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

% 2. Simulate Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Seed
rng(1)

% Unobserved characteristics: omeg and Ksi
omegksi=mvnrnd(mu,truecovomegksi); 
ksi=omegksi(:,1);
omeg=omegksi(:,2);
keyboard
% Constant and One Product Attribute, U(1,2)
A = 1+rand(nobs,nlin-2);
A = [ones(nobs,1) A];

% Cost Shifters, U(0,1)
z =  rand(nobs,ninst);

% Price with perfect competition
% a function of z, A and omeg(ksi) = mc
price = [z A]*zparamtrue + omeg;

%% Question 1.b) 

% X-Matrices for Estimation
Xexo=[A price]; % RHS X vector

% Make parts for market share calculation
deltatrue=Xexo*betatrue+ksi;

% Calculate the True/Observed Market shares
Data.cdid=cdid;Data.dummarket=dummarket;
share=ShareCalculation_simple(deltatrue,Data);

% 3. BLP Instruments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create sum of rival characteristics
% Sum of characteristics per market:
xcomp=dummarket'*A(:,2);
xcomp=xcomp(cdid,:);
xcomp=xcomp-A(:,2);


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

disp('----------------------------------');
disp('OLS, constant (2) - observable (2) - price (-2)')
disp([bols seols]);

for i=2:2

% Choose set of instruments
if i==1
    Z=[A xcomp];
elseif i==2
    Z=[A z];
end

%IV

%Step 1: 2SLS (homoscedastic errors), "weighting matrix" W=inv(Z'Z)
norm=mean(mean(Z'*Z),2);
W=inv((Z'*Z)/norm)/norm;

mid=Z*W*Z'; % projection matrix, first-stage: hat(Xexo) = mid*Xexo
btsls=(Xexo'*mid*Xexo)\(Xexo'*mid*y);
xi=y-Xexo*btsls;

sst=inv(Xexo'*mid*Xexo);
ser=(xi'*xi)./dgf;
setsls=sqrt(ser*diag(sst));
%Step 2: Optimal weighting matrix*/ g() = Z*ksi(theta*)
IVres = Z.*(xi*ones(1,size(Z,2)));
B_hat = IVres'*IVres;
    
mid2 = Z*(B_hat\Z');
btgmm = (Xexo'*mid2*Xexo)\(Xexo'*mid2*y);
xigmm=y-Xexo*btgmm;

sst2=inv(Xexo'*mid2*Xexo);
ser2=(xigmm'*xigmm)./dgf;
segmm=sqrt(ser2*diag(sst2));

%% Print results to screen
fprintf('Instrument set %d \n', i);
disp('----------------------------------');
disp('Linear IV - 2SLS')
disp([btsls setsls]);
disp('Linear IV - optimal GMM')
disp([btgmm segmm]);

end % End loop over instrument sets

%% Question 2. Price with imperfect competition
% Compute equilibrium
Data.A=A;Data.ksi=ksi;
Data.mc=price;Data.betatrue=betatrue;

fprintf('Compute equilibrium prices \n');
disp('----------------------------------');

options=optimset('Display','iter',...
    'TolFun',1e-6,'TolX',1e-6);

aneqprice = @(price)eqprice_simple(price,Data);
[eprice,fval,exitflag] = fsolve(aneqprice,price,options);

disp('Price distribution');
disp('----------------------------------');
disp('Min - Mean - Max')
disp([min(eprice) mean(eprice) max(eprice)]);
disp('Marginal cost distribution');
disp('----------------------------------');
disp('Min - Mean - Max')
disp([min(price) mean(price) max(price)]);

%% Question 3. Contraction mapping: Newton's method

disp('Compute square root using Newton`s method');
disp('----------------------------------');

a = 16;
x = 1;
sqrt_a = newt_sqrt(a,x);
fprintf('The square root of %6.2f is: %4.2f \n', a, sqrt_a);


