function T = compute_midrank(x)
% compute_midrank
% Returns midranks for a vector x.
% Used by DeLong AUC comparison.

x = x(:);
[n, ~] = size(x);

[sorted_x, order] = sort(x);
T_sorted = zeros(n,1);

i = 1;
while i <= n
    j = i;
    while j <= n && sorted_x(j) == sorted_x(i)
        j = j + 1;
    end

    % Midrank for ties
    T_sorted(i:j-1) = 0.5 * (i + j - 1);

    i = j;
end

T = zeros(n,1);
T(order) = T_sorted;
T = T';
end