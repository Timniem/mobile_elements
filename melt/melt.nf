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
        path "${sampleID}_melt.vcf"

    script:
        """
        ${CMD_MELT} java -Xmx8G -jar ${params.melt.melt_jar} Single \
                    -h ${params.reference_genome} \
                    -bamfile ${bamFile} \
                    -n ${params.melt.genes_bed} \
                    -t ${params.melt.transposon_file_list} \
                    -w \$PWD

        ${CMD_MELT} bash -c 'bcftools view -Oz -o SVA.final_comp.vcf.gz SVA.final_comp.vcf
                    bcftools view -Oz -o ALU.final_comp.vcf.gz ALU.final_comp.vcf
                    bcftools view -Oz -o LINE1.final_comp.vcf.gz LINE1.final_comp.vcf
                    bcftools index SVA.final_comp.vcf.gz
                    bcftools index ALU.final_comp.vcf.gz
                    bcftools index LINE1.final_comp.vcf.gz
                    bcftools concat -a -o ${sampleID}_melt_tmp.vcf SVA.final_comp.vcf.gz ALU.final_comp.vcf.gz LINE1.final_comp.vcf.gz

                    # Extract header, remove contig lines, save as new header.
                    bcftools view -h ${sampleID}_melt_tmp.vcf | grep -v '^##contig' > new_header.txt

                    # Replace header in VCF with this cleaned header and sort variants.
                    bcftools reheader -h new_header.txt -o ${sampleID}_melt_tmp_nocontig.vcf ${sampleID}_melt_tmp.vcf
                    bcftools reheader -f ${params.reference_genome}.fai ${sampleID}_melt_tmp_nocontig.vcf > ${sampleID}_melt_tmp_fixheader.vcf
                    bcftools sort ${sampleID}_melt_tmp_fixheader.vcf -o ${sampleID}_melt.vcf'
        """
}
