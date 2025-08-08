#!/usr/bin/env nextflow

process altalignQuant {
    cpus 16
    memory '32 GB'
    time '12h'

    tag "STAR align: ${srr_id}alt"
    input:
    tuple val(srr_id), path(read1), path(read2)
    path(gen)
    path(tran)
    path(gtf)

    output:
    tuple val(srr_id), path("${srr_id}alt/${srr_id}altTranscriptomeAligned.toTranscriptome.out.bam"), path("${srr_id}alt/salmon_quant")
    publishDir "${params.outdir}/${srr_id}alt", mode: 'copy'
    script:
    """
    mkdir ${srr_id}alt
    STAR --quantMode TranscriptomeSAM --runThreadN 16 \
        --genomeDir ${gen.getName()} \
        --readFilesIn ${read1} ${read2} \
        --outSAMtype BAM Unsorted \
        --outFileNamePrefix ./${srr_id}alt/${srr_id}altTranscriptome \
        --outTmpDir ${srr_id}altTranscriptome_tmp \
        --outFilterScoreMinOverLread 0.3 \
        --outFilterMatchNminOverLread 0.3

    samtools fixmate -@ 16 -m ./${srr_id}alt/${srr_id}altTranscriptomeAligned.toTranscriptome.out.bam ./${srr_id}alt/tmpfixdMate.bam
    samtools sort -@ 16 -o ./${srr_id}alt/tmpsorted.bam ./${srr_id}alt/tmpfixdMate.bam
    samtools markdup -@ 16 -r ./${srr_id}alt/tmpsorted.bam ./${srr_id}alt/tmpdeduped.bam
    samtools collate -@ 16 -o ./${srr_id}alt/${srr_id}altTranscriptomeAligned.toTranscriptome.out.bam ./${srr_id}alt/tmpdeduped.bam
    rm ./${srr_id}alt/tmp*
    salmon quant \
        -t ${tran.getName()} \
        -l IU \
        -p 16 \
        -a ./${srr_id}alt/${srr_id}altTranscriptomeAligned.toTranscriptome.out.bam \
        -g ${gtf.getName()} \
        -o ${srr_id}alt/salmon_quant

    """
}
