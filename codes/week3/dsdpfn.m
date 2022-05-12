% Compute market share derivative 
% matrix with respect to price
% Written by Hannes Ullrich (2014)

function dsdp = dsdpfn(sij,data)

nbrn=data.nbrn;
nmkt=data.nmkt;
qweight = data.qweight;
pcoeff = data.betatrue(length(data.betatrue));

dsdp = zeros(nbrn*nmkt,nbrn);
dsdpjj=sum(qweight.*(pcoeff.*sij.*(1-sij)),2);
dsdphelp=zeros(nbrn,nbrn);
for market=1:nmkt
    xind = (market-1)*nbrn+1:market*nbrn;
    sik=sij(xind,:);
    for k=1:nbrn
        dsdphelp(:,k) = ...
            -1.*sum(qweight(xind,:).*...
            (pcoeff.*sij(xind,:).*...
            repmat(sik(k,:),nbrn,1)),2);
    end
    dsdphelp(1:nbrn+1:nbrn^2) = ...
        dsdpjj((market-1)*nbrn+1:market*nbrn);
    dsdp(xind,:) = dsdphelp;
end
