/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INFERENCE PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { BIOFORMATS2RAW } from '../modules/nf-core/bioformats2raw/main'
include { RAW2OMETIFF as RAW2OMETIFF_MASKS } from '../modules/local/raw2ometiff/main'
include { RAW2OMETIFF as RAW2OMETIFF_LABELS } from '../modules/local/raw2ometiff/main'

workflow INFERENCE_PIPELINE {

    take:
    ch_samplesheet // channel: tuple val(meta), path(image)

    main:
    ch_versions = Channel.empty()
    ch_multiqc_report = Channel.empty()

    log.info """
    Selected workflow: inference
    Stages:
      1) Convert input images to OME-Zarr (bioformats2raw)
      2) Run model inference (placeholder scaffold)
      3) Export segmentation masks and labelled images (OME-TIFF)
    """.stripIndent()

    // (1) Convert each source image to OME-Zarr for model consumption.
    BIOFORMATS2RAW(ch_samplesheet)
    ch_versions = ch_versions.mix(BIOFORMATS2RAW.out.versions)

    // (2) Placeholder scaffold for model inference.
    // TODO: Replace this pass-through with the real inference module/subworkflow.
    ch_inference_masks_omezarr = BIOFORMATS2RAW.out.omezarr
        .map { meta, omezarr -> tuple(meta + [output_suffix: 'mask'], omezarr) }

    ch_inference_labelled_omezarr = BIOFORMATS2RAW.out.omezarr
        .map { meta, omezarr -> tuple(meta + [output_suffix: 'labelled'], omezarr) }

    // (3) Export segmentation artefacts as OME-TIFF.
    RAW2OMETIFF_MASKS(ch_inference_masks_omezarr)
    ch_versions = ch_versions.mix(RAW2OMETIFF_MASKS.out.versions)

    RAW2OMETIFF_LABELS(ch_inference_labelled_omezarr)
    ch_versions = ch_versions.mix(RAW2OMETIFF_LABELS.out.versions)

    emit:
    staged_omezarr              = BIOFORMATS2RAW.out.omezarr
    segmentation_masks_ometiff  = RAW2OMETIFF_MASKS.out.ometiff
    labelled_images_ometiff     = RAW2OMETIFF_LABELS.out.ometiff
    multiqc_report              = ch_multiqc_report
    versions                    = ch_versions
}
