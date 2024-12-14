close all




datFile='Cell_Avg_sub_Sphero_DpnII_Avg.matrix.tsv';
Dat=readmatrix(datFile,'FileType','text');



x=-15000:250:25000-250;
bedExpression=readtable('Loops_Optimized_Expression.bed','FileType','text');
bedExpression=unique(bedExpression);
bed=readtable('OutBed.Scaled.bed','FileType','text');
for i=1:size(bed,1)
    bed.expression(i)=bedExpression.name(strcmp(bed.x_chrom(i),bedExpression.x_chrom) & bed.start(i)==bedExpression.start & bed.xEnd(i)==bedExpression.xEnd);
end

regionSize=bed.xEnd-bed.start;


[sortvect sortinds]=sortrows(bed.expression,'descend');


bedSort=bed(sortinds,:);
regionSize=regionSize(sortinds);



Dat=Dat(sortinds,1:end-2);


Dat(isinf(Dat))=nan;
Datsav=Dat;




quantsToUse=[10 90]/100;
binQuants=quantile(sortvect,quantsToUse);

sortVectBinMean=[];
DatBin=[];
for i=1:length(quantsToUse)+1

   
    if i==1
        binInds=sortvect<binQuants(i);
        DatBin(i,:)=mean(Dat(binInds,:),'omitnan');
        
    elseif i==length(quantsToUse)+1
        binInds=sortvect>=binQuants(i-1);
        DatBin(i,:)=mean(Dat(binInds,:),'omitnan');
       
    else
        binInds=sortvect>=binQuants(i-1) & sortvect<binQuants(i);
        DatBin(i,:)=mean(Dat(binInds,:),'omitnan');
     
        ExpressionBin{i}=bedSort.expression(binInds);
      
    end



end
figure

newcolors = [1.00 0 0
            0.49,0.18,0.56
             0 0 1
             0.2 0.60 0.2
             0 0 0];
         
colororder(newcolors)

DatBinsav=DatBin;

for i=1:length(quantsToUse)+1
    maxSubBin(i)=max(DatBin(i,:));
    minSubBin(i)=min(DatBin(i,:));
    maxTSSBin(i)=max(DatBin(i,x<50 & x>-500));
    minTESBin(i)=min(DatBin(i,x<1750 & x>1250));
end
plot(x,movmean(DatBin,1,2),'LineWidth', 2)
hold on
line([0 0],[-1 1],'Color',[0 0 0],'LineStyle','--')
line([10000 10000],[-1 1],'Color',[0 0 0],'LineStyle','--')
xticks([-15000 -5000 0 10000 15000 25000])
xticklabels({'-15000','-5000', 'L', 'R', '5000', '15000'})
ylim([min(minSubBin)-abs(min(minSubBin)/10) max(maxSubBin)+max(maxSubBin)/10])
% xlim([-1500 2750])
f3=gcf;
f3.Position=[1054         489         461         244];
% figure(4)
% imagesc(x,1:nquants,SubtractBin)
ylabel('Signal')
xlabel('Position')


legend({'Bottom 10','10-90','Top10'})
datFilesplit=strsplit(datFile,'.');
writematrix(DatBin,[datFilesplit{1} '.quantilesProfs.tsv'],'FileType','text','Delimiter','tab')

