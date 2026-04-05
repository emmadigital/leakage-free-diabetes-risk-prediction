%% FIG_STAT_HEATMAP_D2_DYNAMIC.m
clear; clc; close all;

models = {'LogReg','RF','FFNN','BPNN','GRNN','ABC-FFNN'};
n = numel(models);

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
    0.6951
    0.8406
    0.0181
    0.4173
    0.1577
    0.5155
    0.0100
    0.2974
    0.0878
    0.0083
    0.4504
    0.1146
    0.2381
    0.2444
    0.7459
];

T5 = table(ModelComparison, DeLongP);

P = nan(n,n);
P(1:n+1:end) = 1;

for k = 1:height(T5)
    cmp = T5.ModelComparison{k};
    parts = split(string(cmp), ' vs ');
    m1 = strtrim(parts(1));
    m2 = strtrim(parts(2));

    i = find(strcmp(models, m1));
    j = find(strcmp(models, m2));

    if isempty(i) || isempty(j)
        warning('Skipping unmatched comparison: %s', cmp);
        continue;
    end

    p = T5.DeLongP(k);

    P(i,j) = p;
    P(j,i) = p;
end

P(isnan(P)) = 1;

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

title('Statistical Significance Matrix (DeLong Test p-values) – Dataset 2', ...
    'FontWeight','bold');
xlabel('Model');
ylabel('Model');

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
            'FontSize',13, ...
            'FontWeight','bold', ...
            'Color', txtColor);
    end
end

exportgraphics(gcf,'FIG_STAT_HEATMAP_D2_DYNAMIC_FIXED.png','Resolution',600);
exportgraphics(gcf,'FIG_STAT_HEATMAP_D2_DYNAMIC_FIXED.pdf','ContentType','vector');

disp('Dataset 2 dynamic heatmap saved successfully.');
