function u = ufun(d,theta,x)
% This function computes utility function given arguments

u = d*theta(3) + ...
    (1-d) .* ( theta(1)*x + theta(2)*(x.*x) );
