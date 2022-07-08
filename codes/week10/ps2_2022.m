clear; clc;

%% Simulation
clear;clc;
N=100000;

% (0) Parameters
delta=0.1;      paramsim(1)=delta;
lam0=2;         paramsim(2)=lam0;
lam1=1;         paramsim(3)=lam1;
mu=10;          paramsim(4)=mu;
sig=3;          paramsim(5)=sig;
% alternative to using parametric wage-distribution: endogenize following
% B-M structure

% discount rate not estimated
r=0.005; 
beta=1/(1+r);

%some notation
k0=lam0/delta;
k1=lam1/delta;

save("paramsim",'paramsim')
 
%% (2.1) Simulate labour market status:

% theory
er = lam0/(delta+lam0);
ur=1-er;
disp('steady state unemployment rate'); disp(ur);

% simulation
emp=(rand(N,1)<er);
E=sum(emp);
U=N-E;
disp('observed employment rate in simulated data'); disp(E/N);
disp('observed unemployment rate  in simulated data'); disp(U/N);

%% (2.2) Simulate wages for employed workers:
% Note we need to use the population wage distribution S(.), 
% not the offer / sampling wage distribution F(.)

% useful functions
f=@(wr) normpdf(wr,mu,sig);
F=@(wr) normcdf(wr,mu,sig);
Fbar=@(wr) 1-F(wr);
Finv=@(xr) norminv(xr,mu,sig);
S=@(wr)    F(wr)./(1+k1*Fbar(wr));
Sinv=@(xr) Finv((xr*(1+k1)./(1+xr*k1)));

% generate wages for employed persons
randw=rand(N,1);
w=NaN(N,1);
w(emp)=Sinv(randw(emp));
disp(mean(w(emp)))

% How could we test whether we have the correct distribution?

%% (2.3) Job tenure

% note that the job tenure distribution can be given as a distribution 
% conditional and unconditional on wages.
%
% Importantly, the two distributions (wages, tenure) are not independent.
%
% => We have a *distribution of j2j finding rates* 
%   Workers in low-wage jobs are more likely to find a better job faster 
%   => thus have shorter completed job spells.
%
% One way of generating job tenure distribution:

% (1) generate wages according to population distribution S(.)
%
% (2) generate tenure conditional on these wages akin to (unconditional) 
% employment durations from last week

%% strategy A - simulate combined probability 
quitrate=@(wr) delta+lam1.*Fbar(wr);
dur1=NaN(N,1);
dur1(emp)=exprnd((1./quitrate(w(emp))),E,1);

%% strategy B
% part I/II: (potentially latent) duration until job-to-job transition
j2jdur=NaN(N,1);
j2jrate=@(wr) lam1.*Fbar(wr);
hist(j2jrate(w(emp)))
disp(mean(j2jrate(w(emp))))
j2jdur(emp) = exprnd((1./j2jrate(w(emp))),E,1);
sum(isnan(j2jdur(emp)))
disp(nanmean(j2jdur(emp)))

% part II/II: (potentially latent) duration until job-to-unemployment transition
j2udur=NaN(N,1);
j2urate=delta;
j2udur(emp) = exprnd(1./j2urate,E,1); 
sum(isnan(j2udur(emp)))
disp(mean(j2udur(emp)))

% realized duration is minimum of these two competing risks
% (i/ii) contribution of job-to-job moves
j2j=false(N,1);
j2j(emp)=(j2jdur(emp)<j2udur(emp));
disp(sum(j2j(emp)));
% (ii/ii) contribution of job-to-unemp moves
j2u=false(N,1);
j2u(emp)=(j2jdur(emp)>j2udur(emp)); %breaking ties should be very rare
disp('percent of job spells ending in job-to-job transition')
sum(j2j(emp)/E)
disp('percent of job spells ending in job-to-unemp transition')
sum(j2u(emp)/E)

dur2=NaN(N,1);
dur2(j2j)=j2jdur(j2j);
dur2(j2u)=j2udur(j2u);

