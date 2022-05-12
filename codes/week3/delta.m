function delta1 = delta(theta,data)

% delta
% Contraction Mapping to find the mean utilities
% Written by Mathias Reynaert (2013)
% Original Source: Aviv Nevo (2000)

k=100;
km=1e-14;
i = 0;
deltastart=zeros(data.nobs,1);

% Unpack
logobsshare=data.logobsshare;

while k > km 
      % Market Share
      [sh, ~, ~]=ShareCalculation(theta,deltastart,data);
      
      % Contraction Mapping
      delta1 = deltastart+logobsshare-log(sh);
      if max(isnan(delta1))==1
         disp('No Convergence - delta calculation failed: OVERFLOW')
         break
      end
      i = i + 1;
      if i>2500
         %disp('No Convergence - delta convergence failed')
         break
      end
      k=max(abs(delta1-deltastart));
      deltastart = delta1;
end