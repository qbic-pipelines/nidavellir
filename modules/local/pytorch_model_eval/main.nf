process PYTORCH_MODEL_EVAL {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(trained_model), path(validation_split)

    output:
    tuple val(meta), path("*_eval_metrics.json"), path("*_eval_descriptor.yml"), path("*_trained_model_passthrough.*"), emit: eval_bundle
    path "versions.yml"                                                                                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    # TODO(stage-4): Replace placeholder evaluation with real model inference and metric computation.
    # TODO(stage-4): Add confusion matrices, ROC curves, and per-class summary outputs.

    cat <<'JSON' > ${meta.id}_eval_metrics.json
    {
      "stage": 4,
      "module": "PYTORCH_MODEL_EVAL",
      "sample": "${meta.id}",
      "trained_model": "${trained_model}",
      "validation_split": "${validation_split}",
      "metrics": {
        "status": "placeholder",
        "accuracy": null,
        "loss": null
      }
    }
    JSON

    cat <<'YAML' > ${meta.id}_eval_descriptor.yml
    stage: 4
    module: PYTORCH_MODEL_EVAL
    sample: "${meta.id}"
    contract:
      trained_model: "${trained_model}"
      validation_split: "${validation_split}"
      outputs:
        metrics_json: "${meta.id}_eval_metrics.json"
    TODO:
      - replace this placeholder with true PyTorch evaluation logic
      - include fold-aware and cohort-aware metric summaries
    YAML

    ext="${trained_model##*.}"
    cp "${trained_model}" "${meta.id}_trained_model_passthrough.${ext}"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scaffold: "1.0"
    END_VERSIONS
    """

    stub:
    """
    cat <<'JSON' > ${meta.id}_eval_metrics.json
    {
      "stage": 4,
      "module": "PYTORCH_MODEL_EVAL",
      "sample": "${meta.id}",
      "status": "stub"
    }
    JSON

    cat <<'YAML' > ${meta.id}_eval_descriptor.yml
    stage: 4
    module: PYTORCH_MODEL_EVAL
    sample: "${meta.id}"
    status: stub
    YAML

    cp "${trained_model}" "${meta.id}_trained_model_passthrough.stub"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scaffold: "stub"
    END_VERSIONS
    """
}
