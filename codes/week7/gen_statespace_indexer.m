function [states, indexer] = gen_statespace_indexer(specs)
% Generate State Space and corresponding Indexer based on Model
% Specification documented in 'specs' data-struct
fprintf('--------------------------- \n');
fprintf('Function: Generate state-space and corresponding Indexer \n');
tic

% Generate state-space:
%   - rows: states
%   - columns: period, age_group, lagged_choice, exp_l, exp_f, type

% Unpack Model Specification
states_pre_size = specs.states_pre_size;
invalid_float = specs.invalid_float;
integer_mis = specs.integer_mis;
num_periods = specs.num_periods;
num_choices = specs.num_choices;


% Pre-allocate state-space size for speed
    % - larger than actual state-space size; trimming at the end of section
states = zeros(states_pre_size,6) + invalid_float;

% Generate indexer
indexer(num_periods, 2, num_choices, num_periods, num_periods, 2) = zeros;

indexer(:, :, :, :, :, :) = integer_mis;
    % > use function "statespace2indexer" to map state-space into index

% Initialize index counter
idx = 1;

% Loop over all periods
for period = 1:num_periods
    % starting period is 1 for indexing convenience
    
    % Potential/Maximal combined experience in current period
    pot_exp = period - 1;
    
    % Loop over all age categories:
    for age_lvl = 1:2
        
        % Loop over all types
        for type = 1:2            
            
            % Define entry state in period 1
            if period == 1               
                % State space
                states(idx, :) = [period, age_lvl, 1, 0, 0, type];
               
                % Indexer
                indexer(period, age_lvl, 0+1, 0+1, 0+1, type) = idx;      
                
                % Update index counter
                idx = idx + 1;     
                
            else
                % loop over all admissable values of experience
                for exp_f = 0:pot_exp        
                    
                    for exp_l = 0:pot_exp
                        
                        % sum of exp larger active period
                        if (exp_f + exp_l) > pot_exp
                            continue       
                        end
                        
                        % loop over all choices
                        for choice_lagged = 1:num_choices
                            
                            % If individual has only worked in fishing in the past, she can only have
                            % fishing as lagged choice
                            if exp_f == pot_exp && choice_lagged ~= 3 
                                continue
                            end
                            
                            % If individual has only worked the land in the past, she can only have
                            % part-time (2) as lagged choice
                            if exp_l == pot_exp && choice_lagged ~= 2
                                continue
                            end
                            
                            % If individual has never worked in fishing, she cannot have that lagged
                            % activity
                            if exp_f == 0 && choice_lagged == 3
                                continue
                            end
                            
                            % If individual has never worked on the land, she cannot have that lagged
                            % activity
                            if exp_l == 0 && choice_lagged == 2
                                continue
                            end
                            
                            % If an individual has always been working, she cannot have home (1) as
                            % lagged choice
                            if (exp_f + exp_l) == pot_exp && choice_lagged == 1
                                continue
                            end
                            
                            
                           % Check for duplicate states
                           % by usage of indexer
                           if indexer(period, age_lvl, choice_lagged, exp_l+1, exp_f+1, type) ~= integer_mis
                               continue
                           end
                           
                           % Record index of currently reached admissable state space point
                           indexer(period, age_lvl, choice_lagged, exp_l+1, exp_f+1, type) = idx;
                           
                           states(idx,:) = [period, age_lvl, choice_lagged, exp_l, exp_f, type];
                           
                           % update index counter
                           idx = idx + 1;
                                                          
                        end
                    end
                end
            end
        end
    end
end

toc

% Trim state-space
cut = states(:, 1) ~= invalid_float;
states = states(cut, :);

end

