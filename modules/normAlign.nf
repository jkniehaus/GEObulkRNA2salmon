#!/usr/bin/env nextflow

process alignQuant {
    cpus 16
    memory '32 GB'
    time '12h'

    tag "STAR align: $srr_id"
    input:
    tuple val(srr_id), path(read1), path(read2)
    path(gen)
    path(tran)
    path(gtf)

    output:
    tuple val(srr_id), path("${srr_id}/${srr_id}TranscriptomeAligned.toTranscriptome.out.bam"), path("${srr_id}/salmon_quant")
    publishDir "${params.outdir}/${srr_id}", mode: 'copy'
    script:
    """
    mkdir $srr_id
    STAR --quantMode TranscriptomeSAM --runThreadN 16 \
        --genomeDir ${gen.getName()} \
        --readFilesIn ${read1} ${read2} \
        --outSAMtype BAM Unsorted \
        --outFileNamePrefix ./${srr_id}/${srr_id}Transcriptome \
        --outTmpDir ${srr_id}Transcriptome_tmp \
        --outFilterScoreMinOverLread 0.3 \
        --outFilterMatchNminOverLread 0.3

    samtools fixmate -@ 16 -m ./${srr_id}/${srr_id}TranscriptomeAligned.toTranscriptome.out.bam ./${srr_id}/tmpfixdMate.bam
    samtools sort -@ 16 -o ./${srr_id}/tmpsorted.bam ./${srr_id}/tmpfixdMate.bam
    samtools markdup -@ 16 -r ./${srr_id}/tmpsorted.bam ./${srr_id}/tmpdeduped.bam
    samtools collate -@ 16 -o ./${srr_id}/${srr_id}TranscriptomeAligned.toTranscriptome.out.bam ./${srr_id}/tmpdeduped.bam
    rm ./${srr_id}/tmp*
    salmon quant \
        -t ${tran.getName()} \
        -l IU \
        -p 16 \
        -a ./${srr_id}/${srr_id}TranscriptomeAligned.toTranscriptome.out.bam \
        -g ${gtf.getName()} \
        -o ${srr_id}/salmon_quant

    """
}
