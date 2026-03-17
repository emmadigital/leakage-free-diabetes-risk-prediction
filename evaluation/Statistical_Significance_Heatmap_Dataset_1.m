% Model names
models = {'LogReg','RF','FFNN','BPNN','GRNN','ABC-FFNN'};

% Example p-value matrix from DeLong tests (Dataset 1)
% Replace with your exact computed values if needed
P = [
    1      0.213  0.017  0.015  0.038  0.0001;
    0.213  1      0.021  0.019  0.029  0.0001;
    0.017  0.021  1      0.734  0.0001 0.0001;
    0.015  0.019  0.734  1      0.0001 0.0001;
    0.038  0.029  0.0001 0.0001 1      0.0001;
    0.0001 0.0001 0.0001 0.0001 0.0001 1
];

figure('Color','white','Position',[200 200 600 500])

imagesc(P)
colormap(flipud(parula))
colorbar
caxis([0 0.1])

xticks(1:length(models))
yticks(1:length(models))

xticklabels(models)
yticklabels(models)

title('Statistical Significance Matrix (DeLong Test p-values) – Dataset 1')
xlabel('Model')
ylabel('Model')

% Add p-values on the heatmap
for i = 1:length(models)
    for j = 1:length(models)
        text(j,i,sprintf('%.3f',P(i,j)), ...
            'HorizontalAlignment','center', ...
            'FontSize',10,'Color','black')
    end
end

grid on
