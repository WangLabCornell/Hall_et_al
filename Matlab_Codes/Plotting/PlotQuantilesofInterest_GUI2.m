% Close all existing figures
close all

% UI to choose the data file you want to plot
datFile = uigetfile('*.matrix.tsv'); % Prompt user to select a .tsv file
Dat = readmatrix(datFile, 'FileType', 'text'); % Read the data from file
Dat(isinf(Dat)) = nan; % Replace infinite values with NaN
x = -1500:10:2750-10; % Define the x-axis range for plotting

% Import bed file data from deeptools and additional bed file for sorting
bedExpression = readtable('SingleGene_NCBI_Proseq_mRNASeq.bed', 'FileType', 'text'); % Load bed file with expression data
bedExpression = unique(bedExpression); % Remove duplicate entries
bed = readtable('OutBed.Scaled.bed', 'FileType', 'text'); % Load bed file for gene regions
for i = 1:size(bed, 1)
    % Match bedExpression values to bed file based on chromosome, start, and end positions
    bed.expression(i) = bedExpression.expression(strcmp(bed.x_chrom(i), bedExpression.x_chrom) & bed.start(i) == bedExpression.start & bed.xEnd(i) == bedExpression.xEnd);
    bed.mRNA(i) = bedExpression.mRNAmean(strcmp(bed.x_chrom(i), bedExpression.x_chrom) & bed.start(i) == bedExpression.start & bed.xEnd(i) == bedExpression.xEnd);
end

% Choose quantiles to use
nquants = 8; % Number of quantiles
quantsToUse = [20 80] / 100; % Define specific quantiles (20% and 80%)

% Calculate the region size for each gene
regionSize = bed.xEnd - bed.start;

% UI to choose the sorting parameter
dialogTitle = 'Choose sorting parameter';
options = {'Pro Seq', 'mRNA Expression', 'Gene Size'}; % Sorting options
dialogMessage = 'Please select one of the options below:';

% Show the list dialog box and capture the user's choice
[selectedIndex, isOk] = listdlg('PromptString', dialogMessage, ...
                                'SelectionMode', 'single', ...
                                'ListString', options, ...
                                'Name', dialogTitle);

% Sort based on user's selection
if isOk
    % Use a switch statement to execute sorting based on the selected option
    switch selectedIndex
        case 1
            disp('Sorting by Proseq Level');
            [sortvect, sortinds] = sortrows(bed.expression, 'descend'); % Sort by Proseq Level

        case 2
            disp('Sorting by mRNA Level');
            [sortvect, sortinds] = sortrows(bed.mRNA, 'descend'); % Sort by mRNA Level

        case 3
            disp('Sorting by Gene Size');
            [sortvect, sortinds] = sortrows(regionSize, 'descend'); % Sort by Gene Size

        otherwise
            disp('Unexpected option selected');
    end
else
    disp('User canceled the operation.');
end

% Sort bed and other data matrices based on selected sorting order
bedSort = bed(sortinds, :);
regionSize = regionSize(sortinds);
Dat = Dat(sortinds, 1:end-1);

% Calculate mean signals in different gene regions (TSS, TES, etc.)
meaninGene = mean(Dat(:, x > 0 & x < 1250), 2, 'omitnan');
meanTSS = mean(Dat(:, x > -60 & x < 40), 2, 'omitnan');
meanTES = mean(Dat(:, x > 1320 & x < 1400), 2, 'omitnan');

% Save a copy of the sorted data
Datsav = Dat;

% Identify max/min values upstream and downstream for each gene
maxUpstream = [];
minDownstream = [];
for i = 1:length(sortvect)
    [maxUpstream(i), maxUpstreamInd(i)] = max(Dat(i, x < 0 & x > -200));
    [minDownstream(i), minDownstreamInd(i)] = min(Dat(i, x > 1250 & x < 1400));
end

