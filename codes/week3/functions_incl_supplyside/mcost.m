% This function computes
% equilibrium marginal cost
% Written by Hannes Ullrich (2014)

function mc = mcost(theta,delta,alpha,data)

price = data.Xexo(:,size(data.Xexo,2));

mark_up = markup(theta,delta,alpha,data);

mc = price - mark_up;
