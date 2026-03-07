/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    TRAINING PIPELINE (SCAFFOLD)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow TRAINING_PIPELINE {

    take:
    ch_samplesheet // channel: tuple val(meta), path(image)

    main:
    ch_multiqc_report = Channel.empty()

    log.info """
    Selected workflow: training
    Scaffold stages:
      1) Stage datasets from OMERO
      2) Stage pretrained models (BioImage Model Zoo)
      3) Run cross-validation training (e.g. PyTorch U-Net)
      4) Evaluate model performance
      5) Publish trained models
      6) Package outputs as FAIR RO-Crate artifacts with full provenance
    """.stripIndent()

    emit:
    multiqc_report = ch_multiqc_report
}
