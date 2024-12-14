#!/bin/bash
# Requires ucsc-bedGraphToBigWig
#Requires a text file with all chromosome sizes to be in the same directory that this is run from, otherwise manually change the path.
#Usage
#./Scripts/BatchBedgraphToBigWig.sh NameList outDir inDir

#Run from main directory of experiment, it looks into the coverage files folder
#Namelist is a text file with the names of the bedgraphs that you want to turn into bigwigs, omit the file extension in the list.
#outDir is the folder that the bigwigs will be put in
#inDir is the folder that the bedgraphs are in.  Normally these are the bedgraphs that I rebinned and renormalize and subtract from eachother using matlab, which are to be converted back to bigwig for plotting using deeptools

#Example (used in manuscript)
# ./Scripts/BatchBedgraphToBigWig.sh NameListMatlabBedgraphs.txt Matlab_Renorm_BW BPMNorm_Deeptools

exec < $1
count=1
while read LINE; do 
	samplenamelist[$count]=$LINE
	((count++))
	
done

#samplenamelist=ls("*.bedgraph")



outDir=$2
inDir=$3
mkdir CoverageFiles
mkdir ./CoverageFiles/$outDir
declare -a samplenamelist
exec 10<&0



count=1

#Settings



for i in ${samplenamelist[@]}; do

	bedGraphToBigWig ./CoverageFiles/$inDir/${samplenamelist[$count]}.bedgraph chrSizeList.txt ./CoverageFiles/$outDir/${samplenamelist[$count]}.bw


	((count++))
done
