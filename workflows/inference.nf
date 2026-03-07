/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INFERENCE PIPELINE (SCAFFOLD)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow INFERENCE_PIPELINE {

    take:
    ch_samplesheet // channel: tuple val(meta), path(image)

    main:
    ch_multiqc_report = Channel.empty()

    log.info """
    Selected workflow: inference
    Scaffold stages:
      1) Convert images to OME-Zarr (NGFF)
      2) Run model inference
      3) Export segmentation masks and labelled images
    """.stripIndent()

    emit:
    multiqc_report = ch_multiqc_report
}
