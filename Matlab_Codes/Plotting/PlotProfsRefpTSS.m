fileName=ls('*.TSS.tsv');
%initMat=readmatrix('','FileType','text');
x=-1000:10:3000;
% close all
figure
hold on
legNames={};
for i=1:size(fileName,1)
    matToPlot=readmatrix(fileName(i,:),'FileType','text');
    legNamesSplit=strsplit(fileName(i,:),'.');

    if length(legNamesSplit)>4
        legNames{i}=strjoin(legNamesSplit(1:2),'_');
    else
        legNames{i}=legNamesSplit{1};
    end
    plot(x,mean(matToPlot,'omitnan'),'LineWidth',2);
    meanProfs(:,i+1)=mean(matToPlot,'omitnan')';
end
legend(legNames, 'Interpreter', 'none')
legend(legNames, 'Interpreter', 'none')
varNames=string({'x',legNames{:}});
meanProfs(:,1)=x;
outTab=array2table(meanProfs);

outTab.Properties.VariableNames=varNames;
writetable(outTab,'AllAvgProfs_RefpTSS.tsv','Delimiter','tab','FileType','text')

xticks([-1000 -500 0 500 1000 1500 2000 2500 3000])
% xticklabels(['-1000' '-500'  '+500' '+1000' '+1500'])
xticklabels({'-1000' '-500' 'TSS' '+500' '+1000' '+1500' '+2000' '+2500' '+3000'})
xlabel('Position')
ylabel('Signal')
xlabel('Position (bp)')