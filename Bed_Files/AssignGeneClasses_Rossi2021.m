close all
bedDiv=readtable('Divergent_Gene_Boundaries.bed','FileType','text');
geneClasses=readtable('Rossi_SI1.chr.txt','FileType','text','Delimiter','tab');

for i=1:size(bedDiv,1)
    geneNames=strsplit(bedDiv.name_L_R_{i},'_');
    geneName_L=geneNames{1};
    geneName_R=geneNames{2};

    try
        nameLoc=strcmp(geneName_L,geneClasses.CommonName) | strcmp(geneName_L,geneClasses.SystematicID);
        bedDiv.geneClass_L(i)=geneClasses.FeatureClassLevel1(nameLoc);
    catch
        try
            nameLoc=strcmp(geneName_R,geneClasses.CommonName) | strcmp(geneName_R,geneClasses.SystematicID);
            bedDiv.geneClass_R(i)=geneClasses.FeatureClassLevel1(nameLoc);
        catch
            continue
        end
    end
    try
        nameLoc=strcmp(geneName_R,geneClasses.CommonName) | strcmp(geneName_R,geneClasses.SystematicID);
        bedDiv.geneClass_R(i)=geneClasses.FeatureClassLevel1(nameLoc);
    catch
        continue
    end

end

bedDivClassed=bedDiv(strcmp(bedDiv.geneClass_L,bedDiv.geneClass_R),:);
uniqueClasses=unique(bedDivClassed.geneClass_L);
bedDivClassedCOI=bedDivClassed(strcmp(bedDivClassed.geneClass_L,uniqueClasses{1}) | ...
    strcmp(bedDivClassed.geneClass_L,uniqueClasses{2}) | ...
    strcmp(bedDivClassed.geneClass_L,uniqueClasses{3}) | ...
    strcmp(bedDivClassed.geneClass_L,uniqueClasses{4}),:);
writetable(bedDivClassedCOI,'Divergent_Gene_Boundaries_RossiClasses1.bed','FileType','text','Delimiter','tab');


