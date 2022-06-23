function [data_sim, choice_rates, avg_period_consumption] = model_simulation(specs, indexer, log_wage_systematic, non_consumption_utility, emaxs)
% Executes Model Simulation of Agent Experiences
%fprintf('--------------------------- \n');
%fprintf('Function: Simulate Agent Experiences \n');

% Unpack model specification
seed_sim = specs.seed_sim;
num_agents = specs.num_agents;
pr_young = specs.pr_young;
pr_type_low = specs.pr_type_low;
num_choices = specs.num_choices;
var_shocks = specs.var_shocks;
num_periods = specs.num_periods;
free_consumption = specs.free_consumption;
mu = specs.mu;
delta = specs.delta;


% Draw random initial conditions
rng(seed_sim);
type_dummy = [1; 2];

% Draw age levels
    % simple implementation; more advanced - file-exchange function "randp"
    r = rand(num_agents, 1) <= pr_young;
    age_type = type_dummy(2 - r);
    % share_young = sum(r)/num_agents * 100;    % test
    % fprintf('Check Age_Type Young %d \n', share_young);
    
% Draw random type
    r = rand(num_agents, 1) <= pr_type_low;
    type = type_dummy(2 - r);
  

% Draw shocks
mean_sim = zeros(num_agents, num_choices);
shocks_cov_matrix = diag(var_shocks);
draws_sim = draw_disturbances(seed_sim, mean_sim, shocks_cov_matrix, num_agents, num_choices, num_periods);


% Generate simulated data matrix
    % empty data_sim matrix first period
    data_sim = NaN(num_agents, 21);

    % fill agentd id
    data_sim(:, 1) = ones; data_sim(:, 1) = cumsum(data_sim(:,1),1);
    % fill types
    data_sim(:, 3) = age_type; data_sim(:, 7) = type;

    % Get position of type-specific agents
    idx_type11 = (data_sim(:, 3) == 1) & (data_sim(:, 7) == 1);
    idx_type12 = (data_sim(:, 3) == 1) & (data_sim(:, 7) == 2);
    idx_type21 = (data_sim(:, 3) == 2) & (data_sim(:, 7) == 1);
    idx_type22 = (data_sim(:, 3) == 2) & (data_sim(:, 7) == 2);
    
    % replicate for size preallocation
    data_sim = repmat(data_sim, num_periods, 1);
    
    % First Period
    % replace lagged_choice with ones (relevant for first period indexer usage)
    data_sim(1:num_agents, 4) = ones;
    % Experience Terms are Zero
    data_sim(1:num_agents, 5:6) = zeros;
    
% Generate Choice-Rates Matrix
    % one page for each age - type combination
    choice_rates = zeros(num_periods, num_choices, 4);


% Loop over all periods
for period = 1:num_periods
    
    if period == 1   % initial states
        
        % fill period
        data_sim((1:num_agents)*period, 2) = period;
        
        % current period state space & index
        current_states = data_sim(data_sim(:, 2) == period, 2:7);
        
        idx_current_states = statespace2index(indexer, current_states);
        
    else
        % update current states
        r_pos1 = num_agents * (period - 1) + 1;
        r_pos2 = r_pos1 + num_agents - 1;
        
        data_sim(r_pos1:r_pos2, 2:7) = current_states;
        
        idx_current_states = statespace2index(indexer, current_states);
        
    end
    
    % get utility components of current period
    current_log_wage_systematic = log_wage_systematic(idx_current_states);
    current_non_consumption_utilities = non_consumption_utility(idx_current_states, :);
    
    % derive current wage
    current_wages = exp(current_log_wage_systematic + draws_sim(:, :, period));
        % adjust for free consumption
        current_wages(:, 1) = free_consumption;
    
    % Calculate total consumption utility values for all choices
    flow_utilities = ((current_wages .^ mu) / mu) .* current_non_consumption_utilities;
    
    % get continuation values for all choices
    continuation_values = emaxs(idx_current_states, 1:num_choices);
    
    % Derive Value Function
    value_functions = flow_utilities + delta * continuation_values;
    
    % Determine Choice as option with highest choice-specific value function
    [max_val_func, choice] = max(value_functions, [], 2);
        % maybe write directl to data_sim matrix
        
    % write simulated choices and results to data_sim matrix
    data_sim(data_sim(:, 2) == period, 8) = choice;         % period choice
    data_sim(data_sim(:, 2) == period, 9) = current_log_wage_systematic;
    data_sim(data_sim(:, 2) == period, 10:12) = current_wages;
    data_sim(data_sim(:, 2) == period, 13:15) = current_non_consumption_utilities;
    data_sim(data_sim(:, 2) == period, 16:18) = flow_utilities;
    data_sim(data_sim(:, 2) == period, 19:21) = continuation_values;
    
    % Save Choice Rates
    %choice_rates(period, :) = histc(choice(:), [1 2 3]);
    choice_rates(period, :, 1) = histc(choice(idx_type11 == 1), [1 2 3])/(sum(idx_type11));
    choice_rates(period, :, 2) = histc(choice(idx_type12 == 1), [1 2 3])/(sum(idx_type12));
    choice_rates(period, :, 3) = histc(choice(idx_type21 == 1), [1 2 3])/(sum(idx_type21));
    choice_rates(period, :, 4) = histc(choice(idx_type22 == 1), [1 2 3])/(sum(idx_type22));
    
    % Update current states according to choice
    current_states(:, 1) = current_states(:, 1) + 1;    % period + 1
    current_states(:, 3) = choice;                      % lagged choice
    % update exp:
    current_states(choice(:, 1) == 2, 4) = current_states(choice(:, 1) == 2, 4) + 1;
    current_states(choice(:, 1) == 3, 5) = current_states(choice(:, 1) == 3, 5) + 1;
      
end

% Derive average consumption in population by period
simulated_consumption = data_sim(:, 10:12); 
simulated_consumption_choice = NaN(size(simulated_consumption,1),1);
choice_idx = data_sim(:,8);

% note: free consumption excluded
for l = 2:num_choices
    simulated_consumption_choice(choice_idx(:, 1) == l, 1) = simulated_consumption(choice_idx(:, 1) == l, l);
end

simulated_consumption_choice = reshape(simulated_consumption_choice, num_agents, num_periods);

avg_period_consumption = nanmean(simulated_consumption_choice)';


end

