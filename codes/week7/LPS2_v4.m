%% Labor Problem Set 2
% Structural Econometrics
% June 2021

% 0. Model Specification
% 1. State Space Creation
% 2. Auxilliary Components
% 3. Backwards Induction
% 4. Model Simulation


close all
clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0. Model Specification

% Missings integers state space
integer_mis = -99;
invalid_float = -99;
    % -> alternative would be to use NaN-matrix 

% Model specification:
% - general
num_choices = 3;                    % number of choices
num_periods = 10;                   % number of periods

% - solution
states_pre_size = 1000000;          % pre-allocate larger then required!!
seed_emax = 2131;                   % rng-seed emaxs disturbances Monte-Carlo Integration
num_draws_emax = 500;               % number of draws for Monte-Carlo Integration

% - simulation
num_agents = 1000;                  % number of agents
seed_sim = 19;                      % rng-seed simulation

% - exogenous components
free_consumption = 2.00;            % outside option

% - intertemporal
delta = 0.98;                       % discount factor
mu = 0.6;                           % risk aversion/degree of intertemporal substitution

% model parameters:
% - consumption / wage equation
gamma0 = [.3446, .2064];            % constant consumption / wage equation
gamma0_start = [.25, .25];          % for estimation
gamma1 = [.5363, .4223];            % returns to experience
var_shocks = [0, 0.025, 0.0625];    % transitory productivity shocks

% - heterogeneity
% -- observed
pr_old = .7;                        % share of old individuals
pr_young = .3;                      % share of young individuals

% -- unobserved
pr_type_low = .2;                   % share of play-hard types
theta_f = [-0.26, -0.19];           % play-hard type contribution to disutility of fishing 
theta_l = [-0.24, -0.10];           % play-hard type contribution to disutility of land work

% - production function
p_l = 0.75;                          % experience factor


% write model specificaiton to data-struct
specs.integer_mis = integer_mis;
specs.invalid_float = invalid_float;
specs.num_choices = num_choices;
specs.num_periods = num_periods;
specs.states_pre_size = states_pre_size;
specs.delta = delta;
specs.num_agents = num_agents;
specs.seed_sim = seed_sim;
specs.seed_emax = seed_emax;
specs.num_draws_emax = num_draws_emax;
specs.free_consumption = free_consumption;
specs.mu = mu;
specs.gamma0 = gamma0;
specs.gamma0_start = gamma0_start;
specs.gamma1 = gamma1;
specs.pr_old = pr_old; specs.pr_young = pr_young;
specs.pr_type_low = pr_type_low;
specs.theta_f = theta_f;
specs.theta_l = theta_l;
specs.var_shocks = var_shocks;
specs.p_l = p_l;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Create State Space
fprintf('----------------------------------------------------- \n');
fprintf('1. Generate State Space \n');

