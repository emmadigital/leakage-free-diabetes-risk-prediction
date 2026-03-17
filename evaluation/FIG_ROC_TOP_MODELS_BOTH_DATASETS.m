%% FIG_ROC_TOP_MODELS_BOTH_DATASETS.m
clear; clc; close all;

% -----------------------------
% Dataset 1 (PIMA): top models
% -----------------------------
D1 = { ...
    'Logistic Regression', 'results_logreg_seeds.mat', [0.85 0.33 0.10]; ...
    'GRNN',                'results_grnn_seeds.mat',   [0.00 0.45 0.74]; ...
    'Random Forest',       'results_rf_seeds.mat',     [0.47 0.67 0.19]  ...
};

% -----------------------------------------
% Dataset 2 (Early Stage Diabetes Risk): top models
% -----------------------------------------
D2 = { ...
    'GRNN',         'results2_grnn_seeds.mat',  [0.00 0.45 0.74]; ...
    'ABC-FFNN',     'results2_abc_seeds.mat',   [0.49 0.18 0.56]; ...
    'Plain FFNN',   'results2_plain_seeds.mat', [0.85 0.33 0.10]  ...
};

fig = figure('Color','w','Position',[100 100 1200 520]);

% =========================
% Panel A: Dataset 1 (PIMA)
% =========================
subplot(1,2,1); hold on; box off; grid on;
title('(A) ROC Curves on Dataset 1: PIMA', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('False Positive Rate', 'FontSize', 12);
ylabel('True Positive Rate', 'FontSize', 12);

leg1 = cell(size(D1,1),1);

for i = 1:size(D1,1)
    name = D1{i,1};
    file = D1{i,2};
    col  = D1{i,3};

    S = load(file);

    % Use seed 1 pooled predictions only
    y = S.y_all_seed{1}(:);
    p = S.p_all_seed{1}(:);

    [fpr, tpr, ~, auc] = perfcurve(y, p, 1);
    plot(fpr, tpr, 'LineWidth', 2.5, 'Color', col);
    leg1{i} = sprintf('%s (AUC = %.3f)', name, auc);
end

plot([0 1], [0 1], 'k--', 'LineWidth', 1);
xlim([0 1]); ylim([0 1]);
legend(leg1, 'Location', 'southeast', 'FontSize', 10);

% ======================================
% Panel B: Dataset 2 (Early Stage Risk)
% ======================================
subplot(1,2,2); hold on; box off; grid on;
title('(B) ROC Curves on Dataset 2: Early Stage Risk', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('False Positive Rate', 'FontSize', 12);
ylabel('True Positive Rate', 'FontSize', 12);

leg2 = cell(size(D2,1),1);

for i = 1:size(D2,1)
    name = D2{i,1};
    file = D2{i,2};
    col  = D2{i,3};

    S = load(file);

    % Use seed 1 pooled predictions only
    y = S.y_all_seed{1}(:);
    p = S.p_all_seed{1}(:);

    [fpr, tpr, ~, auc] = perfcurve(y, p, 1);
    plot(fpr, tpr, 'LineWidth', 2.5, 'Color', col);
    leg2{i} = sprintf('%s (AUC = %.3f)', name, auc);
end

plot([0 1], [0 1], 'k--', 'LineWidth', 1);
xlim([0 1]); ylim([0 1]);
legend(leg2, 'Location', 'southeast', 'FontSize', 10);

exportgraphics(fig, 'FIG_ROC_TOP_MODELS_BOTH_DATASETS.png', 'Resolution', 600);
exportgraphics(fig, 'FIG_ROC_TOP_MODELS_BOTH_DATASETS.pdf', 'ContentType', 'vector');

disp('Saved: FIG_ROC_TOP_MODELS_BOTH_DATASETS.png and FIG_ROC_TOP_MODELS_BOTH_DATASETS.pdf');
