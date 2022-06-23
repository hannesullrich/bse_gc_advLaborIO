function [emaxs] = backwards_induction_2d_vect(specs, states, indexer, log_wage_systematic, non_consumption_utility, draws_emax)
% Function: execute backwards induction

%fprintf('--------------------------- \n');
%fprintf('Function: Execute Backwards Induction \n');

% Unpack model specification
num_choices = specs.num_choices;
invalid_float = specs.invalid_float;
num_periods = specs.num_periods;
mu = specs.mu;
delta = specs.delta;
free_consumption = specs.free_consumption;

% Pre-allocate matrix sizes
emaxs = zeros(size(states, 1), num_choices + 1);
    emaxs(:, num_choices + 1) = invalid_float;
        

% Backwards loop over all periods
for period = num_periods:-1:1
    %tic
    
    % Extract period information
    % States
    states_period = states(states(:, 1) == period, :);
    
    % Draws Period
    draws = draws_emax(:, :, period);
    
    % Continuation Values
    % calculation not performed for last period since continuation values are
    % known to be zero
    if period == num_periods      
       % no action required
        
    else     
  %%%%%%%%%%%%%%%%%%%%%%      
        % -> vectorized version of for-loop over states_period
      
        idx_parent = statespace2index(indexer, states_period);
            % (includes +1 indexing for exp columns)
        
        % 3 potential follow up states depending on choice
        kid_states_period = repmat(states_period, 1, 1, num_choices);
        kid_states_period(:, 1, :) = kid_states_period(:, 1, :) + 1;     % adjust period
        % update exp and lagged choice
        kid_states_period(:, 3, 1) = 1;         % choice home
        
        kid_states_period(:, 3, 2) = 2;         % choice land
        kid_states_period(:, 4, 2) = kid_states_period(:, 4, 2) + 1;
        
        kid_states_period(:, 3, 3) = 3;
        kid_states_period(:, 5, 3) = kid_states_period(:, 5, 3) + 1;
               
        % choice dependent kids (for all states; column-vector)
        idx_1 = statespace2index(indexer, kid_states_period(:, :, 1));
        idx_2 = statespace2index(indexer, kid_states_period(:, :, 2));
        idx_3 = statespace2index(indexer, kid_states_period(:, :, 3));
        
        % get continuation values fro EMAXS matrix
        emaxs(idx_parent,1) = emaxs(idx_1, 4);
        emaxs(idx_parent,2) = emaxs(idx_2, 4);
        emaxs(idx_parent,3) = emaxs(idx_3, 4);
  %%%%%%%%%%%%%%%%%%%%%%%% 
             
    end
    
           

% Calculate EMAX for period reached by current loop
%%%%%%%%%%%%%%%%%%%%%%
    % Alternative to loop over states:
    num_draws = size(draws, 1);
      
    % Get Index for all states of current period
    idx_states_period = statespace2index(indexer, states_period);
        idx_dummy = repelem(idx_states_period, num_draws,1);
    
    % Prep period draws
    draws = repmat(draws, length(idx_states_period), 1);
    
    % Get systematic wage component
    log_wage_systematic_period = repelem(log_wage_systematic(idx_states_period), num_draws,1);   
           
    % Get non-consumption utility component
    non_consumption_utility_period = repelem(non_consumption_utility(idx_states_period,:), num_draws, 1);
       
    % Calculate wages
    wages_period = exp(log_wage_systematic_period + draws);
        % adjust for free consumption
        wages_period(:, 1) = free_consumption;
    
    % Calculate total consumption utilities
    consumption_utilities_period = (wages_period.^mu)/mu;
    
    % Get continuation values
    continuation_values_period = repelem(emaxs(idx_states_period, 1:num_choices), num_draws, 1);   
    
    % Calculate value functions 
    value_functions_period = consumption_utilities_period .* non_consumption_utility_period + delta * continuation_values_period;
    
    % Highest value function for each state_utility-disturbance combination
    emax_period = max(value_functions_period, [], 2);
        % sum over draws
        emax_period = (accumarray(idx_dummy, emax_period) / num_draws);
        
    % Write maximized value function to EMAXS matrix
    emaxs(idx_states_period, 4) = emax_period(idx_states_period);
    %%%%%%%%%%%%%%%%%%%%%%%

    %fprintf('Loop Period: %d \n', period);
    %toc
end

end

