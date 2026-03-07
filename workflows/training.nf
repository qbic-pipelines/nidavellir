/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    TRAINING PIPELINE (SCAFFOLD)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow STAGE_DATASET_FROM_OMERO {

    take:
    ch_samplesheet // channel: tuple val(meta), path(image)

    main:
    // TODO: Replace with dedicated OMERO dataset staging module/subworkflow.
    // Stable schema: tuple val(meta), val(dataset_descriptor)
    ch_dataset_descriptor = ch_samplesheet.map { meta, image ->
        def datasetId = meta.dataset_id ?: meta.sample_id ?: meta.id ?: image.baseName
        def descriptor = [
            dataset_id     : datasetId,
            source         : 'omero',
            source_image   : image.toString(),
            descriptor_type: 'dataset_descriptor',
            status         : 'placeholder'
        ]
        tuple(meta, descriptor)
    }

    ch_versions = Channel.value([stage: 'STAGE_DATASET_FROM_OMERO', version: 'placeholder'])

    emit:
    dataset_descriptor = ch_dataset_descriptor
    versions           = ch_versions
}

workflow STAGE_PARENT_MODEL_BIOIMAGEIO {

    take:
    ch_dataset_descriptor // channel: tuple val(meta), val(dataset_descriptor)

    main:
    // Implemented scaffold: emit stable parent-model artifact metadata from BioImage.IO.
    // Stable schema: tuple val(meta), val(parent_model_artifact)
    ch_parent_model_artifact = ch_dataset_descriptor.map { meta, dataset_descriptor ->
        def parentModel = [
            model_id      : params.parent_model_id ?: 'bioimageio://placeholder/parent-model',
            source        : 'bioimageio',
            artifact_type : 'parent_model_artifact',
            dataset_id    : dataset_descriptor.dataset_id
        ]
        tuple(meta, parentModel)
    }

    ch_versions = Channel.value([stage: 'STAGE_PARENT_MODEL_BIOIMAGEIO', version: 'v1'])

    emit:
    parent_model_artifact = ch_parent_model_artifact
    versions              = ch_versions
}

workflow TRAIN_CV_PYTORCH {

    take:
    ch_dataset_descriptor    // channel: tuple val(meta), val(dataset_descriptor)
    ch_parent_model_artifact // channel: tuple val(meta), val(parent_model_artifact)

    main:
    // TODO: Replace with cross-validation PyTorch training module/subworkflow.
    // Stable schema: tuple val(meta), val(trained_model_artifact)
    ch_trained_model = ch_dataset_descriptor
        .join(ch_parent_model_artifact)
        .map { meta, dataset_descriptor, parent_model_artifact ->
            def trainedModel = [
                model_id              : "trained-${dataset_descriptor.dataset_id}",
                parent_model_id       : parent_model_artifact.model_id,
                artifact_type         : 'trained_model_artifact',
                training_framework    : 'pytorch',
                cross_validation_folds: params.cv_folds ?: 5,
                status                : 'placeholder'
            ]
            tuple(meta, trainedModel)
        }

    ch_versions = Channel.value([stage: 'TRAIN_CV_PYTORCH', version: 'placeholder'])

    emit:
    trained_model = ch_trained_model
    versions      = ch_versions
}

workflow EVAL_MODEL {

    take:
    ch_trained_model // channel: tuple val(meta), val(trained_model_artifact)

    main:
    // TODO: Replace with full evaluation module/subworkflow.
    // Stable schema: tuple val(meta), val(evaluation_summary)
    ch_evaluation_summary = ch_trained_model.map { meta, trained_model ->
        def summary = [
            model_id   : trained_model.model_id,
            status     : 'placeholder',
            metrics    : [dice: null, iou: null],
            evaluator  : 'to-be-implemented'
        ]
        tuple(meta, summary)
    }

    ch_versions = Channel.value([stage: 'EVAL_MODEL', version: 'placeholder'])

    emit:
    evaluation_summary = ch_evaluation_summary
    versions           = ch_versions
}

