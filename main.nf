#!/usr/bin/env nextflow

params.adapters = '/proj/gs25/users/Jesse/references/IlluminaAdapters.fa' // RNA-seq adapters for trimmomatic
params.genome = '/proj/gs25/users/Jesse/references/mm39_starsoloFiltered_2711a/' // path to STAR reference genome
params.gtf = '/proj/gs25/users/Jesse/references/annotations/Mus_musculus.GRCm39.106.ensembl.filtered.gtf' // path to gtf annotation file (salmon)
params.trans = '/proj/gs25/users/Jesse/references/fasta/mm39.106.ensemblfilteredTranscripts_unversioned.fa' // path to RNA transcript fasta (salmon)
params.genomealt = '/proj/gs25/users/Jesse/references/mm39_starsolo_MOR1extUTR/' // path to STAR alternative alignment reference genome
params.gtfalt = '/proj/gs25/users/Jesse/references/annotations/mm39.ensembl.MOR1extUTR.062223.gtf' // path to alternative gtf annotation file
params.transalt = '/proj/gs25/users/Jesse/references/fasta/mm39_extUTRunversioned.fa' // path to alternative RNA transcript fasta
params.outdir = 'results/quant'

include { download_sra } from './modules/dlsra.nf'
include { trim_reads } from './modules/trimreads.nf'
include { alignQuant } from './modules/normAlign.nf'
include { altalignQuant } from './modules/altAlign.nf'
workflow {
    srr_list = params.srrs instanceof String ? params.srrs.split(',') : params.srrs
    read_ch = Channel.from(srr_list)
    genome_ch = Channel.value(file(params.genome))
    transcriptome_ch = Channel.value(file(params.trans))
    gtf_ch = Channel.value(file(params.gtf))
    genomealt_ch = Channel.value(file(params.genomealt))
    transcriptomealt_ch = Channel.value(file(params.transalt))
    gtfalt_ch = Channel.value(file(params.gtfalt))

    downloaded_ch = download_sra(read_ch)

    adapters_ch = Channel.value(file(params.adapters))

    trimmed_ch = trim_reads(downloaded_ch,adapters_ch)

    normalign_ch = alignQuant(trimmed_ch, genome_ch, transcriptome_ch, gtf_ch)
    altalign_ch = altalignQuant(trimmed_ch, genomealt_ch, transcriptomealt_ch, gtfalt_ch)
}
