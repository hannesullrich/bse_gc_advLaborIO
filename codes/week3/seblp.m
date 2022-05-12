function se=seblp(parameters,Data)

% seblp
% Computes standard errors for all parameters
% Written by Mathias Reynaert (2013)

nlin=Data.nlin;

theta2=parameters(nlin+1:nlin+Data.nrc,1);
deltaopt=delta(theta2,Data);
derdel=jacob(theta2,deltaopt,Data);
derksi=[-Data.Xexo derdel]'*Data.Z;
%vv=inv(derksi*Data.W*derksi');
vv=derksi*Data.W*derksi';
xi=deltaopt-Data.Xexo*parameters(1:nlin,:);

covg = zeros(size(Data.Z,2));
for ii =1:length(Data.Z)
    covg = covg + Data.Z(ii,:)'*Data.Z(ii,:)*(xi(ii)^2);
end

%varcovar = vv*derksi*Data.W*covg*Data.W*derksi'*vv;
varcovar = vv\derksi*Data.W*covg*Data.W*derksi'/vv;
se=sqrt(diag(varcovar));
end 