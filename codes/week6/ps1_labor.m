%% Labor Problem Set 1
% Structural Econometrics
% May 2021

% 0. General Settings / Model Specification
% 1. Create State Space
% 2. State Space Derived Covariates
% 3. Backward Induction
% 4. Model Simulation


close all
clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0. Model Specification

% Missings integers state space
integer_mis = int32(-99);
invalid_float = int32(-99);
    % -> alternative would be to use NaN-matrix

% Hours settings
hours = [8, 12, 16];                    % hours choice set
T = 24;                                 % length day

% Model Specification
num_periods = 3;                        % number of periods (note: first period t=0)
num_choice = 3;                         % number of choices
experience_add = [0, 1, 2];             % added experience by hours choice
 

% Model parameters 
% Cobb-Douglas utility
alpha = 0.5;
betta = 0.5;
experience_factor = 0.25;               % experience factor
delta = 1;                              % discount factor  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Create State Space
% > Create state space matrix and indexer to uniquely identify states

% Experience process characterizes number of unique states per period:
%   > 2 * t - 1; for each t = 1, 2, 3, ...

% State-space matrix (states,2):
%   > rows: unique states
%   > columns: [period, accumulated experience]

% Shape of indexer: (n_periods, n_periods * 2)
%   > each row corresponds to a single period
%   > each column contains a unique state in the corresponding period

% Example: t=3; state-space 9x2; indexer 3x6


% Empty indexer
indexer = zeros(num_periods, num_periods * 2, 'int32') + invalid_float;
    
% Preallocation of memory for state-space
    % > successive extension of state-space matrix is inefficient
    % > here: state-space size can be determined based on number of periods
    %           sum(2 * t - 1) for t = 1:num_periods
    % > alternative: preallocate larger matrix than required and crop at the end
state_space = zeros(10000, 2, 'int32') + invalid_float;

% Initialize index
idx = 1;
   
% Loop to generate state-space
for period = 1:num_periods
    
    % Derive potential experience ceiling
    pot_exp = (period - 1) * 2;
    
    if period == 1
        % Define initial state in first period
        indexer(period, 1) = idx;
        
        % gen state-space matrix
        state_space(idx, :) = [period, 0];          % initial experience level is zero
        
        % update index counter
        idx = idx + 1;
        
    else
        % Loop over all admissable values of experience
        for exp = 0:pot_exp 
            
            % Record index of currently reached admissable space point
            indexer(period, exp + 1) = idx;
            
            % Write to state-space
            state_space(idx, :) = [period, exp];
            
            idx = idx + 1;            
        end
    end 
end

% Crop state-space
state_space = state_space(1:(idx - 1), :);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. State Space Derived Covariates
% > derivation of production levels in each state

produce = (1 + experience_factor * double(state_space(:, 2))) .^ 2;


%% 3. Backward Induction
% Procedure:
% 1) retrieve continuation values from t+1 period (except for last period)
%   -> fill in emax matrix
% 2) derive alternative specific value functions in each state:
%   -> by flow utility + continuation value from emax
% 3) determine optimal choice in each state


% Empty matrices
emaxs = zeros(size(state_space, 1), num_choice + 1);        % value function maximization
    emaxs(:, num_choice + 1) = invalid_float;
value_function = zeros(length(state_space), num_choice);     % value functions

% Derive flow utilities 
flow_utililities = (produce .^ alpha) * ((T - hours) .^ betta);


% Backwards loop over periods
for period = num_periods : -1 : 1
    
    % States in current period reached by loop
    states_period = state_space(state_space(:, 1) == period, :);
    
    % Retrieve continuation values
    if period == num_periods
        % no action required; continuation values are known to be zero in the last period
        
    else        
        % Loop over active states
        for i = 1:size(states_period, 1)
            
            % Get index parent
            idx_parent = indexer(period, states_period(i, 2) + 1);
                % recall: intial exp=0 requires matrix-index move +1
                
            % Determine index of kid-states depending on choice
            idx_h1 = indexer(period + 1, states_period(i, 2) + 1);          % choice: 8 hours
            idx_h2 = indexer(period + 1, states_period(i, 2) + 1 + 1);      % choice: 12 hours
            idx_h3 = indexer(period + 1, states_period(i, 2) + 1 + 2);      % choice: 16 hours
            
            % Retrieve corresponding EMAX
            emaxs(idx_parent, 1) = emaxs(idx_h1, 4);
            emaxs(idx_parent, 2) = emaxs(idx_h2, 4); 
            emaxs(idx_parent, 3) = emaxs(idx_h3, 4);                 
        end        
    end
       
    % Calculate maximum value function
    for i = 1:size(states_period, 1)
        
        % Placeholder:
        current_max_value_function = invalid_float;
        
        % Get state index (cp. idx_parent above)
        state = indexer(period, states_period(i, 2) + 1);
        
        % Loop over hours choices 
        for j = 1:length(hours)
            
            % Choice-specific value function
            value_function_choice = flow_utililities(state, j) + delta * emaxs(state, j);
            
            % Entry in value-function matrix
            value_function(state, j) = value_function_choice;
            
            % Reset maximized value function 
            if value_function_choice > current_max_value_function
                current_max_value_function = value_function_choice;   
            end    
        end
        
        % Write maximized value function to emaxs matrix
        emaxs(state, num_choice + 1) = current_max_value_function;          
    end   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Model Simulation

% Choice solution matrix
data_sim = zeros(num_periods, 4);

% Loop over all periods:
for period = 1:num_periods
    
    % Set starting state in first period
    if period==1
        current_state = state_space(period, :);     % single state
    
    else
        % current state already active from update in previous iteration    
    end
    
    idx = indexer(period, current_state(1, 2) + 1);        
    
    % Derive flow-utilities in active state
    flow_utilities = (produce(idx) .^ alpha) * ((T - hours) .^ betta);
    
    % Derive value functions
    value_functions = flow_utilities + delta * emaxs(idx, 1:3);
    
    % Determine choice by highest choice-specific value function
    [max_value_function, choice] = max(value_functions);
    
    % Write solution to data-matrix
    data_sim(period,:) = [period, current_state(1, 2), choice, max_value_function];
       
    % Update to following state based on choice
    current_state = [period + 1, current_state(1, 2) + experience_add(choice)];  
end

% Output simulated Data
col_names = {'Period', 'Experience', 'Choice', 'Value Function'};
output_data_sim = array2table(data_sim, 'VariableNames', col_names);































