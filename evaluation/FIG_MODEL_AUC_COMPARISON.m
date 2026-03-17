%% FIG_MODEL_AUC_COMPARISON.m


clear; clc; close all;

models = {'LogReg','RF','FFNN','BPNN','GRNN','ABC-FFNN'};

% Mean AUC values
auc1 = [0.8371 0.8323 0.7990 0.7973 0.8303 0.7594];
auc2 = [0.9730 0.9871 0.9889 0.9870 0.9976 0.9906];

% Standard deviation
sd1 = [0.0023 0.0036 0.0170 0.0173 0.0040 0.0050];
sd2 = [0.0029 0.0026 0.0037 0.0027 0.0009 0.0018];

% Combine means and SD
aucMat = [auc1; auc2]';
sdMat  = [sd1; sd2]';

fig = figure('Color','w','Position',[200 200 900 500]);

b = bar(aucMat,'grouped');
hold on

% Colors
b(1).FaceColor = [0.2 0.4 0.8];
b(2).FaceColor = [0.85 0.33 0.1];

ngroups = length(models);
nbars = size(aucMat,2);

groupwidth = min(0.8, nbars/(nbars+1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    
    errorbar(x, aucMat(:,i), sdMat(:,i), ...
        'k','linestyle','none','LineWidth',1.5);
end

set(gca,'XTick',1:length(models),'XTickLabel',models)

ylabel('ROC-AUC')
ylim([0.74 1.0])

legend({'Dataset 1 (PIMA)','Dataset 2 (Early Risk)'},'Location','northwest')

title('Model Discrimination Performance Across Two Diabetes Datasets')

grid on

exportgraphics(fig,'FIG_MODEL_AUC_COMPARISON.png','Resolution',600)
exportgraphics(fig,'FIG_MODEL_AUC_COMPARISON.pdf','ContentType','vector')

disp('Figure saved successfully.')
