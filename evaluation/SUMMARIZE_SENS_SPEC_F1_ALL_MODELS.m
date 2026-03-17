%% SUMMARIZE_SENS_SPEC_F1_ALL_MODELS.m
clear; clc;

% =========================
% File definitions
% =========================

filesD1 = {
    'Logistic Regression', 'results_logreg_seeds.mat';
    'Random Forest',       'results_rf_seeds.mat';
    'Plain FFNN',          'results_plain_seeds.mat';
    'BPNN',                'results_bpnn_seeds.mat';
    'GRNN',                'results_grnn_seeds.mat';
    'ABC-FFNN',            'results_abc_seeds.mat'
};

filesD2 = {
    'Logistic Regression', 'results2_logreg_seeds.mat';
    'Random Forest',       'results2_rf_seeds.mat';
    'Plain FFNN',          'results2_plain_seeds.mat';
    'BPNN',                'results2_bpnn_seeds.mat';
    'GRNN',                'results2_grnn_seeds.mat';
    'ABC-FFNN',            'results2_abc_seeds.mat'
};

% =========================
% Build summaries
% =========================
T1 = buildMetricSummary(filesD1, 'Dataset 1 (PIMA)');
T2 = buildMetricSummary(filesD2, 'Dataset 2 (Early-Stage Risk)');

% =========================
% Display
% =========================
disp(' ');
disp('==============================================================');
disp('FINAL EXACT SENSITIVITY / SPECIFICITY / F1 SUMMARY - DATASET 1');
disp('==============================================================');
disp(T1);

disp(' ');
disp('==============================================================');
disp('FINAL EXACT SENSITIVITY / SPECIFICITY / F1 SUMMARY - DATASET 2');
disp('==============================================================');
disp(T2);

% =========================
% Save
% =========================
writetable(T1, 'Summary_Sens_Spec_F1_Dataset1.csv');
writetable(T2, 'Summary_Sens_Spec_F1_Dataset2.csv');

save('Summary_Sens_Spec_F1_Dataset1.mat', 'T1');
save('Summary_Sens_Spec_F1_Dataset2.mat', 'T2');

fprintf('\nSaved files:\n');
fprintf(' - Summary_Sens_Spec_F1_Dataset1.csv\n');
fprintf(' - Summary_Sens_Spec_F1_Dataset2.csv\n');
fprintf(' - Summary_Sens_Spec_F1_Dataset1.mat\n');
fprintf(' - Summary_Sens_Spec_F1_Dataset2.mat\n');

%% =========================================================
% Helper function
% =========================================================
function T = buildMetricSummary(fileMap, datasetLabel)

    n = size(fileMap, 1);

    Model = cell(n,1);

    SensitivityMean = zeros(n,1);
    SensitivitySD   = zeros(n,1);

    SpecificityMean = zeros(n,1);
    SpecificitySD   = zeros(n,1);

    F1Mean = zeros(n,1);
    F1SD   = zeros(n,1);

    SensitivityText = cell(n,1);
    SpecificityText = cell(n,1);
    F1Text          = cell(n,1);

    fprintf('\n%s\n', datasetLabel);
    fprintf('--------------------------------------------------------------\n');

    for i = 1:n
        modelName = fileMap{i,1};
        fileName  = fileMap{i,2};

        assert(isfile(fileName), 'Missing file: %s', fileName);

        S = load(fileName);

        assert(isfield(S,'sens_seed'), 'File %s missing sens_seed', fileName);
        assert(isfield(S,'spec_seed'), 'File %s missing spec_seed', fileName);
        assert(isfield(S,'f1_seed'),   'File %s missing f1_seed', fileName);

        Model{i} = modelName;

        SensitivityMean(i) = mean(S.sens_seed);
        SensitivitySD(i)   = std(S.sens_seed);

        SpecificityMean(i) = mean(S.spec_seed);
        SpecificitySD(i)   = std(S.spec_seed);

        F1Mean(i) = mean(S.f1_seed);
        F1SD(i)   = std(S.f1_seed);

        SensitivityText{i} = sprintf('%.4f ± %.4f', SensitivityMean(i), SensitivitySD(i));
        SpecificityText{i} = sprintf('%.4f ± %.4f', SpecificityMean(i), SpecificitySD(i));
        F1Text{i}          = sprintf('%.4f ± %.4f', F1Mean(i), F1SD(i));

        fprintf('%-22s | Sens = %s | Spec = %s | F1 = %s\n', ...
            modelName, SensitivityText{i}, SpecificityText{i}, F1Text{i});
    end

    % Round numeric columns for cleaner tables
    SensitivityMean = round(SensitivityMean, 4);
    SensitivitySD   = round(SensitivitySD, 4);
    SpecificityMean = round(SpecificityMean, 4);
    SpecificitySD   = round(SpecificitySD, 4);
    F1Mean          = round(F1Mean, 4);
    F1SD            = round(F1SD, 4);

    T = table( ...
        Model, ...
        SensitivityMean, SensitivitySD, SensitivityText, ...
        SpecificityMean, SpecificitySD, SpecificityText, ...
        F1Mean, F1SD, F1Text);
end