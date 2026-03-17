function [p_mc, stat_mc, n01, n10, methodStr] = mcnemar_test_from_predictions(y, predA, predB)
% McNemar test from paired predictions
%
% Inputs:
%   y     : true labels (0/1)
%   predA : predictions from model A (0/1)
%   predB : predictions from model B (0/1)
%
% Outputs:
%   p_mc      : p-value
%   stat_mc   : test statistic
%   n01, n10  : discordant pair counts
%   methodStr : description of test used

y = y(:);
predA = predA(:);
predB = predB(:);

assert(numel(y)==numel(predA) && numel(y)==numel(predB), ...
    'Inputs must have the same length.');

% Correctness indicators
corrA = (predA == y);
corrB = (predB == y);

% Discordant pairs
n01 = sum(corrA==0 & corrB==1); % A wrong, B correct
n10 = sum(corrA==1 & corrB==0); % A correct, B wrong

nDisc = n01 + n10;

if nDisc == 0
    p_mc = 1.0;
    stat_mc = 0.0;
    methodStr = 'exact binomial';
    return;
end

% Use exact binomial for small discordant counts
if nDisc < 25
    x = min(n01, n10);
    p_mc = 2 * binocdf(x, nDisc, 0.5);
    p_mc = min(p_mc, 1);
    stat_mc = nDisc;
    methodStr = 'exact binomial';
else
    % Chi-square with continuity correction
    stat_mc = (abs(n01 - n10) - 1)^2 / nDisc;
    p_mc = 1 - chi2cdf(stat_mc, 1);
    methodStr = 'chi-square with continuity correction';
end
end