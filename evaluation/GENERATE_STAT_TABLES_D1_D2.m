%% GENERATE_STAT_TABLES_D1_D2.m
% Generates:
%   Table 4 -> Dataset 1 statistical comparison
%   Table 5 -> Dataset 2 statistical comparison
%
% Required helper functions in path:
%   - delong_roc_test.m
%   - mcnemar_test_from_predictions.m
%
% Works with saved result files containing:
%   y_all_seed, p_all_seed, pred_all_seed
% Optional but preferred:
%   id_all_seed

clear; clc;

%% =========================
% File definitions
% =========================

% Dataset 1
filesD1 = {
    'LogReg',   'results_logreg_seeds.mat';
    'RF',       'results_rf_seeds.mat';
    'FFNN',     'results_plain_seeds.mat';
    'BPNN',     'results_bpnn_seeds.mat';
    'GRNN',     'results_grnn_seeds.mat';
    'ABC-FFNN', 'results_abc_seeds.mat'
};

% Dataset 2
filesD2 = {
    'LogReg',   'results2_logreg_seeds.mat';
    'RF',       'results2_rf_seeds.mat';
    'FFNN',     'results2_plain_seeds.mat';
    'BPNN',     'results2_bpnn_seeds.mat';
    'GRNN',     'results2_grnn_seeds.mat';
    'ABC-FFNN', 'results2_abc_seeds.mat'
};

%% =========================
% Generate tables
% =========================
fprintf('Generating Table 4 (Dataset 1)...\n');
T4 = generateStatTable(filesD1, 'Dataset 1');

fprintf('Generating Table 5 (Dataset 2)...\n');
T5 = generateStatTable(filesD2, 'Dataset 2');

%% =========================
% Display
% =========================
disp(' ');
disp('===== TABLE 4: DATASET 1 =====');
disp(T4);

disp(' ');
disp('===== TABLE 5: DATASET 2 =====');
disp(T5);

%% =========================
% Save
% =========================
writetable(T4, 'Table4_Statistical_Comparison_Dataset1.csv');
writetable(T5, 'Table5_Statistical_Comparison_Dataset2.csv');

save('Table4_Statistical_Comparison_Dataset1.mat', 'T4');
save('Table5_Statistical_Comparison_Dataset2.mat', 'T5');

fprintf('\nSaved:\n');
fprintf(' - Table4_Statistical_Comparison_Dataset1.csv\n');
fprintf(' - Table5_Statistical_Comparison_Dataset2.csv\n');
fprintf(' - Table4_Statistical_Comparison_Dataset1.mat\n');
fprintf(' - Table5_Statistical_Comparison_Dataset2.mat\n');

%% =========================================================
% Main function
% =========================================================
function T = generateStatTable(fileMap, datasetLabel)

    nModels = size(fileMap,1);

    % Load all results first
    R = struct();
    for i = 1:nModels
        modelName = matlab.lang.makeValidName(fileMap{i,1});
        fileName  = fileMap{i,2};

        assert(isfile(fileName), 'Missing file: %s', fileName);
        R.(modelName) = load(fileName);
    end

    % Define model pairs
    pairs = nchoosek(1:nModels, 2);

    ModelComparison = {};
    DeltaAUC = [];
    DeLongZ = [];
    DeLongP = [];
    AccuracyDifference = [];
    McNemarP = [];
    Significance = {};

    for k = 1:size(pairs,1)
        i = pairs(k,1);
        j = pairs(k,2);

        nameA = fileMap{i,1};
        nameB = fileMap{j,1};

        A = R.(matlab.lang.makeValidName(nameA));
        B = R.(matlab.lang.makeValidName(nameB));

        % -----------------------------------
        % Get pooled predictions robustly
        % -----------------------------------
        [yA, pA, predA] = getRepresentativePredictions(A);
        [yB, pB, predB] = getRepresentativePredictions(B);

        % Align by IDs if available in both
        [yCommon, pACommon, predACommon, pBCommon, predBCommon] = ...
            alignPredictionsForComparison(A, B, yA, pA, predA, yB, pB, predB);

        % -----------------------------------
        % DeLong test
        % -----------------------------------
        [p_delong, z_delong, aucA, aucB] = delong_roc_test(yCommon, pACommon, pBCommon);
        delta_auc = aucB - aucA;

        % -----------------------------------
        % Accuracy difference and McNemar
        % -----------------------------------
        accA = mean(predACommon == yCommon);
        accB = mean(predBCommon == yCommon);
        accDiff = accB - accA;

        [p_mc, ~, ~, ~, ~] = mcnemar_test_from_predictions(yCommon, predACommon, predBCommon);

        % -----------------------------------
        % Significance label
        % -----------------------------------
        if p_delong < 0.05 || p_mc < 0.05
            if aucB > aucA
                sigLabel = sprintf('%s significantly better', nameB);
            elseif aucA > aucB
                sigLabel = sprintf('%s significantly better', nameA);
            else
                sigLabel = 'Significant difference';
            end
        else
            sigLabel = 'Not significant';
        end

        % -----------------------------------
        % Store
        % -----------------------------------
        ModelComparison{end+1,1} = sprintf('%s vs %s', nameA, nameB);
        DeltaAUC(end+1,1) = delta_auc;
        DeLongZ(end+1,1) = z_delong;
        DeLongP(end+1,1) = p_delong;
        AccuracyDifference(end+1,1) = accDiff;
        McNemarP(end+1,1) = p_mc;
        Significance{end+1,1} = sigLabel;
    end

    T = table(ModelComparison, DeltaAUC, DeLongZ, DeLongP, ...
              AccuracyDifference, McNemarP, Significance);

    % Round for cleaner table output
    T.DeltaAUC = round(T.DeltaAUC, 4);
    T.DeLongZ = round(T.DeLongZ, 4);
    T.DeLongP = round(T.DeLongP, 4);
    T.AccuracyDifference = round(T.AccuracyDifference, 4);
    T.McNemarP = round(T.McNemarP, 4);

    fprintf('%s: %d pairwise comparisons completed.\n', datasetLabel, height(T));
