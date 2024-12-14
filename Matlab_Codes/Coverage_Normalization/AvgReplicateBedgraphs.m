% Load the bedgraph files
repNames=readcell('ReplicatesToAvg.txt','FileType','text');
inTag='.Rebin.Norm';
varNames = {'chr', 'start', 'end1', 'score'};
for fNum=1:size(repNames,1)
    Nreps=length(repNames(fNum,:))-1;
    Cellbed={};
    scores=[];
    for repNum=1:Nreps
        if isnan(repNames{fNum,repNum})
%             repNum
            
            break
        end
        inName=strjoin({repNames{fNum,repNum},inTag,'.bedgraph'},'');

        Cellbed{repNum} = readtable(inName, 'FileType', 'text', 'Delimiter', '\t');
        Cellbed{repNum}.Properties.VariableNames = varNames;
        scores(:,repNum)=Cellbed{repNum}.score;
        % Variable names for consistency
        
%         Cellbed{repNum}.Properties.VariableNames = varNames;


    end
    avgScore=sum(scores,2)/size(scores,2);
    OutBed=Cellbed{1};
    OutBed.score=avgScore;
    outName=strjoin({repNames{fNum,end},'.bedgraph'},'');
    writetable(OutBed, outName, 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', false);
end
