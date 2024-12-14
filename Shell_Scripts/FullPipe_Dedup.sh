#!/bin/bash
#Requirements
#bwa-mem2
#samtools
#picard tools
#make sure that there is enough space on the hard drive to temporarily store the sam files that are created.  Depending on the genome size and number of reads, this may not be feasible and you need to change the script, or pipe directly into BAM (which uses more ram)
#they will be compressed and then moved to a folder that doesn't need to be on the main hard drive of the computer.
#run this code from the directory that the fastq files are in
#it assumes that the fastqfiles are appended with _R1 and _R2 so you only need to list the fastq filenames once.
#if they are appended differently, change the append1 and append 2 lines

#usage
# ./../Scripts/FullPipe_Dedup2.sh ../FastqList.txt ../NameList.txt
#FastqList has the names of the fastqfiles without their file extensions
#Namelist has the names of the final outputs bam files it can be the same as the fastqlist if you want.  
#Normally fastq filenames come with extra appendages that are inconvenient to keep.

#change these lines if the fastq files are not named this way
append1="_R1.fastq.gz"
append2="_R2.fastq.gz"

#destination folders for temporary computations and the final bam alignments

mkdir ~/TempDat
mkdir ../BamAlignments

declare -a fastqlist

exec 10<&0

exec < $1
count=1
while read LINE; do 
	fastqlist[$count]=$LINE
	echo ${fastqlist[$count]}
	((count++))
done



declare -a namelist


declare -a samplenamelist
exec 10<&0

exec < $2
count=1
while read LINE; do 
	samplenamelist[$count]=$LINE
	echo ${samplenamelist[$count]}
	((count++))

	
done

echo $samplenamelist
count=1
for i in ${fastqlist[@]}; do
	r1=$i$append1
	r2=$i$append2
	outbase=${samplenamelist[$count]}
	echo $outbase

	#main alignment 
    bwa-mem2 mem -t 12 ../../../Genome_3/Mem2IndexRoman/GCF_000146045.2_R64_genomic.fna $r1 $r2 > ~/TempDat/$outbase.sam

    # turns sam to bam
	samtools view -@12 -b ~/TempDat/$outbase.sam > ~/TempDat/$outbase.bam
	rm ~/TempDat/$outbase.sam 

    #sorts by chromsome
	samtools sort -@12 -o ~/TempDat/$outbase.csort.bam ~/TempDat/$outbase.bam
	rm ~/TempDat/$outbase.bam
	
    #sorts by name
    samtools sort -@12 -n -o ~/TempDat/$outbase.nsort.bam ~/TempDat/$outbase.csort.bam
	rm ~/TempDat/$outbase.csort.bam
	
    #runs fixmate and markdup
    samtools fixmate -@12 -m ~/TempDat/$outbase.nsort.bam ~/TempDat/$outbase.nsort.fixm.bam
	rm ~/TempDat/$outbase.nsort.bam
	samtools sort -@12 -o ~/TempDat/$outbase.nsort.fixm.csort.bam ~/TempDat/$outbase.nsort.fixm.bam
	rm ~/TempDat/$outbase.nsort.fixm.bam 
	samtools markdup -@12 ~/TempDat/$outbase.nsort.fixm.csort.bam ~/TempDat/$outbase.nsort.fixm.csort.dup.bam
	rm ~/TempDat/$outbase.nsort.fixm.csort.bam 
	
    #marks picard duplicates (does not remove)
    picard MarkDuplicates I=~/TempDat/$outbase.nsort.fixm.csort.dup.bam O=~/TempDat/$outbase.picddup.bam M=~/TempDat/$outbase.picarddupmetrics.txt
	rm ~/TempDat/$outbase.nsort.fixm.csort.dup.bam

	samtools index -@10 -b ~/TempDat/$outbase.picddup.bam
	
    #removes duplicates and makes a deduplicated bam file and .bai index
    samtools view -@10 -F 1024 -o ~/TempDat/$outbase.picddup.dedup.bam ~/TempDat/$outbase.picddup.bam
	samtools index -@10 ~/TempDat/$outbase.picddup.dedup.bam
	
    #saves only the duplicate reads separately
	samtools view -@10 -f 1024 -o ~/TempDat/$outbase.picddup.dups.bam ~/TempDat/$outbase.picddup.bam
	samtools index -@10 ~/TempDat/$outbase.picddup.dups.bam
	
	
	
	rm ~/TempDat/$outbase.picddup.bam
	rm ~/TempDat/$outbase.picddup.bam.bai

	mv ~/TempDat/$outbase.picarddupmetrics.txt ../BamAlignments
	mv ~/TempDat/$outbase.picddup.dedup.bam ../BamAlignments
	mv ~/TempDat/$outbase.picddup.dedup.bam.bai ../BamAlignments

	mv ~/TempDat/$outbase.picddup.dups.bam ../BamAlignments
	mv ~/TempDat/$outbase.picddup.dups.bam.bai ../BamAlignments

		
	((count++))
done

