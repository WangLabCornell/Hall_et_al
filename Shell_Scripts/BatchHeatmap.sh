#!/bin/bash
#Computes matricies of the desired window and binsize, outputs heatmaps and composite plots as png files, and outputs the matrix values as .TSV for further plotting using other programs such as matlab.
#It computes rescaled matricies and matricies that are unscaled and only relative to the start, end or center of the region.  The windows in the unscaled matricies are predefined, the rescaled matricies have an input parameter that can be changed.
#This is to be run from the main experiment directory as it looks into the BedFiles directory for the regions file, and the CoverageFiles/inDir of your choosing for the bigwig input file

#Usage 
#./Scripts/BatchHeatmap_ScaleOnly.sh NameList outDir inDir rescaleWindow unscaledOutside binSize bedFilePath

#NameList: A text file with the name of the bigwig to be plotted without the file extension
#outDir: The directory within the heatmaps folder that all of the files will be placed.
#inDir: location within the CoverageFiles directory where the bigwigs can be found
#rescaleWindow: The number of basepairs that all regions will be scaled to for the rescaled plots
#unscaledOutside:  The number of basepairs outside of the scaled window that will be plotted unscaled
#binSize: the desired binSize
#bedFilePath: the path and name of the bed file containing genome coordinates.

#Example usage (used in manuscript)

#./Scripts/BatchHeatmap.sh NameList.txt OneGene BPMNorm_Deeptools 1250 1500 10 BedFiles/SingleGene_NCBI_Proseq_mRNASeq.bed
#./Scripts/BatchHeatmap.sh NameList.txt Divergent 500 1500 10 BedFiles/Divergent_Gene_Boundaries.bed
#./Scripts/BatchHeatmap.sh NameList.txt Convergent BPMNorm_Deeptools 500 1500 10 BedFiles/Convergent_Gene_Boundaries.bed
#./Scripts/BatchHeatmap.sh NameList.txt Codirectional BPMNorm_Deeptools 500 1500 10 BedFiles/Codirectional_Gene_Boundaries.bed
#./Scripts/BatchHeatmap.sh NameList.txt Loops BPMNorm_Deeptools 10000 15000 250 BedFiles/Loops_Optimized.bed





exec 10<&0

exec < $1

while read LINE; do 
	bamlist[$count]=$LINE
	((count++))
done

outTag=$2
inTag=$3
msize=$4
wind=$5
plotBS=$6
pathtobed1=$7



destfold=Heatmaps/Interval$wind/$outTag.$plotBS
mkdir Heatmaps
mkdir Heatmaps/Interval$wind/
mkdir $destfold


count=1

cp $pathtobed1 $destfold

for i in ${bamlist[@]}; do


	computeMatrix scale-regions -bl BedFiles/FilterList_pughRoman.bed -m $msize -bs $plotBS -S ./CoverageFiles/$inTag/$i.bw -R $pathtobed1 --outFileName ~/TempDat/$i$wind.scaled.gz -p 14 -a $wind -b $wind --outFileNameMatrix ~/TempDat/$i.matrix.tsv --sortUsing region_length --outFileSortedRegions $destfold/OutBed.Scaled.bed
	mv ~/TempDat/$i$wind.scaled.gz $destfold
	mv ~/TempDat/$i.matrix.tsv $destfold


	
	plotHeatmap --heatmapWidth 10 --averageType mean --xAxisLabel "$heatnamebase" --plotType se -m $destfold/$i$wind.scaled.gz -o $destfold/$i.scaled.heatmap.png --colorMap Greys --sortUsing region_length

	rm $destfold/$i$wind.scaled.gz

	computeMatrix reference-point -bl BedFiles/FilterList_pughRoman.bed -bs $plotBS --referencePoint TSS -S ./CoverageFiles/$inTag/$i.bw -R $pathtobed1 --outFileName ~/TempDat/$i.refp.TSS.gz -p 14 -a 3000 -b 1000 --outFileNameMatrix ~/TempDat/$i.Refp.TSS.tsv --sortUsing region_length --outFileSortedRegions $destfold/OutBed.Refp.TSS.bed
	
	mv ~/TempDat/$i.refp.TSS.gz $destfold
	mv ~/TempDat/$i.Refp.TSS.tsv $destfold

	plotHeatmap --heatmapWidth 10 --sortUsing region_length --averageType mean --plotType se -m $destfold/$i.refp.TSS.gz -o $destfold/$i.Refp.TSS.heatmap.png  --colorMap Greys
	
	rm $destfold/$i.refp.TSS.gz

	computeMatrix reference-point -bl BedFiles/FilterList_pughRoman.bed -bs $plotBS --referencePoint TES -S ./CoverageFiles/$inTag/$i.bw -R $pathtobed1 --outFileName ~/TempDat/$i.refp.TES.gz -p 14 -a 1000 -b 3000 --outFileNameMatrix ~/TempDat/$i.Refp.TES.tsv --sortUsing region_length --outFileSortedRegions $destfold/OutBed.Refp.TES.bed

	mv ~/TempDat/$i.refp.TES.gz $destfold
	mv ~/TempDat/$i.Refp.TES.tsv $destfold

	plotHeatmap --heatmapWidth 10 --sortUsing region_length --averageType mean --plotType se -m $destfold/$i.refp.TES.gz -o $destfold/$i.Refp.TES.heatmap.png  --colorMap Greys

	rm $destfold/$i.refp.TES.gz

	computeMatrix reference-point --sortUsing region_length -bl BedFiles/FilterList_pughRoman.bed -bs $plotBS --referencePoint center -S ./CoverageFiles/$inTag/$i.bw -R $pathtobed1 --outFileName ~/TempDat/$i.refp.center.gz -p 14 -a 3000 -b 3000 --outFileNameMatrix ~/TempDat/$i.Refp.center.tsv --outFileSortedRegions $destfold/OutBed.Refp.center.bed

	mv ~/TempDat/$i.refp.center.gz $destfold
	mv ~/TempDat/$i.Refp.center.tsv $destfold

	plotHeatmap --heatmapWidth 10 --sortUsing region_length --averageType mean --plotType se -m $destfold/$i.refp.center.gz -o $destfold/$i.Refp.center.heatmap.png  --colorMap Greys

	rm $destfold/$i.refp.center.gz


	bedtools intersect -header -wa -a $pathtobed1 -b $destfold/OutBed.Scaled.bed > $destfold/OutBed.Scaled.Intersect.bed
	bedtools intersect -header -wa -a $pathtobed1 -b $destfold/OutBed.Refp.TSS.bed > $destfold/OutBed.Refp.TSS.Intersect.bed
	bedtools intersect -header -wa -a $pathtobed1 -b $destfold/OutBed.Refp.TES.bed > $destfold/OutBed.Refp.TES.Intersect.bed
	bedtools intersect -header -wa -a $pathtobed1 -b $destfold/OutBed.Refp.center.bed > $destfold/OutBed.Refp.center.Intersect.bed

	((count++))
done

