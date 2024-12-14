% Load the bedgraph files

% fileList=readcell('NameList.txt','FileType','text');


% fileList=cell(fileList);
for fNum=1:length(fileList)
    fileList{fNum}
    Cellbed = readtable(strjoin({fileList{fNum} '.bedgraph'},''), 'FileType', 'text', 'Delimiter', '\t');
    % Variable names for consistency
    varNames = {'chr', 'start', 'end1', 'score'};
    Cellbed.Properties.VariableNames = varNames;
    % DpnIIbed.Properties.VariableNames = varNames

    % Initialize a table for corrected bins
    CellbedCorr = table;
    keyboard
    % Get the unique chromosomes
    chrs = unique(Cellbed.chr);

    % Process each chromosome
    for i = 1:length(chrs)
        chrName = chrs{i};

        if strcmp(chrName, 'NC_001224.1')
            continue
        end
        chrs{i}
        % Filter the data by chromosome
        Cellbedchr = Cellbed(strcmp(Cellbed.chr, chrName), :);

        % Initialize a new table to hold corrected bins for this chromosome
        CellbedchrCorr = table;

        % Process each bin and adjust to 10 bp intervals
        for j = 1:height(Cellbedchr)
            startPos = Cellbedchr.start(j);
            endPos = Cellbedchr.end1(j);
            score = Cellbedchr.score(j);

            % Determine the number of 10 bp bins in this range
            binCount = ceil((endPos - startPos) / 10);

            for k = 1:binCount
                newStart = startPos + (k-1) * 10;
                newEnd = min(newStart + 10, endPos);

                % Create a new row with the corrected bin
                newRow = {chrName, newStart, newEnd, score};
                CellbedchrCorr = [CellbedchrCorr; newRow];
            end
        end

        % Append the corrected chromosome data to the final table
        CellbedCorr = [CellbedCorr; CellbedchrCorr];
    end
    CellbedCorr.Properties.VariableNames = varNames;
    CellbedCorr.score=CellbedCorr.score./mean(CellbedCorr.score,'omitnan');
    % Save the corrected BEDGraph
    baseName=strsplit(fileList{fNum},'.');
    outName=strjoin({baseName{1},'.Rebin.Norm.bedgraph'},'');
    writetable(CellbedCorr, outName, 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', false);
end
