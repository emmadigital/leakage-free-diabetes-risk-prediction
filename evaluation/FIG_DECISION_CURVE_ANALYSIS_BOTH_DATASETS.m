%% FIG_DECISION_CURVE_ANALYSIS_BOTH_DATASETS.m
clear; clc; close all;

% -----------------------------------------
% Top models for cleaner DCA visualization
% -----------------------------------------
filesD1 = {
    'results_logreg_seeds.mat', 'LogReg';
    'results_rf_seeds.mat',     'RF';
    'results_grnn_seeds.mat',   'GRNN';
    'results_abc_seeds.mat',    'ABC-FFNN'
};

filesD2 = {
    'results2_logreg_seeds.mat', 'LogReg';
    'results2_rf_seeds.mat',     'RF';
    'results2_grnn_seeds.mat',   'GRNN';
    'results2_abc_seeds.mat',    'ABC-FFNN'
};

thresholds = 0.01:0.01:0.50;   % clinically more realistic

fig = figure('Color','w','Position',[100 100 1250 520]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

% =========================
% Panel A: Dataset 1
% =========================
nexttile;
plotDCAForDataset(filesD1, thresholds, '(A) Decision Curve Analysis: Dataset 1 – PIMA');

% =========================
% Panel B: Dataset 2
% =========================
nexttile;
plotDCAForDataset(filesD2, thresholds, '(B) Decision Curve Analysis: Dataset 2 – Early-Stage Risk');

exportgraphics(fig, 'FIG_DECISION_CURVE_ANALYSIS_BOTH_DATASETS.png', 'Resolution', 600);
exportgraphics(fig, 'FIG_DECISION_CURVE_ANALYSIS_BOTH_DATASETS.pdf', 'ContentType', 'vector');

disp('Saved: FIG_DECISION_CURVE_ANALYSIS_BOTH_DATASETS.png');
disp('Saved: FIG_DECISION_CURVE_ANALYSIS_BOTH_DATASETS.pdf');

%% =========================================================
% Local function: plot DCA for one dataset
% =========================================================
function plotDCAForDataset(fileList, thresholds, plotTitle)

    hold on; box on;

    allY = [];
    allIDs = [];
    allP = cell(size(fileList,1),1);

    % -------------------------------------
    % Load subject-level aligned predictions
    % -------------------------------------
    for i = 1:size(fileList,1)
        S = load(fileList{i,1});

        if isfield(S,'id_all_seed') && iscell(S.id_all_seed) && ...
           ~isempty(S.id_all_seed) && ~isempty(S.id_all_seed{1})
            [y, p, ids] = averageSeedProbabilitiesWithIDs_local(S);
        else
            % Fallback: use seed 1 raw order
            y = S.y_all_seed{1}(:);
            p = S.p_all_seed{1}(:);
            ids = (1:numel(y))';
        end

        if isempty(allY)
            allY = y;
            allIDs = ids;
            allP{i} = p;
        else
            % Align to first model by IDs
            [idRef, idxRef] = sort(allIDs);
            [idCur, idxCur] = sort(ids);

            assert(isequal(idRef, idCur), ...
                'ID mismatch across models. Cannot align predictions safely.');

            yCur = y(idxCur);
            pCur = p(idxCur);

            assert(isequal(allY(idxRef), yCur), ...
                'Label mismatch across aligned models.');

            allP{i} = pCur;
        end
    end

    % Sort master labels once
    [allIDs, idxRef] = sort(allIDs);
    allY = allY(idxRef);

    % Reorder all prediction vectors
    for i = 1:numel(allP)
        if numel(allP{i}) == numel(idxRef)
            if i == 1
                allP{i} = allP{i}(idxRef);
            end
        end
    end

    N = numel(allY);
    prevalence = mean(allY);

    % -------------------------------------
    % Plot model net benefit curves
    % -------------------------------------
    for i = 1:size(fileList,1)
        p = allP{i};
        assert(numel(p) == N, 'Prediction length mismatch after alignment.');

        nb = zeros(size(thresholds));

        for t = 1:numel(thresholds)
            pt = thresholds(t);
            pred = p >= pt;

            TP = sum((pred == 1) & (allY == 1));
            FP = sum((pred == 1) & (allY == 0));

            nb(t) = (TP / N) - (FP / N) * (pt / (1 - pt));
        end

        plot(thresholds, nb, 'LineWidth', 2.4, 'DisplayName', fileList{i,2});
    end

    % Treat none
    plot(thresholds, zeros(size(thresholds)), 'k--', ...
        'LineWidth', 2, 'DisplayName', 'Treat None');

    % Treat all
    nb_all = zeros(size(thresholds));
    for t = 1:numel(thresholds)
        pt = thresholds(t);
        nb_all(t) = prevalence - (1 - prevalence) * (pt / (1 - pt));
    end
    plot(thresholds, nb_all, 'k:', ...
        'LineWidth', 2.2, 'DisplayName', 'Treat All');

    xlabel('Threshold Probability');
    ylabel('Net Benefit');
    title(plotTitle, 'FontWeight', 'bold');
    legend('Location', 'southwest');
    grid on;
    set(gca, 'FontSize', 11);
end

%% =========================================================
% Local helper: average probabilities across seeds by IDs
% =========================================================
function [y_ref, p_avg, id_ref_sorted] = averageSeedProbabilitiesWithIDs_local(S)

    nSeeds = numel(S.y_all_seed);

    id_ref = S.id_all_seed{1}(:);
    y0 = S.y_all_seed{1}(:);
    p0 = S.p_all_seed{1}(:);

    [id_ref_sorted, idx_ref] = sort(id_ref);
    y_ref = y0(idx_ref);

    P = zeros(numel(id_ref_sorted), nSeeds);
    P(:,1) = p0(idx_ref);

    for s = 2:nSeeds
        ids = S.id_all_seed{s}(:);
        ys  = S.y_all_seed{s}(:);
        ps  = S.p_all_seed{s}(:);

        [ids_sorted, idx] = sort(ids);
        ys_sorted = ys(idx);
        ps_sorted = ps(idx);

        assert(isequal(ids_sorted, id_ref_sorted), ...
            'Subject IDs differ across seeds.');
        assert(isequal(ys_sorted, y_ref), ...
            'Labels differ after ID alignment across seeds.');

        P(:,s) = ps_sorted;
    end

    p_avg = mean(P, 2);
end