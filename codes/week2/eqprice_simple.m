% This function computes 
% Bertrand-Nash equilibrium prices, 
% given a price starting vector and data
function root = eqprice_simple(price,data)

betatrue=data.betatrue;A=data.A;ksi=data.ksi;mc=data.mc;
pcoeff=data.betatrue(length(data.betatrue));

% Make parts for market share calculation
deltatrue=[A price]*betatrue+ksi;

share = ShareCalculation_simple(deltatrue,data);

dsdp = dsdpfn_simple(share,pcoeff);

root = mc - price - share./dsdp;