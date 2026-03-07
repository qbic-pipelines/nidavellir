process PACKAGE_TRAINING_ROCRATE {
    tag "$meta.id"
    label 'process_low'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://python:3.11-slim' :
        'python:3.11-slim'}"

    input:
    tuple val(meta), path(training_artifact)

    output:
    tuple val(meta), path("*_training_rocrate_artifact_path.txt"), emit: artifact_path
    tuple val(meta), path("*_training_rocrate_summary.json")     , emit: summary
    tuple val(meta), path("*_training_rocrate.zip")              , optional: true, emit: crate_zip
    tuple val(meta), path("*_training_rocrate")                  , optional: true, emit: crate_dir
    path "versions.yml"                                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    def rocrateInput = [
        sample_id        : meta.id,
        training_artifact: training_artifact.toString(),
        omero            : meta.omero ?: [:],
        parent_model     : meta.parent_model ?: [:],
        training_run     : meta.training_run ?: [:],
        trained_model    : meta.trained_model ?: [:],
        publication      : meta.publication ?: [:],
        zip_output       : meta.rocrate_zip_output == null ? true : meta.rocrate_zip_output,
        base_uri         : meta.rocrate_base_uri ?: null
    ]

    """
    cat <<'JSON' > ${prefix}_training_rocrate_input.json
    ${groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(rocrateInput))}
    JSON

    package_training_rocrate.py \
        --metadata-json ${prefix}_training_rocrate_input.json \
        --output-prefix ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: meta.id

    """
    mkdir -p ${prefix}_training_rocrate
    touch ${prefix}_training_rocrate/ro-crate-metadata.json
    printf '%s\n' "${prefix}_training_rocrate" > ${prefix}_training_rocrate_artifact_path.txt

    cat <<'JSON' > ${prefix}_training_rocrate_summary.json
    {
      "sample_id": "${meta.id}",
      "artifact_path": "${prefix}_training_rocrate",
      "crate_format": "directory",
      "status": "stub"
    }
    JSON

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: "stub"
    END_VERSIONS
    """
}