workflow PUBLISH_MODEL_BIOIMAGEIO {

    take:
    ch_trained_model
    ch_evaluation_summary

    main:
    // Implemented scaffold: produce a stable BioImage.IO publication record schema.
    // Stable schema: tuple val(meta), val(bioimageio_publication_record)
    ch_publication_record = ch_trained_model
        .join(ch_evaluation_summary)
        .map { meta, trained_model, evaluation_summary ->
            def publicationRecord = [
                publication_id   : "bioimageio-publication-${trained_model.model_id}",
                registry         : 'bioimageio',
                model_id         : trained_model.model_id,
                evaluation_status: evaluation_summary.status,
                record_type      : 'bioimageio_publication_record'
            ]
            tuple(meta, publicationRecord)
        }

    ch_versions = Channel.value([stage: 'PUBLISH_MODEL_BIOIMAGEIO', version: 'v1'])

    emit:
    bioimageio_publication_record = ch_publication_record
    versions                      = ch_versions
}

workflow PACKAGE_RO_CRATE {

    take:
    ch_trained_model
    ch_evaluation_summary
    ch_publication_record

    main:
    // Implemented scaffold: emit a stable RO-Crate output path representation.
    // Stable schema: tuple val(meta), val(ro_crate_path)
    ch_ro_crate = ch_trained_model
        .join(ch_evaluation_summary)
        .join(ch_publication_record)
        .map { meta, trained_model, evaluation_summary, publication_record ->
            def sampleId = meta.sample_id ?: meta.id ?: trained_model.model_id
            def roCratePath = "results/ro-crate/${sampleId}.ro-crate.zip"
            tuple(meta, roCratePath)
        }

    ch_versions = Channel.value([stage: 'PACKAGE_RO_CRATE', version: 'v1'])

    emit:
    ro_crate = ch_ro_crate
    versions = ch_versions
}

workflow TRAINING_PIPELINE {

    take:
    ch_samplesheet // channel: tuple val(meta), path(image)

    main:
    ch_versions = Channel.empty()
    ch_multiqc_report = Channel.empty()

    log.info """
    Selected workflow: training
    Stages:
      1) Stage datasets from OMERO
      2) Stage pretrained models (BioImage Model Zoo)
      3) Run cross-validation training (e.g. PyTorch U-Net)
      4) Evaluate model performance
      5) Publish trained models
      6) Package outputs as FAIR RO-Crate artifacts with full provenance
    """.stripIndent()

    STAGE_DATASET_FROM_OMERO(ch_samplesheet)
    ch_versions = ch_versions.mix(STAGE_DATASET_FROM_OMERO.out.versions)

    STAGE_PARENT_MODEL_BIOIMAGEIO(STAGE_DATASET_FROM_OMERO.out.dataset_descriptor)
    ch_versions = ch_versions.mix(STAGE_PARENT_MODEL_BIOIMAGEIO.out.versions)

    TRAIN_CV_PYTORCH(
        STAGE_DATASET_FROM_OMERO.out.dataset_descriptor,
        STAGE_PARENT_MODEL_BIOIMAGEIO.out.parent_model_artifact
    )
    ch_versions = ch_versions.mix(TRAIN_CV_PYTORCH.out.versions)

    EVAL_MODEL(TRAIN_CV_PYTORCH.out.trained_model)
    ch_versions = ch_versions.mix(EVAL_MODEL.out.versions)

    PUBLISH_MODEL_BIOIMAGEIO(
        TRAIN_CV_PYTORCH.out.trained_model,
        EVAL_MODEL.out.evaluation_summary
    )
    ch_versions = ch_versions.mix(PUBLISH_MODEL_BIOIMAGEIO.out.versions)

    PACKAGE_RO_CRATE(
        TRAIN_CV_PYTORCH.out.trained_model,
        EVAL_MODEL.out.evaluation_summary,
        PUBLISH_MODEL_BIOIMAGEIO.out.bioimageio_publication_record
    )
    ch_versions = ch_versions.mix(PACKAGE_RO_CRATE.out.versions)

    emit:
    trained_model                  = TRAIN_CV_PYTORCH.out.trained_model
    evaluation_summary             = EVAL_MODEL.out.evaluation_summary
    bioimageio_publication_record  = PUBLISH_MODEL_BIOIMAGEIO.out.bioimageio_publication_record
    ro_crate                       = PACKAGE_RO_CRATE.out.ro_crate
    multiqc_report                 = ch_multiqc_report
    versions                       = ch_versions
}
