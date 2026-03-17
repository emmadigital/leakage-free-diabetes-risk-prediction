% Model names
models = {'LogReg','RF','FFNN','BPNN','GRNN','ABC-FFNN'};

% Example p-value matrix from DeLong tests (Dataset 2)
% Rows vs Columns (symmetric matrix)
P = [
    1      0.0038 0.0820 0.0788 0.00001 0.00033;
    0.0038 1      0.3156 0.4392 0.0035  0.1733;
    0.0820 0.3156 1      0.8259 0.0015  0.0310;
    0.0788 0.4392 0.8259 1      0.8259  0.0625;
    0.00001 0.0035 0.0015 0.8259 1      0.0152;
    0.00033 0.1733 0.0310 0.0625 0.0152 1
];

figure('Color','white','Position',[200 200 600 500])

imagesc(P)
colormap(flipud(parula))
colorbar
caxis([0 0.1]) % emphasize significance threshold

xticks(1:length(models))
yticks(1:length(models))

xticklabels(models)
yticklabels(models)

title('Statistical Significance Matrix (DeLong Test p-values)')
xlabel('Model')
ylabel('Model')

% Add p-values on the heatmap
for i = 1:length(models)
    for j = 1:length(models)
        text(j,i,sprintf('%.3f',P(i,j)), ...
            'HorizontalAlignment','center','FontSize',10)
    end
end

grid on
