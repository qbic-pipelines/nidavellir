/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { BIOFORMATS2RAW         } from '../modules/nf-core/bioformats2raw/main'

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

    // 1) Data and model staging (current MVP: image conversion to OME-Zarr)
    BIOFORMATS2RAW(ch_samplesheet)
    ch_versions = ch_versions.mix(BIOFORMATS2RAW.out.versions)

    // 4) FAIR output packaging (MVP: line-delimited JSON summary for downstream RO-Crate generation)
    BIOFORMATS2RAW.out.omezarr
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
    staged_omezarr      = BIOFORMATS2RAW.out.omezarr // channel: tuple val(meta), path("*.ome.zarr")
    fair_training_inputs = ch_fair_training_inputs    // channel: path("fair_training_inputs.ndjson")
    multiqc_report      = ch_multiqc_report          // channel: empty placeholder for pipeline completion hooks
    versions            = ch_versions                // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
