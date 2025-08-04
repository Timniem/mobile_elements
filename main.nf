/**
Nextflow main MELT/SCRAMble
author: T Niemeijer
**/

nextflow.enable.dsl=2

include { Melt } from "./melt/melt"
include { IdentifyClusters; SCRAMble } from "./scramble/scramble"


workflow Melt_workflow {
    Channel
    .fromPath( params.samplesheet )
    .splitCsv( header: true, sep: '\t' )
    .map { row ->
        def bai = file("${row.bamFile}.bai")  // This will be data/sample.bam.bai
        if (!bai.exists()) error "Missing BAI index for ${row.bamFile}"
        tuple( row.sampleID, row.bamFile, bai)
    }
    | Melt

}

workflow SCRAMble_workflow {
     /* 
    SCRAMble workflow
    */
    Channel
    .fromPath( params.samplesheet )
    .splitCsv( header: true, sep: '\t' )
    .map { row ->
        def bai = file("${row.bamFile}.bai")  // This will be data/sample.bam.bai
        if (!bai.exists()) error "Missing BAI index for ${row.bamFile}"
        tuple( row.sampleID, row.bamFile, bai)
    }
    | IdentifyClusters
    | SCRAMble

}


workflow {
    Melt_workflow()
    SCRAMble_workflow()
}