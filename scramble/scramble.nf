#!/usr/bin/env nextflow
/**
    SCRAMble processes
**/


process IdentifyClusters {
    time '1h'
    memory '16 GB'
    cpus 1

    publishDir "$params.output/scramble", mode: 'copy'

    input:
        tuple val(sampleID), path(bamFile), path(baiFile)
    output:
        tuple val(sampleID), path("${sampleID}_clusters.txt")

    script:
        """
        ${CMD_SCRAMBLE} cluster_identifier ${bamFile} > ${sampleID}_clusters.txt
        """
}

process SCRAMble {
    time '2h'
    memory '16 GB'
    cpus 1

    publishDir "$params.output/scramble", mode: 'copy'

    input:
        tuple val(sampleID), path(clusterFile)
    output:
        path "${sampleID}_scramble.vcf"

    script:
        """
        ls -lh ${clusterFile}
        ${CMD_SCRAMBLE} Rscript --vanilla ${params.scramble.scramble_script} \
            --out-name \$PWD/${sampleID}_scramble \
            --cluster-file \$PWD/${clusterFile} \
            --install-dir ${params.scramble.cluster_analysis_bin} \
            --mei-refs ${params.scramble.mei_ref} \
            --ref ${params.reference_genome} \
            --eval-meis
        """
}