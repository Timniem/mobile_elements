#!/usr/bin/env nextflow
/**
    Melt processes
**/


process Melt {
    time '1h'
    memory '16 GB'
    cpus 1

    publishDir "$params.output/melt", mode: 'copy'

    input:
        tuple val(sampleID), path(bamFile), path(baiFile)
    output:
        path "${sampleID}.SVA.final_comp.vcf"
        path "${sampleID}.ALU.final_comp.vcf"
        path "${sampleID}.LINE1.final_comp.vcf"

    script:
        """
        ${CMD_MELT} java -Xmx8G -jar ${params.melt.melt_jar} Single \
                    -h ${params.reference_genome} \
                    -bamfile ${bamFile} \
                    -n ${params.melt.genes_bed} \
                    -t ${params.melt.transposon_file_list} \
                    -w \$PWD
        mv SVA.final_comp.vcf ${sampleID}.SVA.final_comp.vcf
        mv ALU.final_comp.vcf ${sampleID}.ALU.final_comp.vcf
        mv LINE1.final_comp.vcf ${sampleID}.LINE1.final_comp.vcf
        """
}
