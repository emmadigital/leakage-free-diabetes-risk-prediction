%% FIG_CALIBRATION_CURVES_BOTH_DATASETS.m
clear; clc; close all;

% Choose representative models
D1 = { ...
    'Logistic Regression', 'results_logreg_seeds.mat', [0.85 0.33 0.10]; ...
    'Random Forest',       'results_rf_seeds.mat',     [0.47 0.67 0.19]; ...
    'GRNN',                'results_grnn_seeds.mat',   [0.00 0.45 0.74]  ...
};

D2 = { ...
    'Logistic Regression', 'results2_logreg_seeds.mat', [0.85 0.33 0.10]; ...
    'Random Forest',       'results2_rf_seeds.mat',     [0.47 0.67 0.19]; ...
    'GRNN',                'results2_grnn_seeds.mat',   [0.00 0.45 0.74]  ...
};

nBins = 10;
fig = figure('Color','w','Position',[100 100 1200 500]);

% -------- Dataset 1 --------
subplot(1,2,1); hold on; box off; grid on;
title('(A) Calibration Curves: Dataset 1', 'FontWeight','bold');
xlabel('Mean Predicted Probability');
ylabel('Observed Event Rate');
plot([0 1],[0 1],'k--','LineWidth',1.2);

leg1 = cell(size(D1,1),1);

for i = 1:size(D1,1)
    S = load(D1{i,2});
    y = S.y_all_seed{1}(:);
    p = S.p_all_seed{1}(:);

    [mp, op] = makeCalibrationCurve(y, p, nBins);
    plot(mp, op, '-o', 'Color', D1{i,3}, 'LineWidth', 2, 'MarkerSize', 5);
    leg1{i} = D1{i,1};
end
legend(leg1, 'Location', 'southeast');

% -------- Dataset 2 --------
subplot(1,2,2); hold on; box off; grid on;
title('(B) Calibration Curves: Dataset 2', 'FontWeight','bold');
xlabel('Mean Predicted Probability');
ylabel('Observed Event Rate');
plot([0 1],[0 1],'k--','LineWidth',1.2);

leg2 = cell(size(D2,1),1);

for i = 1:size(D2,1)
    S = load(D2{i,2});

    % Use seed 1 pooled predictions for plotting robustness
    y = S.y_all_seed{1}(:);
    p = S.p_all_seed{1}(:);

    [mp, op] = makeCalibrationCurve(y, p, nBins);
    plot(mp, op, '-o', 'Color', D2{i,3}, 'LineWidth', 2, 'MarkerSize', 5);
    leg2{i} = D2{i,1};
end
legend(leg2, 'Location', 'southeast');

exportgraphics(fig, 'FIG_CALIBRATION_CURVES_BOTH_DATASETS.png', 'Resolution', 600);
exportgraphics(fig, 'FIG_CALIBRATION_CURVES_BOTH_DATASETS.pdf', 'ContentType', 'vector');

disp('Saved: FIG_CALIBRATION_CURVES_BOTH_DATASETS.png and .pdf');

% ===== helper =====
function [meanPred, obsRate] = makeCalibrationCurve(y, p, nBins)
    edges = linspace(0,1,nBins+1);
    meanPred = nan(nBins,1);
    obsRate  = nan(nBins,1);

    for b = 1:nBins
        if b < nBins
            idx = p >= edges(b) & p < edges(b+1);
        else
            idx = p >= edges(b) & p <= edges(b+1);
        end

        if any(idx)
            meanPred(b) = mean(p(idx));
            obsRate(b) = mean(y(idx));
        end
    end

    keep = ~(isnan(meanPred) | isnan(obsRate));
    meanPred = meanPred(keep);
    obsRate  = obsRate(keep);
end
