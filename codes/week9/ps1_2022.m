
%% Problem Set Job Search - Week 1 %%

%% Section (1) Value functions and strategies
% See slides.

%% Section (2) Simulation


%% (2.1) Numerically solve for reservation wage

% Set up
clear;clc;
N=1000; 

% model primitives
% express in terms of months
lam0=1;                     % one job offer per month
delta1=1/(30*12);           % job loss once every 30 years 
delta2=1/(10*12);           % job loss once every 10 years 

% contrast with 0.01 (!)
r=0.005;

r=0.005;    bet=1/(1+r);    % discount rate / factor
b=100;                      % monthly benefits
wmu=7;
wsigma=1;

% interesting object: integral
%
% - in this case, can use conditional expectation
%   (take care to specify the condition!)
%
% But don't be afraid to integrate!
% - easiest solution: use in-built functions
% but: these sometimes restrictive (e.g.  types of arrays)
% plus: good to know what numerical integration is doing
%
% First, what is upper support?
%
% choose support to cover nearly whole distribution...
w_upper = logninv(0.99999999,wmu,wsigma);

integrand =@(wx,wrx) ((wx-wrx).*lognpdf(wx,wmu,wsigma));

% alternative to logn(.) - using normpdf and log input value
integrand2=@(wx,wrx) ((wx-wrx).*normpdf(log(wx),wmu,wsigma)./wx);

% Set up the reservation wage equations - left-hand and right-hand sides
LHS=@(wrx,deltar) (1-bet.*(1-deltar)).*(wrx-b);
RHS=@(wrx) lam0.*bet.*integral(@(wx) integrand(wx,wrx),wrx,w_upper);
qdist=@(wrx,deltar) (LHS(wrx,deltar)-RHS(wrx))^2;

[resw_d1,~]=fminsearch(@(wrx) qdist(wrx,delta1),1);
disp('predicted reservation wage with job loss every 30 years'); 
sprintf('%f',resw_d1)

[resw_d2,~]=fminsearch(@(wrx) qdist(wrx,delta2),1);
disp('predicted reservation wage with job loss every 10 years'); 
sprintf('%f',resw_d2)

%% (2.2) Present an alternative, simple, way of approximating the integral

% see slides

%% (2.3) How many individuals are unemployed?

F = @(wr) logncdf(wr,wmu,wsigma);
Fbar = @(wr) 1-F(wr);
% u=delta / (delta + lambda* Fbar(w^R))

urate = delta1 / (delta1 + lam0* Fbar(resw_d1));
disp('number of unemployed individuals'); disp(round(urate*N))

% How would you determine individuals to be unemployed in a simulation?

%% (2.4) Distribution of duration in employment (I/II)
%
%  " Simulate the duration in employment of a cohort of workers who 
%    become employed at the same time. Show the histogram of the durations. 
%    Show the histogram.)"
% 
% A completed employment spell may end only due to cause:
%   job loss (delta) (in this model, there is no moving to another job (see next week)

% The duration distribution of waiting times governed by Poisson rates
% is given by the exponential distribution. 
% Hazard rate is job-out-flow rate delta 

% (a) Easy with predefined distributions in statistics package
%
% generate durations using exp random number generator
% 
duremp1a = exprnd(1./delta1,[N,1]);
duremp2a = exprnd(1./delta2,[N,1]); 

% NB. if you were simulating, you could now censor the durations of individuals
% previously determined to be unemployed

histogram(duremp1a)

% contrast mean durations depending on deltas 
mean_duremp1a = mean(duremp1a); disp(mean_duremp1a)
mean_duremp2a = mean(duremp2a); disp(mean_duremp2a)

%% Alternative: Distribution of duration in employment (II/II)
%
%  More general route: use inverse probability sampling
%
% CDF: 
%  Pr(X<tu) = 1-(1-delta)^tu
%       CDF = 1-(1-delta)^tu
%     1-CDF = (1-delta)^tu
% log(1-CDF)= tu*log(1-delta)
%        tu = [log(1-rand(N,1)]./[log(1-delta)];
%
% function to generate unemployment durations as f of delta
makedur=@(deltar) log(1-rand(N,1))./[log(1-deltar)];

% generate durations with diff deltas
duremp1b=makedur(delta1);
duremp2b=makedur(delta2);

% contrast mean durations depending on delta
mean_duremp1b=mean(duremp1b); disp(mean_duremp1b)
mean_duremp2b=mean(duremp2b); disp(mean_duremp2b)

%% (2.5) Distribution of accepted wages

% "Using your knowledge of the distribution, 
% simulate the wages employed workers receive. 
% Show the histogram. Calculate the mean wage of employed workers." 
% 
% Use inverse probability sampling (uniform random var & inverse CDF)
% 
% to sample from F*:
% 1. create uniform random variable
% 2. create inverse CDF 
%    <==> solve for w in p=[F(w)-F(wr)]/[1-F(wr)]
%     ==> w=Finv[(1+F(wr))*p+F(wr)]
% 3. We know F and Finv because Normal is a known distribution!!

% 1. pick points on CDF
p=rand(N,1);
% 2. CDF, CDF-inverse, and 1-CDF of log normal distribution
% using normcdf and norminv (if logncdf and logninv are not available)
%
% recall: Fbar = 1-F
Finv=@(prob) logninv(prob,wmu,wsigma);

% 3. invert F* to get w
w_d1= Finv(Fbar(resw_d1).*p    +F(resw_d1)) ; 
w_d2= Finv(Fbar(resw_d2).*p    +F(resw_d2)) ; 

 figure;
 hist([log(w_d1) log(w_d2)]);

 ksdensity(log(w_d1))
 hold on
 ksdensity(log(w_d2))
 legend('low job-loss','high job-loss');
 title('Accepted wage by delta');
 xlabel('Wage');ylabel('Frequency');
 hold off
