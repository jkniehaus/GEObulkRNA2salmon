# GEObulkRNA2salmon
This nextflow pipeline downloads bulk PE RNA-seq data from GEO, trims the fastqs for illumina index sequences, and aligns + quantifies the resulting fastq files to two separate reference genomes/annotaitons.  

Custom STAR genomes, transcript .fa files, gene annotation .gtf files, and illumina adapter sequences must be provided as parameters in the 'main.nf' pipeline file.  

This pipeline was created for use on UNC's longleaf HPC. Therefore, this nextflow pipeline uses SLURM as its executor, submitting a job for each process.  

The expected input is a single or list of SRA number(s)  
The expected output is a results directory with a subdirectory for each SRR number.  
Each SRR subdirectory contains salmon quantification files, which can be read into R/python for further analyses (DEG analysis, pathway enrichment etc.)  

Assuming apptainer is installed, the nextflow environment can be created with the following
```bash
apptainer build srrBulkRNAseq_trim_starsalmon.sif srrAlign.def
```
With the custom resource files specified in `main.nf` and nextflow/apptainer installed, the nextflow pipeline can be submitted as its own job using the following:
```bash
sbatch -t 01-00:00:00 --wrap='nextflow -C slurmProfile.config run main.nf -with-apptainer srrBulkRNAseq_trim_starsalmon.sif --srrs "SRR123456"'
```
where SRR123456 is the desired SRA number. Multiple SRR numbers can be submitted as a list.
