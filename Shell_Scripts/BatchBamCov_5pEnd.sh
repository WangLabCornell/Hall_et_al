#!/bin/bash

#Usage
#requirements Deeptools 2.0 or greater
# Run from main directory of experiment input all parameters listed below.  binSize is an integer as is smoothLength.
#This will report the coverage of 5' ends of read 1 only if you want to change that, change the samFlagInclude line to include the SAM flags that you want.
#It will output both bigwig and bedgraph files.  If you only want one or the other, comment the appropriate lines out.

#./Scripts/BatchBamCov_5pEnd.sh NameList bamtag outdirectoryname binSize smoothLength

#NameList: a text file separated by line breaks that lists the base names of the bam files that you want to calculate the coverage of.
#bamtag: a string input that says the extension of the bamfiles.  If you used the pipeline script to make the bam files, it will be picddup.dedup otherwise it can be anything else, or left blank
#outdirectoryname: name of the output directory which will be in a subdirectory of CoverageFiles
#binSize: the desired binsize
#smoothLength: the desired smoothlengs

#Example (used in manuscript)

# ./Scripts/BatchBamCov_5pEnd.sh NameList.txt picddup.dedup BPMNorm_Deeptools 10 100

exec < $1
count=1
while read LINE; do 
	samplenamelist[$count]=$LINE
	((count++))
	
done

bamtag=$2

outDir=$3

binSize=$4

smoothLength=$5

mkdir CoverageFiles
mkdir ./CoverageFiles/$outDir
declare -a samplenamelist
exec 10<&0



count=1

#Settings

bamCovopts="--Offset 1 --samFlagInclude 64 --normalizeUsing BPM -p 20"

for i in ${samplenamelist[@]}; do

	bamCoverage $bamCovopts --binSize $binSize --smoothLength $smoothLength -b ./BamAlignments/$i.$bamtag.bam -o ~/TempDat/${samplenamelist[$count]}.bw
	mv ~/TempDat/${samplenamelist[$count]}.bw ./CoverageFiles/$outDir

	bamCoverage $bamCovopts --binSize $binSize --smoothLength $smoothLength -b ./BamAlignments/$i.$bamtag.bam -o ~/TempDat/${samplenamelist[$count]}.bedgraph -of bedgraph
	mv ~/TempDat/${samplenamelist[$count]}.bedgraph ./CoverageFiles/$outDir

	((count++))
done
