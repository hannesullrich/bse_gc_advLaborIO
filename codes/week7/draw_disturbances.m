function [draws] = draw_disturbances(seed, mean, covar, dim1, choices, periods)
% function to draw disturbances matrices 
%   Detailed explanation goes here

rng(seed);

draws(dim1, choices, periods) = zeros;

for period = 1:periods
    draws(:, :, period) = mvnrnd(mean, covar);
end

end

