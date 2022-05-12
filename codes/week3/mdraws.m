% pseudo- and quasi-random draws for simulation (normal distribution)
% and nodes and weights for Sparse Grid Integration
% Hannes Ullrich, April 2014

function [v, quadweight] = mdraws(nishares,Ktheta,ndr)

%rng(0);
rng('default');
if nishares == 1
    % Pseudo-random draws
    v = randn(Ktheta,ndr);
    quadweight = (1/ndr)*ones(ndr,1);
elseif nishares == 2
    % Modified Latin Hypercube Sampling (Hess, Train, Polak, 2006)
    shift = rand(1,1)/ndr;
    if Ktheta==1
        p = (0:ndr-1)./ndr + shift;
        v = norminv(p,0,1);
    else
        v = zeros(Ktheta,ndr);
        for k=1:Ktheta
            % unidimensional draws
            draws = (0:ndr-1)./ndr + shift;
            % Shuffle unidimensional draws, append
            [~,rrid] = sort(rand(ndr,1));
            v(k,:) = norminv(draws(rrid'),0,1);
        end
    end
    quadweight = (1/(ndr*Ktheta))*ones(ndr*Ktheta,1);
elseif nishares == 3
    % Scrambled Halton draws
    p = net(...
        scramble(...
        haltonset(Ktheta,'Skip',1e3,'Leap',1e2),...
        'RR2'),...
        ndr)';
    v = norminv(p,0,1);
    quadweight = (1/(ndr*Ktheta))*ones(ndr*Ktheta,1);
elseif nishares == 4
    % Sparse Grid Integration (Heiss and Winschel, 2008)
    [v,quadweight]=nwspgr('KPN', Ktheta, ndr);
end
