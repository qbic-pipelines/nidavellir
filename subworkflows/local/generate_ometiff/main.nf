include { BIOFORMATS2RAW } from '../../../modules/nf-core/bioformats2raw/main'
include { RAW2OMETIFF    } from '../../../modules/local/raw2ometiff/main'

workflow GENERATE_OMETIFF {

    take:
    ch_samplesheet // channel: tuple val(meta), path(image)

    main:
    ch_versions = Channel.empty()

    BIOFORMATS2RAW(ch_samplesheet)
    ch_versions = ch_versions.mix(BIOFORMATS2RAW.out.versions)

    RAW2OMETIFF(BIOFORMATS2RAW.out.omezarr)
    ch_versions = ch_versions.mix(RAW2OMETIFF.out.versions)

    emit:
    staged_omezarr = BIOFORMATS2RAW.out.omezarr
    staged_ometiff = RAW2OMETIFF.out.ometiff
    versions       = ch_versions
}
