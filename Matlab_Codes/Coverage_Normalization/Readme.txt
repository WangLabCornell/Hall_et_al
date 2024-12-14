- BinCorrectionAndRenormalization.m
Takes a bedgraph file that was made using deeptools and rebins the data, making sure that every 10bp window is represented, even if there are values of 0 or the adjacent bins are equivalent.  It then normalizes the data to the mean across the genome and outputs a new bedgraph file that can be used for further processing.  To use this code, you need a list of names of the bedgraph files without their file extensions.  The new bedgraph files will have an extension called .Rebin.Norm.

- AvgReplicateBedgraphs.m
Takes a tab separated list of bedgraph names imports the bedgraphs and averages them together, outputting a single bedgraph that represents the average of them.
The names should not include the file extension.

- DivideandSubtractBedgraphs.m
Takes a tab separated list of bedgraphs which where the bedgraphs listed in the second column will be subtracted from the bedgraphs listed in the first column.  The output will be a new bedgraph file called Name1_sub_Name2.