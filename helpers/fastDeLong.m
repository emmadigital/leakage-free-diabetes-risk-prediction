function [aucs, delongcov] = fastDeLong(predictions_sorted_transposed, m)
% Fast DeLong implementation for 1 or more classifiers
% predictions_sorted_transposed: k x (m+n), positives first
% m = number of positive examples

[k, N] = size(predictions_sorted_transposed);
n = N - m;

positive_examples = predictions_sorted_transposed(:, 1:m);
negative_examples = predictions_sorted_transposed(:, m+1:end);

tx = zeros(k, m);
ty = zeros(k, n);
tz = zeros(k, m+n);

for r = 1:k
    tx(r,:) = compute_midrank(positive_examples(r,:));
    ty(r,:) = compute_midrank(negative_examples(r,:));
    tz(r,:) = compute_midrank(predictions_sorted_transposed(r,:));
end

aucs = sum(tz(:,1:m), 2) / (m*n) - (m + 1) / (2*n);
v01  = (tz(:,1:m) - tx) / n;
v10  = 1 - (tz(:,m+1:end) - ty) / m;

sx = cov(v01');
sy = cov(v10');

if k == 1
    sx = sx(:);
    sy = sy(:);
end

delongcov = sx / m + sy / n;
end