end

%% =========================================================
% Get representative predictions
% If IDs are available -> average across seeds by ID
% Otherwise -> use seed 1 pooled predictions
% =========================================================
function [y, p, pred] = getRepresentativePredictions(S)

    if isfield(S,'id_all_seed') && ~isempty(S.id_all_seed) && ...
       iscell(S.id_all_seed) && ~isempty(S.id_all_seed{1})
        [y, p] = averageSeedProbabilitiesRobust(S);
        pred = double(p >= 0.5);
    else
        warning('id_all_seed missing; using seed 1 pooled predictions.');
        y = S.y_all_seed{1}(:);
        p = S.p_all_seed{1}(:);
        pred = double(p >= 0.5);
    end
end

%% =========================================================
% Align predictions from two models
% If both contain id_all_seed, use IDs
% Otherwise assume seed-1 or representative order is same
% =========================================================
function [y, pA, predA, pB, predB] = alignPredictionsForComparison(A, B, ...
    yA, pA0, predA0, yB, pB0, predB0)

    hasIDA = isfield(A,'id_all_seed') && ~isempty(A.id_all_seed) && ...
             iscell(A.id_all_seed) && ~isempty(A.id_all_seed{1});
    hasIDB = isfield(B,'id_all_seed') && ~isempty(B.id_all_seed) && ...
             iscell(B.id_all_seed) && ~isempty(B.id_all_seed{1});

    if hasIDA && hasIDB
        idA = A.id_all_seed{1}(:);
        idB = B.id_all_seed{1}(:);

        [idA, idxA] = sort(idA);
        [idB, idxB] = sort(idB);

        assert(isequal(idA, idB), 'ID mismatch between compared models.');

        yA = A.y_all_seed{1}(:); yA = yA(idxA);
        yB = B.y_all_seed{1}(:); yB = yB(idxB);

        assert(isequal(yA, yB), 'Label mismatch after ID alignment.');

        pA = pA0(idxA);
        predA = predA0(idxA);

        pB = pB0(idxB);
        predB = predB0(idxB);

        y = yA;
    else
        assert(numel(yA) == numel(yB), ...
            'Prediction lengths differ and IDs are unavailable for alignment.');
        assert(isequal(yA, yB), ...
            'Label order differs and IDs are unavailable for alignment.');

        y = yA;
        pA = pA0;
        predA = predA0;
        pB = pB0;
        predB = predB0;
    end
end

%% =========================================================
% Average probabilities across seeds using subject IDs
% =========================================================
function [y_ref, p_avg] = averageSeedProbabilitiesRobust(S)

    assert(isfield(S,'y_all_seed'), 'Missing y_all_seed');
    assert(isfield(S,'p_all_seed'), 'Missing p_all_seed');
    assert(isfield(S,'id_all_seed'), 'Missing id_all_seed');

    nSeeds = numel(S.y_all_seed);

    id_ref = S.id_all_seed{1}(:);
    y_ref0 = S.y_all_seed{1}(:);
    p_ref0 = S.p_all_seed{1}(:);

    [id_ref_sorted, idx_ref] = sort(id_ref);
    y_ref = y_ref0(idx_ref);

    P = zeros(numel(id_ref_sorted), nSeeds);
    P(:,1) = p_ref0(idx_ref);

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

    p_avg = mean(P,2);
end