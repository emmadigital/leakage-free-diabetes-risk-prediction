%% FIG_STAT_HEATMAP_D1_DYNAMIC.m
clear; clc; close all;

% Final model order
models = {'LogReg','RF','FFNN','BPNN','GRNN','ABC-FFNN'};
n = numel(models);

% -------------------------------------------------------------------------
% Enter the FINAL Dataset 1 DeLong p-values here as comparison rows
% Update only this block if your final Table 4 changes
% -------------------------------------------------------------------------
ModelComparison = {
    'LogReg vs RF'
    'LogReg vs FFNN'
    'LogReg vs BPNN'
    'LogReg vs GRNN'
    'LogReg vs ABC-FFNN'
    'RF vs FFNN'
    'RF vs BPNN'
    'RF vs GRNN'
    'RF vs ABC-FFNN'
    'FFNN vs BPNN'
    'FFNN vs GRNN'
    'FFNN vs ABC-FFNN'
    'BPNN vs GRNN'
    'BPNN vs ABC-FFNN'
    'GRNN vs ABC-FFNN'
};

DeLongP = [
    0.7114
    0.0718
    0.0073
    0.8834
    0.0001
    0.1637
    0.0089
    0.7866
    0.0001
    0.2266
    0.0930
    0.0006
    0.0048
    0.0020
    0.0001
];

% Build a table dynamically
T4 = table(ModelComparison, DeLongP);

% -------------------------------------------------------------------------
% Build symmetric p-value matrix
% -------------------------------------------------------------------------
P = nan(n,n);
P(1:n+1:end) = 1;

for k = 1:height(T4)
    cmp = T4.ModelComparison{k};
    parts = split(string(cmp), ' vs ');
    m1 = strtrim(parts(1));
    m2 = strtrim(parts(2));

    i = find(strcmp(models, m1));
    j = find(strcmp(models, m2));

    if isempty(i) || isempty(j)
        warning('Skipping unmatched comparison: %s', cmp);
        continue;
    end

    p = T4.DeLongP(k);

    P(i,j) = p;
    P(j,i) = p;
end

P(isnan(P)) = 1;

% -------------------------------------------------------------------------
% Plot heatmap
% -------------------------------------------------------------------------
figure('Color','w','Position',[200 200 780 640]);

imagesc(P);
colormap(flipud(parula));
cb = colorbar;
cb.Label.String = 'DeLong test p-value';

caxis([0 1]);
axis square;
box on;

xticks(1:n);
yticks(1:n);
xticklabels(models);
yticklabels(models);
set(gca,'FontSize',11,'XTickLabelRotation',30);

title('Statistical Significance Matrix (DeLong Test p-values) – Dataset 1', ...
    'FontWeight','bold');
xlabel('Model');
ylabel('Model');

% Add text labels
for i = 1:n
    for j = 1:n
        if P(i,j) < 0.001
            txt = '<0.001';
        else
            txt = sprintf('%.3f', P(i,j));
        end

        if P(i,j) <= 0.35
            txtColor = 'k';
        else
            txtColor = 'w';
        end

        text(j, i, txt, ...
            'HorizontalAlignment','center', ...
            'FontSize',12, ...
            'FontWeight','bold', ...
            'Color', txtColor);
    end
end

exportgraphics(gcf,'FIG_STAT_HEATMAP_D1_DYNAMIC_FIXED.png','Resolution',600);
exportgraphics(gcf,'FIG_STAT_HEATMAP_D1_DYNAMIC_FIXED.pdf','ContentType','vector');

disp('Dataset 1 dynamic heatmap saved successfully.');