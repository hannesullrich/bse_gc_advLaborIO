function fval = msm_obj(gamma0_estim, specs, states, indexer, draws_emax, moments_obs)
% Function computing the gmm-objective
%   f is gmm-objective: -> result of function to be minimized

% Steps:
%   - given starting values for gamma0
%   - solve model for current gamma0 values
%   - simulate population and compare simulated moments to observed moments
%   - minimize objective

% unpack
num_periods = specs.num_periods;

% update gamma0 in model-specs struct
specs.gamma0 = gamma0_estim;

% derive auxilliary components
[log_wage_systematic, non_consumption_utility] = util_components(specs, states);  

% backwards induction
emaxs = backwards_induction_3d_vect(specs, states, indexer, log_wage_systematic, non_consumption_utility, draws_emax);

% generate simulated data-set
[~, ~, moments_sim] = model_simulation(specs, indexer, log_wage_systematic, non_consumption_utility, emaxs);

% weighting matrix
weighting_matrix = eye(num_periods);

% Construct Criterion Value
stats_dif = moments_obs - moments_sim;

fval = stats_dif' * weighting_matrix * stats_dif;


end