% Generate state-space and indexer based on model specification
[states, indexer] = gen_statespace_indexer(specs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Auxilliary Components
fprintf('----------------------------------------------------- \n');
fprintf('2. Compute Auxilliary Components \n');
tic

% 2.1 Derive Utility Components               
[log_wage_systematic, non_consumption_utility] = util_components(specs, states);        
    

% 2.2 Draw Disturbances
% Input parameters of distribution
mean_shocks = zeros(num_draws_emax, num_choices);
shocks_cov_matrix = diag(var_shocks);

% use function to draw disturbances
draws_emax = draw_disturbances(seed_emax, mean_shocks, shocks_cov_matrix, num_draws_emax, num_choices, num_periods);


toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Model Solution - Backwards Induction
fprintf('----------------------------------------------------- \n');
fprintf('3. Backward Induction \n');
fprintf('----------------------------------------------------- \n');
fprintf('Loop version \n');
tic   
test = backwards_induction_loop(specs, states, indexer, log_wage_systematic, non_consumption_utility, draws_emax);
toc

fprintf('----------------------------------------------------- \n');
fprintf('3Vectorised \n');
tic   
emaxs = backwards_induction_3d_vect(specs, states, indexer, log_wage_systematic, non_consumption_utility, draws_emax);
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Model Simulation
fprintf('----------------------------------------------------- \n');
fprintf('4. Model Simulation (Question 2) \n');

tic
[data_sim, choice_rates, avg_period_consumption] = model_simulation(specs, indexer, log_wage_systematic, non_consumption_utility, emaxs);
toc

% Output simulated data
col_names = {'Identifier', 'Period', 'Age_Level', 'Lagged_Choice','Exp_Land_Work', ...
                'Exp_Fishing_Work', 'Type', 'Choice', 'Log_Systematic_Consumption', ...
                'Period_Wage_Home', 'Period_Wage_Land', 'Period_Wage_Fishing', ... 
                'Non_Consumption_Util_Home', 'Non_Consumption_Util_Land', 'Non_Consumption_Util_Fishing', ...
                'Flow_Util_Home', 'Flow_Util_Land', 'Flow_Util_Fishing', ...
                'Continuation_Value_Home', 'Continuation_Value_Land', 'Continuation_Value_Fishing'};
output_data_sim = array2table(data_sim, 'VariableNames', col_names);
output_data_sim = sortrows(output_data_sim, 2);

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Comparative statics
fprintf('----------------------------------------------------- \n');
fprintf('5. Model Simulation (Question 3) \n');
tic

% New disutility levels
theta_f_q3 = [-0.36, -0.19]; specs.theta_f = theta_f_q3;
theta_l_q3= [-0.34, -0.10]; specs.theta_l = theta_l_q3;
    % -> affects non-consumption utilities

% Solution
% - derived components
[log_wage_systematic2, non_consumption_utility2] = util_components(specs, states); 

% - Backward induction
emaxs2 = backwards_induction_3d_vect(specs, states, indexer, log_wage_systematic2, non_consumption_utility2, draws_emax);

% Simulation
[data_sim_q3, choice_rates_q3] = model_simulation(specs, indexer, log_wage_systematic2, non_consumption_utility2, emaxs2);

toc


% % 7. Plot Choice Rates
% fprintf('----------------------------------------------------- \n');
% fprintf('7. Plot Choice Rates) \n');    
% 
% time = 1:num_periods;
% 
% f1 = figure('Name', 'Choice Rates - Young/Playhard');
%     tiledlayout(2,2);
%     sgtitle('Choice Rates - Young/Playhard')
%     
%     nexttile
%     plot(time, choice_rates(:,1,1), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,1,1), '--');
%     title('Home')
%     ylim([0 1.1])
%     
%     nexttile
%     plot(time, choice_rates(:,2,1), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,2,1), '--');
%     title('Land')
%     ylim([0 1.1])
%     
%     nexttile
%     plot(time, choice_rates(:,3,1), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,3,1), '--');
%     title('Fish')
%     ylim([0 1.1])
%     
%     saveas(f1,'choices_young_playhard.png') 
% 
%     
% f2 = figure('Name', 'Choice Rates - Young/Workhard');
%     tiledlayout(2,2)
%     sgtitle('Choice Rates - Young/Workhard');
%     
%     nexttile
%     plot(time, choice_rates(:,1,2), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,1,2), '--');
%     title('Home')
%     ylim([0 1.1])
%     
%     nexttile
%     plot(time, choice_rates(:,2,2), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,2,2), '--');
%     title('Land')
%     ylim([0 1.1])
%     
%     nexttile
%     plot(time, choice_rates(:,3,2), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,3,2), '--');
%     title('Fish')
%     ylim([0 1.1])
%  
%     saveas(f2,'choices_young_workhard.png') 
%     
% f3 = figure('Name', 'Choice Rates - Old/Playhard');
%     tiledlayout(2,2);
%     sgtitle('Choice Rates - Old/Playhard');
%     
%     nexttile
%     plot(time, choice_rates(:,1,3), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,1,3), '--');
%     title('Home')
%     ylim([0 1.1])
%     
%     nexttile
%     plot(time, choice_rates(:,2,3), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,2,3), '--');
%     title('Land')
%     ylim([0 1.1])
%     
%     nexttile
%     plot(time, choice_rates(:,3,3), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,3,3), '--');
%     title('Fish')
%     ylim([0 1.1])
% 
%     saveas(f3,'choices_old_playhard.png') 
%     
% f4 = figure('Name', 'Choice Rates - Old/Workhard');
%     tiledlayout(2,2);
%     sgtitle('Choice Rates - Old/Workhard');
%     
%     nexttile
%     plot(time, choice_rates(:,1,4), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,1,4), '--');
%     title('Home')
%     ylim([0 1.1])
%     
%     nexttile
%     plot(time, choice_rates(:,2,4), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,2,4), '--');
%     title('Land')
%     ylim([0 1.1])
%     
%     nexttile
%     plot(time, choice_rates(:,3,4), '-');
%     hold on 
%     plot(time, choice_rates_q3(:,3,4), '--');
%     title('Fish')
%     ylim([0 1.1])
%     
%     saveas(f2,'choices_old_workhard.png') 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 8. Estimation
fprintf('----------------------------------------------------- \n');
fprintf('8. Model Estimation) \n');

% Deset disutility levels to origional values:
theta_f = [-0.26, -0.19]; specs.theta_f = theta_f;
theta_l = [-0.24, -0.10]; specs.theta_l = theta_l;

load('moments_obs.mat');

% Define objective function
msmfun = @(gamma0_estim)msm_obj(gamma0_estim, specs, states, indexer, draws_emax, moments_obs);

options = ...
    optimset( 'Display', 'iter', ...
                'TolCon',1E-6,...
                'TolFun',1E-6,'TolX',1E-6,...
                'PlotFcns',@optimplotfval);
           
[gamma0_estim, fval] = fminsearch(msmfun, gamma0_start, options);


















