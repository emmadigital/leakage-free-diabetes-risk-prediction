%% FIG_ROC_ALL_MODELS_BOTH_DATASETS.m
clear; clc; close all;

models = {'logreg','rf','plain','bpnn','grnn','abc'};
labels = {'LogReg','RF','FFNN','BPNN','GRNN','ABC-FFNN'};

colors = lines(numel(models));

fig = figure('Color','w','Position',[100 100 1300 520]);

for d = 1:2
    subplot(1,2,d); hold on; box on;

    for m = 1:numel(models)
        if d == 1
            fname = sprintf('results_%s_seeds.mat', models{m});
        else
            fname = sprintf('results2_%s_seeds.mat', models{m});
        end

        S = load(fname, 'y_all_seed', 'p_all_seed');

        % Use pooled predictions across all seeds
        y = vertcat(S.y_all_seed{:});
        p = vertcat(S.p_all_seed{:});

        [fpr, tpr, ~, auc] = perfcurve(y, p, 1);

        plot(fpr, tpr, 'LineWidth', 2, ...
            'Color', colors(m,:), ...
            'DisplayName', sprintf('%s (AUC = %.3f)', labels{m}, auc));
    end

    plot([0 1], [0 1], 'k--', 'LineWidth', 1.5);

    xlabel('False Positive Rate');
    ylabel('True Positive Rate');

    if d == 1
        title('(A) ROC Curves on Dataset 1: PIMA', 'FontWeight', 'bold');
    else
        title('(B) ROC Curves on Dataset 2: Early-Stage Risk', 'FontWeight', 'bold');
    end

    legend('Location', 'southeast');
    grid on;
    xlim([0 1]);
    ylim([0 1]);
    set(gca, 'FontSize', 12);
end

exportgraphics(fig, 'FIG_ROC_ALL_MODELS_BOTH_DATASETS.png', 'Resolution', 600);
exportgraphics(fig, 'FIG_ROC_ALL_MODELS_BOTH_DATASETS.pdf', 'ContentType', 'vector');
disp('Saved ROC figure for both datasets.');