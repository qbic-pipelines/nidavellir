/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { GENERATE_OMETIFF       } from '../subworkflows/local/generate_ometiff/main'
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
    ch_staged_omezarr = Channel.empty()
    ch_staged_ometiff = Channel.empty()
    ch_omero_upload_manifest = Channel.empty()

    if (params.data_storage_mode == 'generate_ometiff') {
        GENERATE_OMETIFF(ch_samplesheet)
        ch_versions = ch_versions.mix(GENERATE_OMETIFF.out.versions)
        ch_staged_omezarr = GENERATE_OMETIFF.out.staged_omezarr
        ch_staged_ometiff = GENERATE_OMETIFF.out.staged_ometiff
    } else if (params.data_storage_mode == 'full') {
        DATA_STORAGE_OMERO(ch_samplesheet)
        ch_versions = ch_versions.mix(DATA_STORAGE_OMERO.out.versions)
        ch_staged_omezarr = DATA_STORAGE_OMERO.out.staged_omezarr
        ch_staged_ometiff = DATA_STORAGE_OMERO.out.staged_ometiff
        ch_omero_upload_manifest = DATA_STORAGE_OMERO.out.omero_upload_manifest
    } else {
        error "Unsupported --data_storage_mode '${params.data_storage_mode}'. Choose one of: generate_ometiff, full"
    }

    // 4) FAIR output packaging (MVP: line-delimited JSON summary for downstream RO-Crate generation)
    ch_staged_omezarr
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
    staged_omezarr        = ch_staged_omezarr         // channel: tuple val(meta), path("*.ome.zarr")
    staged_ometiff        = ch_staged_ometiff         // channel: tuple val(meta), path("*.ome.tif")
    omero_upload_manifest = ch_omero_upload_manifest  // channel: tuple val(meta), path("*_omero_upload.json")
    fair_training_inputs  = ch_fair_training_inputs   // channel: path("fair_training_inputs.ndjson")
    multiqc_report        = ch_multiqc_report         // channel: empty placeholder for pipeline completion hooks
    versions              = ch_versions               // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
