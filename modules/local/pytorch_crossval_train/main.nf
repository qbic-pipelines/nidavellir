process PYTORCH_CROSSVAL_TRAIN {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(dataset_descriptor), path(parent_model)

    output:
    tuple val(meta), path("*_trained_model.pt"), path("*_training_descriptor.json"), path("*_parent_model_passthrough.*"), emit: trained_bundle
    path "versions.yml"                                                                                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def folds = task.ext.cv_folds ?: 5

    """
    # TODO(stage-3): Replace placeholder logic with real PyTorch cross-validation training.
    # TODO(stage-3): Persist learned model weights and fold metrics from actual training runs.

    touch ${meta.id}_trained_model.pt

    cat <<'JSON' > ${meta.id}_training_descriptor.json
    {
      "stage": 3,
      "module": "PYTORCH_CROSSVAL_TRAIN",
      "sample": "${meta.id}",
      "dataset_descriptor": "${dataset_descriptor}",
      "parent_model": "${parent_model}",
      "cv_folds": ${folds},
      "status": "todo-implement-pytorch-crossval"
    }
    JSON

    # Ensure a stable pass-through artifact name preserving extension when possible.
    ext="${parent_model##*.}"
    cp "${parent_model}" "${meta.id}_parent_model_passthrough.${ext}"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scaffold: "1.0"
    END_VERSIONS
    """

    stub:
    """
    touch ${meta.id}_trained_model.pt
    cat <<'JSON' > ${meta.id}_training_descriptor.json
    {
      "stage": 3,
      "module": "PYTORCH_CROSSVAL_TRAIN",
      "sample": "${meta.id}",
      "status": "stub"
    }
    JSON
    cp "${parent_model}" "${meta.id}_parent_model_passthrough.stub"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scaffold: "stub"
    END_VERSIONS
    """
}
