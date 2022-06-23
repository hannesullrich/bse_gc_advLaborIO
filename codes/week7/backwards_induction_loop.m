function [emaxs] = backwards_induction_loop(specs, states, indexer, log_wage_systematic, non_consumption_utility, draws_emax)
% Function: execute backwards induction

%fprintf('--------------------------- \n');
%fprintf('Function: Execute Backwards Induction \n');

% Unpack model specification:
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
    
    % Extract period information:
    % States
    states_period = states(states(:, 1) == period, :);
    
    % Draws Period
    draws = draws_emax(:, :, period);
    
    % Continuation Values:
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
    % Loop over states in current period
    %    -> time-intensive loop!
    for k = 1:size(states_period, 1)
        
        % unpack current state
        % -> idx_parent for periods < T
        age_lvl = states_period(k, 2);
        choice_lagged = states_period(k, 3);
        exp_l = states_period(k, 4) + 1;        % add 1 for correct indice
        exp_f = states_period(k, 5) + 1;        % add 1 for correct indice
        type = states_period(k, 6);
            
        state_current = indexer(period, age_lvl, choice_lagged, exp_l, exp_f, type);
            % this an index; use function: statespace2index
            

            
        % numerical integration over distribution of error terms
        emax = 0;
        
        num_draws = size(draws, 1);       % unnecessary bc num_draws initialized in beginning?
        
        
        % loop over amount of draws (combined with loop over states this takes most
        % time -> use different numerical integration method?)
        for i = 1:num_draws
            
            current_max_value_function = invalid_float;
            
            % loop over choice          (vectorize - see simulation section)
            for j = 1:num_choices
                
                wage =  exp(log_wage_systematic(state_current) + draws(i, j));
                
                % consumption utiltiy depending on choice
                if j == 1
                    consumption_utility = (free_consumption^mu)/mu;
                else
                    consumption_utility = (wage^mu)/mu;
                end
                
                value_function_choice = consumption_utility * non_consumption_utility(state_current, j) + delta * emaxs(state_current, j);
                
                if value_function_choice > current_max_value_function
                    current_max_value_function = value_function_choice;
                end
                
            end
            
            
            % sum maximized aggregate utilities over draws
            emax = emax + current_max_value_function;
            
        end
        
        
        emax = emax / num_draws;
        
        % write maximized value function to EMAXS matrix
        emaxs(state_current, 4) = emax;
       
   end     % end for loop over states    

    %fprintf('Loop Period: %d \n', period);
    %toc
end

end

