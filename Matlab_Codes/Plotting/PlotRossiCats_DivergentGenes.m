close all




datFile='Cell_Avg_sub_Sphero_DpnII_Avg.matrix.tsv';

Dat=readmatrix(datFile,'FileType','text');

Dat(isinf(Dat))=nan;

x=-1500:10:2000-10;

%relate the bed files and the categorized bed files, assign the gene
%classes to each region
bedName=ls('NCBI_Genes_Expression.Sizes*.bed');
bedExpression=readtable('NCBI_Genes_Divergent_RossiClasses_mRNA.bed','FileType','text');
bedExpression=unique(bedExpression);
bed=readtable('OutBed.Scaled.bed','FileType','text');
for i=1:size(bed,1)

    try
        bed.expression(i)=bedExpression.mRNA_L(strcmp(bed.x_chrom(i),bedExpression.x_chrom) & bed.start(i)==bedExpression.start & bed.xEnd(i)==bedExpression.end1);
        bed.expressionR(i)=bedExpression.mRNA_R(strcmp(bed.x_chrom(i),bedExpression.x_chrom) & bed.start(i)==bedExpression.start & bed.xEnd(i)==bedExpression.end1);
        bed.geneClass_L(i)=bedExpression.geneClass_L(strcmp(bed.x_chrom(i),bedExpression.x_chrom) & bed.start(i)==bedExpression.start & bed.xEnd(i)==bedExpression.end1);
    catch
        continue
    end
end

regionSize=bed.xEnd-bed.start;
[sortvect sortinds]=sortrows(regionSize,'descend');


bedSort=bed(sortinds,:);
regionSize=regionSize(sortinds);



Dat=Dat(sortinds,1:end-1);

filtVect=~cellfun(@isempty,bedSort.geneClass_L);

Dat=Dat(filtVect,:);

bedSort=bedSort(filtVect,:);
regionSize=regionSize(filtVect);
sortvect=sortvect(filtVect);
regionSizeFilt=regionSize>=0 & regionSize<=3000000;

Dat=Dat(regionSizeFilt,:);
bedSort=bedSort(regionSizeFilt,:);
regionSize=regionSize(regionSizeFilt);
sortvect=sortvect(regionSizeFilt);

Datsav=Dat;




figure(1)
imagesc(x,1:length(sortinds),(movmean(movmean(Dat,5,1,'omitnan'),5,2,'omitnan')))
colorbar

colormap(flipud(slanCM('RdYlBu')))
hold on
plot(linspace(0,0,length(sortinds)),1:length(sortinds),'color',[0 0 0],'LineStyle','--')
plot(linspace(1250,1250,length(sortinds)),1:length(sortinds),'color',[0 0 0],'LineStyle','--')
xlabel('Distance From Region Center (bp)')
% ylabel('Gene Pair')
xlim([min(x) max(x)])
% caxis([-.9 1.3])
f=gcf;
f.Position=[554   45.8000  368.8000  420.0000];

catsToUse=unique(bedSort.geneClass_L);

DatBin=[];
DatTESBin=[];

for i=1:length(catsToUse)

    binInds=strcmp(bedSort.geneClass_L,catsToUse{i});
        
    DatBin(i,:)=mean(Dat(binInds,:),'omitnan');
   
    sortVectBin{i}=sortvect(binInds);
    
    sortVectBinMean(i)=mean(sortVectBin{i});


end
figure(3)

newcolors = [1.00 0 0
            0.49,0.18,0.56
             0 0 1
             0.2 0.60 0.2
             0 0 0];
         
colororder(newcolors)

DatBinsav=DatBin;

for i=1:length(catsToUse)
    maxSubBin(i)=max(DatBin(i,:));
    minSubBin(i)=min(DatBin(i,:));
    maxTSSBin(i)=max(DatBin(i,x<50 & x>-200));
    minTESBin(i)=min(DatBin(i,x<1450 & x>1250));
end
plot(x,movmean(DatBin,5,2),'LineWidth', 2)
hold on
line([0 0],[-1 1],'Color',[0 0 0],'LineStyle','--')
line([500 500],[-1 1],'Color',[0 0 0],'LineStyle','--')
xticks([-1500 -500 0 500 1000 2000])
xticklabels({'-1500','-500', 'TSS', 'TSS', '500', '1500'})
ylim([min(minSubBin)-abs(min(minSubBin)/10) max(maxSubBin)+max(maxSubBin)/10])
xlim([-1500 2000])
f3=gcf;
f3.Position=[1054         489         461         244];
% figure(4)
% imagesc(x,1:nquants,SubtractBin)
ylabel('Signal')
xlabel('Position')


legend(catsToUse,'Interpreter','none')
datFilesplit=strsplit(datFile,'.');
writematrix(DatBin,[datFilesplit{1} '.quantilesProfs.tsv'],'FileType','text','Delimiter','tab')



legend(catsToUse,'Interpreter','none')




