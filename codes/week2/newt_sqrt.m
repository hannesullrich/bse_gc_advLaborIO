% Newton's root-finding method
function xt1 = newt_sqrt(a,xt)

if a<0
    disp('Number a should be positive.');
    xt1=0;
    return
else
tol = 10e-12;
i = 0;
xdiff = 100;
while xdiff > tol
    fx = a-xt^2;
    dfdx = -2*xt;
    xt1 = xt - fx/dfdx;
    i = i + 1;
    fprintf('Value at iteration %d: %16.14f \n', i, xt1);
    xdiff = abs(xt1-xt);
    xt = xt1;
end
end