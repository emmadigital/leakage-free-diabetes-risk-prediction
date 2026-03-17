function [y_ref, p_avg] = averageSeedProbabilities(S)
% Align pooled predictions across seeds by subject ID, then average probs.
% If id_all_seed is unavailable, fall back to direct order checking.

assert(isfield(S,'y_all_seed'), 'Missing y_all_seed');
assert(isfield(S,'p_all_seed'), 'Missing p_all_seed');

nSeeds = numel(S.y_all_seed);
assert(nSeeds >= 1, 'No seeds found.');

% Case 1: preferred path with subject IDs
if isfield(S,'id_all_seed')
    id_ref = S.id_all_seed{1}(:);
    y_ref0 = S.y_all_seed{1}(:);
    p_ref0 = S.p_all_seed{1}(:);

    [id_ref_sorted, idx_ref] = sort(id_ref);
    y_ref = y_ref0(idx_ref);

    P = zeros(length(id_ref_sorted), nSeeds);
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

% Case 2: fallback for older files without IDs
else
    y_ref = S.y_all_seed{1}(:);
    P = zeros(length(y_ref), nSeeds);
    P(:,1) = S.p_all_seed{1}(:);

    for s = 2:nSeeds
        ys = S.y_all_seed{s}(:);
        ps = S.p_all_seed{s}(:);

        assert(isequal(ys, y_ref), ...
            'Order of y_all differs across seeds and no id_all_seed is available.');

        P(:,s) = ps;
    end
end

p_avg = mean(P,2);
end