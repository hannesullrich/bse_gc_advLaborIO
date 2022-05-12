% This function computes 
% Bertrand-Nash equilibrium prices, 
% given a price starting vector and data
% Written by Hannes Ullrich (2014)

function root = eqprice(price,data)

betatrue=data.betatrue;rc_true=data.rc_true;
A=data.A;ksi=data.ksi;owner=data.owner;mc=data.mc;

% Make parts for market share calculation
deltatrue=[A price]*betatrue+ksi;

[share, sij,~]=...
    ShareCalculation(rc_true,deltatrue,data);

dsdp = dsdpfn(sij,data);

root = mc - price - share./sum((owner.*dsdp),2);