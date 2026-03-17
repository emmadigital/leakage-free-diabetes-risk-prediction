function out = mcnemar_paired(y, predA, predB)
% McNemar test for paired classification disagreement
% y, predA, predB are binary column vectors (0/1)

y     = y(:);
predA = predA(:);
predB = predB(:);

assert(numel(y)==numel(predA) && numel(y)==numel(predB), ...
    'Input vectors must have same length.');

correctA = (predA == y);
correctB = (predB == y);

n01 = sum(correctA & ~correctB); % A correct, B wrong
n10 = sum(~correctA & correctB); % A wrong, B correct
nD  = n01 + n10;

if nD < 25
    % Exact binomial McNemar
    p = 2 * binocdf(min(n01,n10), nD, 0.5);
    p = min(p,1);
    stat = min(n01,n10);
    method = 'exact binomial';
else
    % Continuity-corrected chi-square
    stat = (abs(n01 - n10) - 1)^2 / nD;
    p = 1 - chi2cdf(stat, 1);
    method = 'chi-square with continuity correction';
end

out = struct();
out.n01 = n01;
out.n10 = n10;
out.statistic = stat;
out.p = p;
out.method = method;
end