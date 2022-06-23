function [log_wage_systematic, non_consumption_utility] = util_components(specs, states)
% Derives auxilliary components which can be directly derived based on the
% state space

%fprintf('--------------------------- \n');
%fprintf('Function: Derive Utility Components \n');

% Unpack Model Specification
gamma0 = specs.gamma0;
gamma1 = specs. gamma1;
num_choices = specs.num_choices;
p_l = specs.p_l;
theta_l = specs.theta_l;
theta_f = specs.theta_f;

% Derive Utility Components               
    % Calculate systematic wages, i.e. wages net of shock, for all states:
        % Construct Wage Components
        gamma_0s = zeros(size(states, 1), 1);
        gamma_1s = zeros(size(states, 1), 1);
        for age_lvl = 1:2
            gamma_0s(states(:, 2) == age_lvl, 1) = gamma0(age_lvl);         %%% use pre-allocated sizes!!
            gamma_1s(states(:, 2) == age_lvl, 1) = gamma1(age_lvl);
        end 

        period_exp_sum = states(:, 4) * p_l + states(:, 5);
        
        % Calculate wage in the given state
        returns_to_exp = gamma_1s .* log(period_exp_sum + 1);
        log_wage_systematic = gamma_0s + returns_to_exp;
        
    % Calculate non-consumption utility
        non_consumption_utility = zeros(size(states, 1), num_choices);
        for type = 1:2
            non_consumption_utility(states(:, 6) == type, 2) = theta_l(type);
            non_consumption_utility(states(:, 6) == type, 3) = theta_f(type);
        end
        
        non_consumption_utility = exp(non_consumption_utility);
    

end

