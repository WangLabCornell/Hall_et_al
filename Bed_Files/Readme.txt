- AllYeastGenes_SGD.bed
List of all yeast genes including verified, dubious, XUT, CUT etc.  This list was used to filter intergenic regions such that no annotations existed between verified ORFs.

- FilterList_pughRoman.bed
Blacklist from Rossi 2021, used with deeptools in order to filter out uninterpretable regions of the yeast genome.
Defined in Rossi et al., Nature 2021.  Obtained from any download folder on yeastepigenome.org, the chromosomes are renamed from alphanumeric to roman format.

- SingleGene_NCBI_Proseq_mRNASeq.bed
List of yeast genes from NCBI where the average Proseq and mRNAseq values across the gene body are listed.
This file was used to create the gene configurations by considering the nearest neighbor genes.  Then regions that had an overlap with AllYeastGenes_SGD.bed in their intergenic regions were removed to ensure minimal transcription interference between the genes of interest.

- Codirectional_Gene_Boundaries.bed
Codirectional genes boundaries after filtering.  The strand information represents the orientation of the pair. (-) means both genes go to the left, (+) means that both genes go to the right.  Deeptools will automatically flip the (-) when plotting.
The name column list the name of each gene from left to right separated by (_) this allows genes to be reidentified later.

The regions between start and end represent the space between the genes.

- Convergent_Gene_Boundaries.bed
- Divergent_Gene_Boundaries.bed

As above, but no strand information is required.  Genes are listed as they appear in their genome coordinates from low to high.

- AssignGeneClasses.m

A matlab script that will assign gene classes defined by Rossi_SI1.chr.txt based on the name of each gene.  It will then filter the classes so that only RP, STM, TFO, and UNB are listed, and it requires that both have the same class.  The output will be a new bed file which has the genes of interest and their classes.


- Divergent_Gene_Boundaries_RossiClasses.bed

Output of matlab script defined above.  To be used with previously plotted heatmaps to subcategorize regions.

- Loops_Optimized.bed

This file contains the nearest neighbor loop boundaries as start and end coordinates.  All hierarchical loops have been removed in order to get rid of redundant boundaries being plotted with 1-dimensional data.  Loops were originally detected using cooltools on MicroCXL Data in G2 arrested cells from Constantino et al, Elife 2020, using a 500 bp bin size.  Scc1-ChIP-seq (Jeppsonn, Science Advances, 2022) was then used to adjust the boundaries to the nearest scc1 peak to increase resolution beyond that of MicroCXL such that the boundary was centered on the cohesion peak rather than the fuzzy dot.  The boundaries were moved by no more than 500 bp on either side of the boundary.