% Plot the heatmap of sorted data
figure(1)
imagesc(x, 1:length(sortinds), movmean(movmean(Dat, 5, 1, 'omitnan'), 5, 2, 'omitnan'))
colorbar
colormap(flipud(slanCM('RdYlBu')))
hold on
plot(linspace(0, 0, length(sortinds)), 1:length(sortinds), 'color', [0 0 0], 'LineStyle', '--')
plot(linspace(1250, 1250, length(sortinds)), 1:length(sortinds), 'color', [0 0 0], 'LineStyle', '--')
xlabel('Distance From Region Center (bp)')
xlim([min(x) max(x)])
caxis([-mean(abs(Dat), 'all', 'omitnan') - 0.5*std(abs(Dat), 1, 'all', 'omitnan'), mean(abs(Dat), 'all', 'omitnan') + 0.5*std(abs(Dat), 1, 'all', 'omitnan')])
f = gcf;
f.Position = [554, 45.8, 368.8, 420];

% Calculate quantiles for sorting parameter and create bins
binQuants = quantile(sortvect, quantsToUse);
DatBin = [];
maxTSSBin = [];
minTESBin = [];
expressionBinMean = [];
sortVectBin = {};
sortVectBinMean = [];

for i = 1:length(quantsToUse)+1
    % Define indices for each quantile bin
    if i == 1
        binInds = sortvect < binQuants(i);
    elseif i == length(quantsToUse) + 1
        binInds = sortvect >= binQuants(i-1);
    else
        binInds = sortvect >= binQuants(i-1) & sortvect < binQuants(i);
    end
    
    % Calculate mean values for each bin
    DatBin(i, :) = mean(Dat(binInds, :), 'omitnan');
    ExpressionBin{i} = bedSort.expression(binInds) .* regionSize(binInds);
    sortVectBin{i} = sortvect(binInds);
    sortVectBinMean(i) = mean(sortVectBin{i});
end


DatBinsav=DatBin;

for i=1:length(quantsToUse)+1
    maxSubBin(i)=max(DatBin(i,:));
    minSubBin(i)=min(DatBin(i,:));
    maxTSSBin(i)=max(DatBin(i,x<50 & x>-200));
    minTESBin(i)=min(DatBin(i,x<1450 & x>1250));
    meanTSSBin(i)=mean(DatBin(i,x>-1000 & x<0))
    meanTESBin(i)=mean(DatBin(i,x<2250 & x>1250))
end

% Plot the quantiles
figure(3)
newcolors = [0 0 1; 0 .7 0; 1 0 0; 0.2 0.60 0.2; 0 0 0];
colororder(newcolors)
plot(x, movmean(DatBin, 5, 2), 'LineWidth', 2)
hold on
line([0 0], [-1 1], 'Color', [0 0 0], 'LineStyle', '--')
line([1250 1250], [-1 1], 'Color', [0 0 0], 'LineStyle', '--')
xticks([-1500 -500 0 1250 1250+500 1250+1500])
xticklabels({'-1500','-500', 'TSS', 'TES', '500', '1500'})
ylim([min(min(DatBin)) - abs(min(min(DatBin)) / 10), max(max(DatBin)) + max(max(DatBin)) / 10])
xlim([-1500 2750])
ylabel('Signal')
xlabel('Position')
legend({'Bottom 20', '20-80', 'Top 20'})

% Write the quantile profiles to file
datFilesplit = strsplit(datFile, '.');
writematrix(DatBin, [datFilesplit{1} '.quantilesProfs.tsv'], 'FileType', 'text', 'Delimiter', 'tab')

% Plot max/min values in boundary vicinity vs average sorting parameter
figure(5)
hold on
scatter(log2(sortVectBinMean), maxTSSBin, 'MarkerEdgeColor', 'blue');
scatter(log2(sortVectBinMean), minTESBin, 'MarkerEdgeColor', 'red');
title('Max or min in Boundary vicinity vs Average of the sorting parameter')
legend({'Max near TSS', 'Min near TES'})

% Plot mean values in boundary vicinity vs average sorting parameter
figure(6)
hold on
scatter(sortVectBinMean, meanTSSBin, 'MarkerEdgeColor', 'blue');
scatter(sortVectBinMean, meanTESBin, 'MarkerEdgeColor', 'red');
title('Mean in Boundary vicinity vs Average of the sorting parameter')
legend({'Mean near TSS', 'Mean near TES'})