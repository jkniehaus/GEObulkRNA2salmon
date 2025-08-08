# GEObulkRNA2salmon
nextflow pipeline to download bulk RNA-seq data from GEO, trim, align, and quantify with salmon output using two different reference genomes/gene annotations.   
Input is a list of SRR numbers  
Output is a results directory with a subdirectory for each SRR number.  
Each SRR subdirectory contains salmon output counts, which can be read into R/python for further analyses (DEG analysis, pathway enrichment etc.)
