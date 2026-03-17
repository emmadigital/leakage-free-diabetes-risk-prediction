clc; clear; close all;

% Top 4 models
models = {'LogReg','RF','GRNN','ABC-FFNN'};
metrics = {'Accuracy','Sensitivity','Specificity','F1','AUC','Calibration'};
theta = linspace(0, 2*pi, numel(metrics)+1);
set(gca,'FontSize',13)

% =========================
% DATASET 1 (PIMA)
% Order: LogReg, RF, GRNN, ABC-FFNN
% Values should reflect relative performance across metrics
% =========================
D1 = [
    0.768 0.628 0.845 0.640 0.832 0.843;  % LogReg
    0.776 0.635 0.850 0.646 0.829 0.848;  % RF
    0.830 0.630 0.902 0.653 0.837 0.843;  % GRNN
    0.716 0.588 0.820 0.595 0.759 0.810;  % ABC-FFNN
];

% =========================
% DATASET 2 (EARLY RISK)
% Order: LogReg, RF, GRNN, ABC-FFNN
% Calibration column uses inverse Brier-like scaling proxy (higher = better)
% =========================
D2 = [
    0.9231 0.9331 0.9070 0.9372 0.9730 0.9395; % LogReg
    0.9476 0.9475 0.9477 0.9570 0.9871 0.9587; % RF
    0.9701 0.9670 0.9750 0.9755 0.9976 0.9753; % GRNN
    0.9608 0.9631 0.9570 0.9680 0.9906 0.9640; % ABC-FFNN
];

% Normalize each dataset by column max for radar comparison
D1n = D1 ./ max(D1, [], 1);
D2n = D2 ./ max(D2, [], 1);

% Colors
C = [
    0.0000 0.4470 0.7410;   % LogReg - blue
    0.8500 0.3250 0.0980;   % RF - orange
    0.4660 0.6740 0.1880;   % GRNN - green
    0.4940 0.1840 0.5560;   % ABC-FFNN - purple
];

fig = figure('Color','w','Position',[100 100 1200 520]);

% =========================
% DATASET 1 RADAR
% =========================
ax1 = polaraxes('Position',[0.05 0.12 0.38 0.76]);
hold(ax1,'on')

for i = 1:size(D1n,1)
    data = [D1n(i,:) D1n(i,1)];
    polarplot(ax1, theta, data, ...
        'LineWidth', 2.5, ...
        'Color', C(i,:), ...
        'Marker', 'o', ...
        'MarkerSize', 5, ...
        'MarkerFaceColor', C(i,:));
end

ax1.ThetaTick = rad2deg(theta(1:end-1));
ax1.ThetaTickLabel = metrics;
ax1.RLim = [0.75 1.00];
ax1.RTick = [0.8 0.9 1.0];
ax1.GridAlpha = 0.25;
ax1.FontSize = 11;
title(ax1,'(A) Dataset 1 – PIMA','FontWeight','bold','FontSize',14)

% =========================
% DATASET 2 RADAR
% =========================
ax2 = polaraxes('Position',[0.57 0.12 0.38 0.76]);
hold(ax2,'on')

for i = 1:size(D2n,1)
    data = [D2n(i,:) D2n(i,1)];
    polarplot(ax2, theta, data, ...
        'LineWidth', 2.5, ...
        'Color', C(i,:), ...
        'Marker', 'o', ...
        'MarkerSize', 5, ...
        'MarkerFaceColor', C(i,:));
end

ax2.ThetaTick = rad2deg(theta(1:end-1));
ax2.ThetaTickLabel = metrics;
ax2.RLim = [0.90 1.00];
ax2.RTick = [0.92 0.96 1.00];
ax2.GridAlpha = 0.25;
ax2.FontSize = 11;
title(ax2,'(B) Dataset 2 – Early Diabetes Risk','FontWeight','bold','FontSize',14)

% Global legend
lgd = legend(models,'Location','southoutside','Orientation','horizontal','FontSize',13);
lgd.Position = [0.34 0.01 0.32 0.05];

% Export
exportgraphics(fig,'Model_Ranking_Radar_Top4.png','Resolution',600);
exportgraphics(fig,'Model_Ranking_Radar_Top4.pdf','ContentType','vector');

disp('Saved: Model_Ranking_Radar_Top4.png and Model_Ranking_Radar_Top4.pdf');
exportgraphics(gcf,'Model_Ranking_Radar_Top4.pdf','ContentType','vector')
