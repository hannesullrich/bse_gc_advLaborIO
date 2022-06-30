
%% Integrating over log normal wages using cc

% Assume you wish to integrate over wage distribution
% i.e. integrate to obtain cdf - integral of pdf
clear; 

% (a) Take a random draw from a lognormal distribution
mu_wage = 13;
sd_wage = 5;
wageobs = exp(mu_wage + randn*sd_wage);

% (b) Calculate the lognormal CDF via numerical integration            %
% (b.i) quadrature formula: clenshaw-curtis (not always suited)

[xr,wr]=ccquad(20)

% lower support of integral: With lognormal, zero is natural.
% => what would you take for the normal distribution*?
lowsupport=0;

testcdf=@(zd) ((zd-lowsupport)./2).*wr'*lognpdf( ((zd+lowsupport)./2) + (xr*(zd-lowsupport))./2,mu_wage,sd_wage);
disp('our DIY cdf function')
testcdf(wageobs)

% (b.ii) log normal cdf (inbuilt Matlab) 
disp('Matlab in-built cdf')
logncdf(wageobs,mu_wage,sd_wage)


%% When will our function be poor quality?
lowage=exp(mu_wage+sd_wage)
testcdf(lowage)
logncdf(lowage,mu_wage,sd_wage)

%% NB. works not only for parametric built-in integrals, 
% but more generally as alternative
% to numerical integration algorithm in matlab (eg using command
% "integral")

paramdistrib=@(pr) lognpdf(pr,mu_wage,sd_wage)
integral(paramdistrib,0,wageobs)

logncdf(wageobs,mu_wage,sd_wage)

%* example of sensible choice for normal: lowsupport=mu_wage-5.*sd_wage;
%  Why is this a sensible choice?

