-PlotQuantilesofInterest_GUI2.m
This program will recreate the plots in figure 2.  It will also write out a text file of the average profiles for the selected data file.
It must be run from the output directory created by "BatchHeatmap.sh" this program was designed for plotting a single gene in this way.
The expression information must be contained in the bed file.  So if you used: SingleGene_NCBI_Proseq_mRNASeq.bed as the bed file for BatchHeatmap.sh, this will automatically be present in the heatmap directory .
Otherwise you must change line 11 to the name of the bed file used.

- PlotRossiCats_DivergentGenes.m
Used to make plots in figure 4b
This program will generate the plots from figure 4b using the torsion data.
It is designed for use with the divergent gene labeled bed file "Divergent_Gene_Boundaries_RossiClasses.bed"
The heatmaps can be originally generated using "Divergent_Gene_Boundaries.bed" or the RossiClasses.bed so long as the proper columns are in place to categorize names.


-PlotProfsRefpTSS.m and PlotProfsRefpTES.m
Used to make plots in Figures 1 and 2.
Will take all matricies generated from BatchHeatmap.sh using any desired bed file and plot them in a single plot.
The figure legend will indicate which sample is which.  It will output a .tsv file containing all of the average profiles.
TSS and TES only refers to the start and end reference point of the bed file used to generate the matricies, so these are not specific to genes.  
However, the xvalues, binsize is all hard coded in based on how BatchHeatmap.sh generates the matricies.


- PlotProfs_GenePairs.m
Used to make plots in figure 3
This can be used with any output from BatchHeatmap.sh, however you have to change the x values if you did not use the parameters used for plotting gene pairs
(binsize=10, rescaleSize=500, unscaledOutside=1500)
It will output a text file containing all of the average profiles.  It automatically does this for all rescaled matrix files within the directory.

-PlotLoopQuantiles.m
Used to make plots in figure 4a
This is a very similar script to PlotQuantilesofInterest_GUI2.m except that its use is hardcoded for plotting loops.
It is designed for outputs of BatchHeatmap.sh using the following inputs:
BedFile = Loops_Optimized.bed
rescaleSize = 10000
unscaledOutside = 15000
binSize = 250

If the heatmap matricies that you want to plot were generated with those parameters, it will extract the loop scores from the BedFile in the directory and use those to make quantiles.
It will save the average profiles into a .tsv file