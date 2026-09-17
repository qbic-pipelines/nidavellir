#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/nidavellir
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/nidavellir
    Website: https://nf-co.re/nidavellir
    Slack  : https://nfcore.slack.com/channels/nidavellir
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { NIDAVELLIR  } from './workflows/nidavellir'
include { TRAINING_PIPELINE } from './workflows/training'
include { INFERENCE_PIPELINE } from './workflows/inference'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_nidavellir_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_nidavellir_pipeline'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow NFCORE_NIDAVELLIR {

    take:
    samplesheet // channel: samplesheet read in from --input

    main:
    ch_multiqc_report = Channel.empty()
    def selected_workflow = params.workflow_track ?: params.pipeline_track

    if (selected_workflow == 'data_storage') {
        NIDAVELLIR (
            samplesheet,
            params.data_storage_mode
        )
        ch_multiqc_report = NIDAVELLIR.out.multiqc_report
    } else if (selected_workflow == 'generate_ometiff') {
        NIDAVELLIR (
            samplesheet,
            'generate_ometiff'
        )
        ch_multiqc_report = NIDAVELLIR.out.multiqc_report
    } else if (selected_workflow == 'training') {
        TRAINING_PIPELINE (
            samplesheet
        )
        ch_multiqc_report = TRAINING_PIPELINE.out.multiqc_report
    } else if (selected_workflow == 'inference') {
        INFERENCE_PIPELINE (
            samplesheet
        )
        ch_multiqc_report = INFERENCE_PIPELINE.out.multiqc_report
    } else {
        error "Unsupported workflow '${selected_workflow}'. Choose one of: training, inference, data_storage, generate_ometiff"
    }

    emit:
    multiqc_report = ch_multiqc_report // channel: /path/to/multiqc_report.html
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input
    )

    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_NIDAVELLIR (
        PIPELINE_INITIALISATION.out.samplesheet
    )
    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        NFCORE_NIDAVELLIR.out.multiqc_report
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
