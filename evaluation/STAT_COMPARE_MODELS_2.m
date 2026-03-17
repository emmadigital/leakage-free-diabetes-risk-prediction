%% STAT_COMPARE_MODELS_2.m
clear; clc;

models = { ...
    'Logistic Regression', 'results2_logreg_seeds.mat'; ...
    'Random Forest',       'results2_rf_seeds.mat'; ...
    'Plain FFNN',          'results2_plain_seeds.mat'; ...
    'GRNN',                'results2_grnn_seeds.mat'; ...
    'BPNN',                'results2_bpnn_seeds.mat'; ...
    'ABC-FFNN',            'results2_abc_seeds.mat' ...
};

pairs = {
    'Logistic Regression', 'Random Forest';
    'Logistic Regression', 'Plain FFNN';
    'Logistic Regression', 'GRNN';
    'Logistic Regression', 'BPNN';
    'Logistic Regression', 'ABC-FFNN';
    'Random Forest',       'Plain FFNN';
    'Random Forest',       'GRNN';
    'Random Forest',       'BPNN';
    'Random Forest',       'ABC-FFNN';
    'Plain FFNN',          'GRNN';
    'Plain FFNN',          'BPNN';
    'Plain FFNN',          'ABC-FFNN';
    'GRNN',                'ABC-FFNN'
};

fprintf('============================================\n');
fprintf('STATISTICAL COMPARISON OF MODELS - DATASET 2\n');
fprintf('============================================\n\n');

R = struct();
for i = 1:size(models,1)
    name = models{i,1};
    file = models{i,2};
    assert(isfile(file), 'Missing file: %s', file);
    R.(matlab.lang.makeValidName(name)) = load(file);
end

for i = 1:size(pairs,1)
    Aname = pairs{i,1};
    Bname = pairs{i,2};

    A = R.(matlab.lang.makeValidName(Aname));
    B = R.(matlab.lang.makeValidName(Bname));

    fprintf('--------------------------------------------\n');
    fprintf('Comparing: %s  vs  %s\n', Aname, Bname);
    fprintf('--------------------------------------------\n\n');

    % --- [1] Multi-seed paired comparison ---
    fprintf('[1] Multi-seed paired comparison\n');

    nSeed = min(length(A.auc_seed), length(B.auc_seed));
    aucA = A.auc_seed(1:nSeed);
    aucB = B.auc_seed(1:nSeed);
    accA = A.acc_seed(1:nSeed);
    accB = B.acc_seed(1:nSeed);

    [~, p_t_auc, ~, stats_auc] = ttest(aucA, aucB);
    p_w_auc = signrank(aucA, aucB);

    [~, p_t_acc, ~, stats_acc] = ttest(accA, accB);
    p_w_acc = signrank(accA, accB);

    fprintf('AUC  paired t-test: p = %.6f, t(%d) = %.4f\n', p_t_auc, stats_auc.df, stats_auc.tstat);
    fprintf('AUC  Wilcoxon signed-rank: p = %.6f\n', p_w_auc);
    fprintf('ACC  paired t-test: p = %.6f, t(%d) = %.4f\n', p_t_acc, stats_acc.df, stats_acc.tstat);
    fprintf('ACC  Wilcoxon signed-rank: p = %.6f\n\n', p_w_acc);

    % --- [2] DeLong AUC comparison ---
    fprintf('[2] Paired AUC comparison (DeLong test)\n');

    yA = A.y_all_seed{1}(:);
    pA = A.p_all_seed{1}(:);
    yB = B.y_all_seed{1}(:);
    pB = B.p_all_seed{1}(:);

    assert(isequal(yA, yB), 'Seed-1 pooled labels differ between models.');
    [p_delong, z_delong, auc1, auc2] = delong_roc_test(yA, pA, pB);

    fprintf('%s AUC = %.4f\n', Aname, auc1);
    fprintf('%s AUC = %.4f\n', Bname, auc2);
    fprintf('DeLong test: z = %.4f, p = %.6f\n\n', z_delong, p_delong);

    % --- [3] McNemar test ---
    fprintf('[3] Paired accuracy comparison (McNemar test)\n');

    predA = double(pA >= 0.5);
    predB = double(pB >= 0.5);

    [p_mc, stat_mc, n01, n10, methodStr] = mcnemar_test_from_predictions(yA, predA, predB);

    fprintf('Discordant pairs: n01 = %d, n10 = %d\n', n01, n10);
    fprintf('McNemar test (%s): statistic = %.4f, p = %.6f\n\n', methodStr, stat_mc, p_mc);
end