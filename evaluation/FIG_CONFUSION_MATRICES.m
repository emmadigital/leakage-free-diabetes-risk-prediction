%% FIG_CONFUSION_MATRICES.m
clear; clc; close all;

models = {
    'Logistic Regression','results2_logreg_seeds.mat';
    'Random Forest','results2_rf_seeds.mat';
    'FFNN','results2_plain_seeds.mat';
    'BPNN','results2_bpnn_seeds.mat';
    'GRNN','results2_grnn_seeds.mat';
    'ABC-FFNN','results2_abc_seeds.mat'
};

fig = figure('Color','w','Position',[100 100 1200 700]);

for i = 1:6
    
    subplot(2,3,i)
    
    S = load(models{i,2});
    
    % Sum confusion matrices across seeds
    C = sum(S.Csum_seed,3);
    
    % Row-normalize
    Cn = C ./ sum(C,2);
    
    imagesc(Cn)
    colormap(parula)
    caxis([0 1])
    
    xticks([1 2])
    yticks([1 2])
    
    xticklabels({'Pred: No Diabetes','Pred: Diabetes'})
    yticklabels({'True: No Diabetes','True: Diabetes'})
    
    title(models{i,1},'FontWeight','bold')
    
    % Annotate values
    for r = 1:2
        for c = 1:2
            text(c,r,sprintf('%.2f',Cn(r,c)), ...
                'HorizontalAlignment','center', ...
                'Color','w','FontWeight','bold','FontSize',11);
        end
    end
    
end

sgtitle('Row-Normalized Confusion Matrices (Dataset 2: Early Stage Risk)', ...
        'FontSize',14,'FontWeight','bold')

exportgraphics(fig,'FIG_CONFUSION_MATRICES.png','Resolution',600)
exportgraphics(fig,'FIG_CONFUSION_MATRICES.pdf','ContentType','vector')

disp('Confusion matrix figure saved.')
