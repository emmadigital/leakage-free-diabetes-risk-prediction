function [y_cat, pA_cat, pB_cat, predA_cat, predB_cat] = getPairedPredictionsAcrossSeeds(A, B)
% Concatenate paired predictions across seeds for two models
% Assumes the same seed index uses the same fold generation logic in both models

nS = min(numel(A.y_all_seed), numel(B.y_all_seed));

y_cat = [];
pA_cat = [];
pB_cat = [];
predA_cat = [];
predB_cat = [];

for s = 1:nS
    yA = A.y_all_seed{s}(:);
    yB = B.y_all_seed{s}(:);

    assert(isequal(yA, yB), ...
        'Within seed %d, y_all order differs between models.', s);

    pA = A.p_all_seed{s}(:);
    pB = B.p_all_seed{s}(:);

    predA = double(pA >= 0.5);
    predB = double(pB >= 0.5);

    y_cat     = [y_cat; yA];
    pA_cat    = [pA_cat; pA];
    pB_cat    = [pB_cat; pB];
    predA_cat = [predA_cat; predA];
    predB_cat = [predB_cat; predB];
end
end