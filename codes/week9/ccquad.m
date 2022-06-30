function [xcc,wcc] = ccquad(n)
% [nodes, weights]=ccquad(number of nodepoints)
% Clenshaw-Curtis quadratures by DFTs
% n>1 
% Nodes: x_k = cos(k*pi/n), k=0,...,n
% wcc = weights 
% Compute \int_{-1}^{1} f(x)dx = f*wcc 
%   for f = [f(x_0) ... f(x_n]
 
K=[0:n]';xcc=cos(K*pi/n);
N=[1:2:n-1]'; l=length(N); m=n-l; 
v0=[2./N./(N-2); 1/N(end); zeros(m,1)];
v2=-v0(1:end-1)-v0(end:-1:2); 

%Clenshaw-Curtis nodes: k=0,1,...,n; weights: wcc, wcc_n=wcc_0
g0=-ones(n,1); g0(1+l)=g0(1+l)+n; g0(1+m)=g0(1+m)+n;
g=g0/(n^2-1+mod(n,2)); wcc=real(ifft(v2+g));
wcc=[wcc;wcc(1)];
