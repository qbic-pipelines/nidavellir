/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { DATA_STORAGE_OMERO     } from '../subworkflows/local/data_storage_omero/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NIDAVELLIR {

    take:
    ch_samplesheet // channel: tuple val(meta), path(image) read in from --input

    main:
    ch_versions = Channel.empty()
    ch_multiqc_report = Channel.empty()

    // 3) Data storage pipeline: convert to OME-Zarr -> OME-TIFF -> upload to OMERO with metadata manifest
    DATA_STORAGE_OMERO(ch_samplesheet)
    ch_versions = ch_versions.mix(DATA_STORAGE_OMERO.out.versions)

    // 4) FAIR output packaging (MVP: line-delimited JSON summary for downstream RO-Crate generation)
    DATA_STORAGE_OMERO.out.staged_omezarr
        .map { meta, omezarr ->
            def record = [
                sample: meta.id,
                omero_id: meta.omero_id ?: null,
                staged_dataset: omezarr.toString(),
                data_format: 'OME-Zarr'
            ]
            return groovy.json.JsonOutput.toJson(record)
        }
        .collectFile(
            storeDir: "${params.outdir}/metadata",
            name: 'fair_training_inputs.ndjson',
            newLine: true,
            sort: true
        )
        .set { ch_fair_training_inputs }

    // Collate and save software versions
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_nidavellir_mqc_versions.yml',
            sort: true,
            newLine: true
        )
        .set { ch_collated_versions }

    emit:
    staged_omezarr        = DATA_STORAGE_OMERO.out.staged_omezarr      // channel: tuple val(meta), path("*.ome.zarr")
    staged_ometiff        = DATA_STORAGE_OMERO.out.staged_ometiff      // channel: tuple val(meta), path("*.ome.tif")
    omero_upload_manifest = DATA_STORAGE_OMERO.out.omero_upload_manifest // channel: tuple val(meta), path("*_omero_upload.json")
    fair_training_inputs  = ch_fair_training_inputs                    // channel: path("fair_training_inputs.ndjson")
    multiqc_report        = ch_multiqc_report                          // channel: empty placeholder for pipeline completion hooks
    versions              = ch_versions                                // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
