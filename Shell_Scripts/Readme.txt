Further descriptions and usage guidelines are contained inside each script.


- FullPipe_Dedup.sh

The location of the genome is hardcoded in and is the SacCer3 genome indexed using bwa-mem2 index 

Used to create bam alignments from fastq files. It outputs 4 files per fastq file
1. bam file with duplicates marked by picard and samtools removed
2. bai index of above
3. bam file containing only the duplicates
4. bai index of above

- BatchBamCov_5pEnd.sh

Creates bigwig and bedgraphs from a bam files using deeptools.

- BatchHeatmap.sh

Makes heatmaps and TSV files of values using deeptools and a bed file containing genomic coordinates as described in the script

- BatchBedgraphToBigWig.sh

Converts bedgraphs to bigwigs


- RenameChromosomes_NC_RomanBAM.sh

Renames chromosomes in a BAM file from alpha numeric to roman numerals i.e chr5 --> chrV for the 16 chromosomes in the sCer genome.

