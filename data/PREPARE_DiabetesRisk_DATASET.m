%% PREPARE_DiabetesRisk_DATASET.m
% Prepares the UCI Early Stage Diabetes Risk Prediction Dataset
% Expected input: CSV file downloaded from UCI
%
% Output:
%   prepared_risk.mat containing:
%       X          : numeric predictor matrix
%       y          : binary outcome (0/1)
%       groups     : subject groups (unique IDs here)
%       predictors : predictor names

clear; clc;

% -------------------------------------------------------------------------
% CHANGE THIS FILE NAME TO MATCH YOUR DOWNLOADED UCI CSV
% -------------------------------------------------------------------------
csvFile = 'diabetes_risk_dataset.csv';

assert(isfile(csvFile), 'Dataset file not found: %s', csvFile);

T = readtable(csvFile, 'VariableNamingRule','preserve');
origNames = T.Properties.VariableNames;

% Clean variable names for easier processing
cleanNames = matlab.lang.makeValidName(origNames);
T.Properties.VariableNames = cleanNames;

% Display columns for checking
disp('Detected columns:');
disp(T.Properties.VariableNames');

% -------------------------------------------------------------------------
% Identify target column
% Usually named "class" in the UCI dataset
% -------------------------------------------------------------------------
targetIdx = find(strcmpi(T.Properties.VariableNames, 'class'), 1);

if isempty(targetIdx)
    targetIdx = find(contains(lower(T.Properties.VariableNames), 'class'), 1);
end

if isempty(targetIdx)
    error('Could not identify target column. Please check the dataset column names.');
end

targetName = T.Properties.VariableNames{targetIdx};

% -------------------------------------------------------------------------
% Convert target to binary
% positive -> 1, negative -> 0
% -------------------------------------------------------------------------
yRaw = T.(targetName);

if iscellstr(yRaw) || isstring(yRaw) || iscategorical(yRaw)
    yStr = lower(string(yRaw));
    y = double(yStr == "positive" | yStr == "yes" | yStr == "1");
else
    y = double(yRaw);
end

% Remove target from predictors
T.(targetName) = [];

predictors = T.Properties.VariableNames;
n = height(T);
p = width(T);

X = zeros(n,p);

% -------------------------------------------------------------------------
% Convert predictors to numeric
% Age remains numeric
% Gender: Male/Female -> 1/0
% Symptom variables: Yes/No -> 1/0
% -------------------------------------------------------------------------
for j = 1:p
    col = T.(predictors{j});

    if isnumeric(col)
        X(:,j) = double(col);

    elseif iscellstr(col) || isstring(col) || iscategorical(col)
        s = lower(string(col));

        % yes/no style encoding
        if all(ismember(unique(s), ["yes","no"]))
            X(:,j) = double(s == "yes");

        % male/female encoding
        elseif all(ismember(unique(s), ["male","female"]))
            X(:,j) = double(s == "male");

        % positive/negative encoding if any feature uses that
        elseif all(ismember(unique(s), ["positive","negative"]))
            X(:,j) = double(s == "positive");

        else
            error('Unhandled categorical variable in column: %s', predictors{j});
        end
    else
        error('Unsupported variable type in column: %s', predictors{j});
    end
end

% Unique group per row (no repeated subjects in this dataset)
groups = (1:n)';

fprintf('\nPrepared Early Stage Diabetes Risk dataset:\n');
fprintf('Samples: %d\n', n);
fprintf('Predictors: %d\n', p);
fprintf('Positive cases: %d\n', sum(y==1));
fprintf('Negative cases: %d\n', sum(y==0));

save('prepared_risk.mat', 'X', 'y', 'groups', 'predictors');
disp('Saved: prepared_risk.mat');