%% FIG_CONFUSION_MATRICES_D2_FINAL.m
clear; clc; close all;

files = {
    'results2_logreg_seeds.mat', 'Logistic Regression';
    'results2_rf_seeds.mat',     'Random Forest';
    'results2_plain_seeds.mat',  'FFNN';
    'results2_bpnn_seeds.mat',   'BPNN';
    'results2_grnn_seeds.mat',   'GRNN';
    'results2_abc_seeds.mat',    'ABC-FFNN'
};

fig = figure('Color','w','Position',[100 100 1500 850]);
tiledlayout(2,3,'TileSpacing','compact','Padding','compact');

for i = 1:size(files,1)
    S = load(files{i,1}, 'Csum_seed');

    C = sum(S.Csum_seed, 3);
    Cn = C ./ sum(C,2);

    nexttile;
    imagesc(Cn);
    colormap(parula);
    caxis([0 1]);
    colorbar;
    axis square;

    title(files{i,2}, 'FontWeight','bold');
    xticks([1 2]); yticks([1 2]);
    xticklabels({'Pred: No Diabetes','Pred: Diabetes'});
    yticklabels({'True: No Diabetes','True: Diabetes'});
    xtickangle(25);

    for r = 1:2
        for c = 1:2
            pct = 100 * Cn(r,c);
            txt = sprintf('%.1f%%\n(n=%d)', pct, C(r,c));
            if Cn(r,c) > 0.5
                text(c, r, txt, 'HorizontalAlignment','center', ...
                    'Color','k','FontWeight','bold','FontSize',12);
            else
                text(c, r, txt, 'HorizontalAlignment','center', ...
                    'Color','w','FontWeight','bold','FontSize',12);
            end
        end
    end
end

sgtitle('Row-Normalized Confusion Matrices (Dataset 2: Early-Stage Risk)', ...
    'FontWeight','bold','FontSize',16);

exportgraphics(fig, 'FIG_CONFUSION_MATRICES_D2_FINAL.png', 'Resolution', 600);
exportgraphics(fig, 'FIG_CONFUSION_MATRICES_D2_FINAL.pdf', 'ContentType', 'vector');
disp('Saved Dataset 2 confusion matrices.');