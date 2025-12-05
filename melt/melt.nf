#!/usr/bin/env nextflow
/**
    Melt processes
**/


process Melt {
    time '2h'
    memory '16 GB'
    cpus 1

    publishDir "$params.output/melt", mode: 'copy'

    input:
        tuple val(sampleID), path(bamFile), path(baiFile)
    output:
        path "${sampleID}_melt.vcf"

    script:
        """
        if [[ "${params.genomeBuild}" == "hg19" ]]; then
            ${CMD_MELT:-} java -Xmx8G -jar "${params.melt.melt_jar}" Single \
                -h "${params.reference_genome}" \
                -bamfile "${bamFile}" \
                -n "${params.melt.genes_bed_hg19}" \
                -t "${params.melt.transposon_file_list_hg19}" \
                -w "$PWD"
        else
            ${CMD_MELT:-} java -Xmx8G -jar "${params.melt.melt_jar}" Single \
                -h "${params.reference_genome}" \
                -bamfile "${bamFile}" \
                -n "${params.melt.genes_bed_hg38}" \
                -t "${params.melt.transposon_file_list_hg38}" \
                -w "$PWD"
        fi
        ${CMD_MELT} bash -c '
        # Initialize array for gzipped VCFs to concat
        files_to_concat=()
        
        for type in SVA ALU LINE1; do
            vcf="\${type}.final_comp.vcf"
            if [ -s "\$vcf" ]; then
                echo "\$vcf is non-empty, compressing and indexing..."
                bcftools view -Oz -o "\${type}.final_comp.vcf.gz" "\$vcf"
                bcftools index "\${type}.final_comp.vcf.gz"
                files_to_concat+=("\${type}.final_comp.vcf.gz")
            else
                echo "\$vcf is empty or missing, skipping."
            fi
        done

        if [ \${#files_to_concat[@]} -gt 0 ]; then
            bcftools concat -a -o ${sampleID}_melt_tmp.vcf "\${files_to_concat[@]}"
            bcftools view -h ${sampleID}_melt_tmp.vcf | grep -v "^##contig" > new_header.txt
            bcftools reheader -h new_header.txt -o ${sampleID}_melt_tmp_nocontig.vcf ${sampleID}_melt_tmp.vcf
            bcftools reheader -f ${params.reference_genome}.fai ${sampleID}_melt_tmp_nocontig.vcf > ${sampleID}_melt_tmp_fixheader.vcf
            # Sort final VCF
            bcftools sort ${sampleID}_melt_tmp_fixheader.vcf -o ${sampleID}_melt.vcf
        else
            echo "No VCF files with variants to concatenate for sample ${sampleID}."
            touch ${sampleID}_melt.vcf
        fi
        '
        """
}
