#!/usr/bin/env nextflow

process trim_reads {
    tag "Trim: $srr_id"

    input:
    tuple val(srr_id), path(read1), path(read2)
    path adapters_file
    output:
    tuple val(srr_id), path("out1P.fastq"), path("out2P.fastq")

    script:
    """
    trimmomatic PE \
      $read1 $read2 \
      out1P.fastq out1U.fastq out2P.fastq out2U.fastq \
      ILLUMINACLIP:${adapters_file.getName()}:2:30:10 \
      LEADING:3 SLIDINGWINDOW:4:15 MINLEN:50
    """
}
