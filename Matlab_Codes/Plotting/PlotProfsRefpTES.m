fileName=ls('*.TES.tsv');
%initMat=readmatrix('','FileType','text');
x=-3000:10:1000;
close all
figure
hold on
legNames={};
meanProfs=[];
meanProfs(:,1)=x';
for i=1:size(fileName,1)
    matToPlot=readmatrix(fileName(i,:),'FileType','text');
    matToPlot=matToPlot/mean(matToPlot,'all','omitnan');
    legNamesSplit=strsplit(fileName(i,:),'.');
    if length(legNamesSplit)>4
        legNames{i}=strjoin(legNamesSplit(1:2),'_');
    else
        legNames{i}=legNamesSplit{1};
    end
    plot(x,mean(matToPlot,'omitnan'),'LineWidth',2);
    meanProfs(:,i+1)=mean(matToPlot,'omitnan')';
end
meanProfs(:,1)=x;
legend(legNames, 'Interpreter', 'none')
legend(legNames, 'Interpreter', 'none')
varNames=string({'x',legNames{:}});
outTab=array2table(meanProfs);

outTab.Properties.VariableNames=varNames;
writetable(outTab,'AllAvgProfs_RefpTES.tsv','Delimiter','tab','FileType','text')
xticks([-3000 -2500 -2000 -1500 -1000 -500 0 500 1000])
% xticklabels(['-1000' '-500'  '+500' '+1000' '+1500'])
xticklabels({'-3000' '-2500' '-2000' '-1500' '-1000' '-500' 'TES' '+500' '+1000'})
xlabel('Position')
ylabel('Signal')
xlabel('Position (bp)')