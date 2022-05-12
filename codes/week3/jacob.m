function f=jacob(theta,delta,data)

% jacob
% Jacobian of the implicit function that defines the mean utility
% This function is needed to compute the optimal instruments at a given
% value of theta
% 
% Written by Mathias Reynaert (2013)
% Original Source: Aviv Nevo (2000)
% Adapted by Hannes Ullrich (2014)

%% Unpack
nodes=data.nodes;
xv=data.xv;
nrc=data.nrc;
cdid=data.cdid;
qweight=data.qweight;

%% Market Shares
[~, sij, wsij]=ShareCalculation(theta,delta,data);

%% Jacobian
derTheta=zeros(size(xv,1),size(theta,1));
for j = 1:max(cdid)
wssij=wsij((cdid==j),:);
ssij=sij((cdid==j),:);
sqweight=qweight((cdid==j),:);
part1=wssij*ssij';
derShareDelt = (diag(sum(wssij,2)) - part1);
f1 = zeros(size(derShareDelt,1),nrc);
% computing (partial share)/(partial sigma)
for i = 1:nrc   
 	sxv=xv(cdid==j,((i-1)*nodes)+1:i*nodes);
    sumxv=sum(sxv.*ssij,1);
    sumxv=repmat(sumxv,size(sxv,1),1);
 	f1(:,i) = sum(sqweight.*(ssij.*(sxv-sumxv)),2);
 	clear sxv sumxv
end
derTheta((cdid==j),:)=-derShareDelt\f1;
end
f=derTheta;

end
