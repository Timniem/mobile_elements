#!/usr/bin/env nextflow
/**
    BAM to results .tsv workflow
**/


process IdentifyClusters {
    time '1h'
    memory '16 GB'
    cpus 1

    publishDir "$params.output/scramble", mode: 'copy'

    input:
        tuple val(sampleID), path(bamFile), path(baiFile)
    output:
        tuple val(sampleID), path("${sampleID}.cluster.txt")

    script:
        """
        ${CMD_SCRAMBLE} cluster_identifier ${bamFile} > ${sampleID}.cluster.txt
        """
}

process SCRAMble {
    time '1h'
    memory '16 GB'
    cpus 1

    publishDir "$params.output/scramble", mode: 'copy'

    input:
        tuple val(sampleID), path(clusterFile)
    output:
        path "${sampleID}_scramble_out.tsv"

    script:
        """
        ls -lh ${clusterFile}
        ${CMD_SCRAMBLE} Rscript --vanilla ${params.scramble.scramble_script} \
            --out-name ${sampleID}_scramble_out.tsv \
            --cluster-file \$PWD/${clusterFile} \
            --install-dir ${params.scramble.cluster_analysis_bin} \
            --mei-refs ${params.scramble.mei_ref} \
            --ref ${params.reference_genome} \
            --eval-meis
        """
}