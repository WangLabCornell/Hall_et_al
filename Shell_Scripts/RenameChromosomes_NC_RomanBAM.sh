#!/bin/bash
#To rename chromsomes in a bam file from Numeric to roman numerals.  
#Some programs cannot handle different naming schemes, so I renamed all chromosomes to roman when they were alpha numeric using this script.
#Requires samtools
#Run from directory above the bamfiles folder.

#Usage
./Scripts/RenameChromosomes_NC_RomanBAM.sh NameList

#NameList: List of bam file names.

#Makes a tempdat directory in your home directory so that you can
mkdir ~/TempDat

declare -a samplenamelist
exec 10<&0

exec < $1
count=1
while read LINE; do 
	samplenamelist[$count]=$LINE
	((count++))
	
done

count=1

for i in ${samplenamelist[@]}; do
samtools view -@10 -H ./BamAlignments/$i.bam |\
   sed -e 's/SN:chr10/SN:chrX/' | \
   sed -e 's/SN:chr11/SN:chrXI/' | sed -e 's/SN:chr12/SN:chrXII/' | \
   sed -e 's/SN:chr13/SN:chrXIII/' | sed -e 's/SN:chr14/SN:chrXIV/' | \
   sed -e 's/SN:chr15/SN:chrXV/' | sed -e 's/SN:chr16/SN:chrXVI/' |  \
   sed -e 's/SN:chr1/SN:chrI/' | sed -e 's/SN:chr2/SN:chrII/' | \
   sed -e 's/SN:chr3/SN:chrIII/' | sed -e 's/SN:chr4/SN:chrIV/' | \
   sed -e 's/SN:chr5/SN:chrV/' | sed -e 's/SN:chr6/SN:chrVI/' | \
   sed -e 's/SN:chr7/SN:chrVII/' | sed -e 's/SN:chr8/SN:chrVIII/' | \
   sed -e 's/SN:chr9/SN:chrIX/' |  \
  samtools reheader - ./BamAlignments/$i.bam > ~/TempDat/$i.chr.bam
   mv ~/TempDat/$i.chr.bam ./BamAlignments
	samtools index -@10 -b ./BamAlignments/$i.chr.bam
done