%% Strategies should be equivalent
disp(nanmean(dur1)-nanmean(dur2))

disp('J2J: mean duration of job spells ending in job-to-job transition')
disp(nanmean(dur2(j2j)));
disp(nanmean(dur1(j2j)));

disp('J2J: mean wage of job spells ending in job-to-job transition')
disp(nanmean(w(j2j)));

disp('J2U: mean duration of job spells ending in job-to-unemployment transition')
disp(nanmean(dur1(j2u)));
disp(nanmean(dur2(j2u)));

disp('J2U: mean wage of job spells ending in job-to-unemployment transition')
disp(nanmean(w(j2u)));

%% for completeness of dataset (and for likelihood): duration in unemp
udur=NaN(N,1);
udur(~emp) = exprnd(1./lam0,U,1); 
sum(isnan(udur(~emp)))
disp(mean(udur(~emp)))
dur(~emp)=udur(~emp);

% save the simulated data
data.emp=emp;
data.dur=dur2;
data.w=w;
data.j2j=j2j;
data.j2u=j2u;
save ("simdata.mat",'data')

%% (3) Estimation

% When doing a Monte Carlo (testing whether estimator recovers parameters
% with which simulated data has been generated), remember to clear
% simulated parameters.

clear; clc;
load simdata

%% (3.1) likelihood contributions - see function translik below

%% (3.2) Estimation of parameters

% (3.1) ML estimation

% need to set starting values. things can go wrong here...
x0=[1 1 1 mean(data.w(data.emp)) std(data.w(data.emp))]; 

options  =  optimset('TolFun', 0.00001, 'TolX', 0.00001, 'diagnostic', 'on', 'MaxFunEvals',10000, 'MaxIter', 10000);
paramhat= fminsearch(@(paramr) translik(data,paramr), x0, options);

disp('So how did the estimator perform?')

disp('Estimated parameters: delta / lam0 / lam1 / wmu / wsig')
disp(abs(paramhat))

disp('Real/simulation parameters: delta / lam0 / lam1 / wmu / wsig')
load paramsim
disp(paramsim)

% note that we can easily deal with censoring (MAR).... how?
function lik=translik(data,param)
disp(param)
delta=abs(param(1));
lam0=abs(param(2));
lam1=abs(param(3));
wmu=param(4);
wsig=param(5);

% just for simplification
k0=lam0/delta;
k1=lam1/delta;

f=@(wr) normpdf(wr,wmu,wsig);
F=@(wr) normcdf(wr,wmu,wsig);
Fbar=@(wr) 1-F(wr);
s=@(wr) (f(wr).*(1+k1))./((1+k1.*Fbar(wr)).^2);

% (3.1.a) likelihood contribution of being unemployed
%  function for likelihood contribution of unemployed spell: ignoring duration in unemployment:
likuf=@(tr)             (1./(1+k0));

% function for likelihood contribution of a job-to-unemployment spell
likj2uf=@(t1r,wr)    (k0/(1+k0)).*s(wr)'.*exp(-(delta+lam1.*Fbar(wr)').*t1r').*delta;

% function for likelihood contribution of a job-to-unemployment spell
likj2jf=@(t1r,wr)    (k0/(1+k0)).*s(wr)'.*exp(-(delta+lam1.*Fbar(wr)').*t1r').*lam1.*Fbar(wr)';

liku=zeros(size(data.emp,1),1);
likj2u=zeros(size(data.emp,1),1);
likj2j=zeros(size(data.emp,1),1);

liku(~data.emp)             =   likuf(data.dur(~data.emp));
likj2u(data.emp & data.j2u)   =   likj2uf(data.dur(data.emp&data.j2u),data.w(data.emp&data.j2u));
likj2j(data.emp & (~data.j2u))=   likj2jf(data.dur(data.emp&(~data.j2u)),data.w(data.emp&(~data.j2u)));

lik=sum(abs(log(liku+likj2u+likj2j)));
end
