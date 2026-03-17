function [p, z, auc1, auc2] = delong_roc_test(y_true, pred1, pred2)
% Paired DeLong test for comparing two correlated ROC AUCs
% y_true must be binary {0,1}
% pred1, pred2 are predicted probabilities

y_true = y_true(:);
pred1  = pred1(:);
pred2  = pred2(:);

assert(numel(y_true)==numel(pred1) && numel(y_true)==numel(pred2), ...
    'Inputs must have same length.');

% Sort so positives come first
[~, order] = sort(y_true, 'descend');
y_true = y_true(order);
preds  = [pred1(order)'; pred2(order)'];

m = sum(y_true == 1);
n = sum(y_true == 0);

assert(m > 0 && n > 0, 'Both classes must be present.');

[aucs, delongcov] = fastDeLong(preds, m);
auc1 = aucs(1);
auc2 = aucs(2);

l = [1; -1];
z = abs(diff(aucs)) / sqrt(l' * delongcov * l);
p = 2 * (1 - normcdf(z));
end