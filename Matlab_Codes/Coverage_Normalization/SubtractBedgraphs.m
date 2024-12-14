% Load the bedgraph files
repNames=readcell('BedgraphsToSubtractorDivide.txt','FileType','text','Delimiter','\t');

inTag='';
varNames = {'chr', 'start', 'end1', 'score'};
pseudocount=0;
for fNum=1:size(repNames,1)
    Nreps=length(repNames(fNum,:));
    Cellbed={};
    scores=[];
    for repNum=1:Nreps

        inName=strjoin({repNames{fNum,repNum},inTag,'.bedgraph'},'');

        Cellbed{repNum} = readtable(strjoin({repNames{fNum,repNum},inTag,'.bedgraph'},''), 'FileType', 'text', 'Delimiter', '\t');
        Cellbed{repNum}.Properties.VariableNames = varNames;
        scores(:,repNum)=Cellbed{repNum}.score;


    end
   
    subScore=scores(:,1)-scores(:,2);
  
    OutBedSub=Cellbed{1}
    OutBedSub.score=subScore;
    

    outNameSub=strjoin({repNames{fNum,1},'_sub_',repNames{fNum,2},'.bedgraph'},'');


    writetable(OutBedSub, outNameSub, 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', false);

end
