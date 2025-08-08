#!/usr/bin/env nextflow

process download_sra {
    tag "Download: $srr_id"

    input:
    val srr_id

    output:
    tuple val(srr_id), path("*_1.fastq"), path("*_2.fastq")

    script:
    """
    prefetch --output-file ${srr_id}.sra $srr_id
    fasterq-dump ${srr_id}.sra --split-files
    """
}
