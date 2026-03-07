include { GENERATE_OMETIFF     } from '../../../subworkflows/local/generate_ometiff/main'
include { OMERO_UPLOAD_OMETIFF } from '../../../modules/local/omero_upload_ometiff/main'

workflow DATA_STORAGE_OMERO {

    take:
    ch_samplesheet // channel: tuple val(meta), path(image)

    main:
    ch_versions = Channel.empty()

    GENERATE_OMETIFF(ch_samplesheet)
    ch_versions = ch_versions.mix(GENERATE_OMETIFF.out.versions)

    ch_ometiff_with_metadata = GENERATE_OMETIFF.out.staged_ometiff.map { meta, ometiff ->
        def metadata = [
            sample_id          : meta.id,
            source_omero_id    : meta.omero_id ?: null,
            source_image       : meta.image_path ?: null,
            pipeline_component : 'data_storage_pipeline'
        ]
        def enriched_meta = meta + [omero_metadata: metadata]
        [enriched_meta, ometiff]
    }

    OMERO_UPLOAD_OMETIFF(ch_ometiff_with_metadata)
    ch_versions = ch_versions.mix(OMERO_UPLOAD_OMETIFF.out.versions)

    emit:
    staged_omezarr         = GENERATE_OMETIFF.out.staged_omezarr
    staged_ometiff         = GENERATE_OMETIFF.out.staged_ometiff
    omero_upload_manifest  = OMERO_UPLOAD_OMETIFF.out.upload_manifest
    versions               = ch_versions
}
