process OMERO_UPLOAD_OMETIFF {
    tag "$meta.id"
    label 'process_low'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://openmicroscopy/omero-py:latest' :
        'openmicroscopy/omero-py:latest'}"

    input:
    tuple val(meta), path(ometiff)

    output:
    tuple val(meta), path("*_omero_upload.json"), emit: upload_manifest
    path "versions.yml"                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def dataset = params.omero_dataset ?: ''
    def dryRun = params.omero_dry_run == null ? true : params.omero_dry_run

    """
    cat <<'JSON' > ${meta.id}_omero_upload.json
    {
      "sample": "${meta.id}",
      "input_ometiff": "${ometiff}",
      "omero_dataset": "${dataset}",
      "omero_project": "${params.omero_project ?: ''}",
      "annotation": ${groovy.json.JsonOutput.toJson(meta.omero_metadata ?: [:])},
      "dry_run": ${dryRun}
    }
    JSON

    if [[ "${dryRun}" == "false" ]]; then
        omero login "${params.omero_host}" -u "${params.omero_user}" -w "${params.omero_password}"
        omero import --transfer=ln_s ${dataset ? "--dataset ${dataset}" : ''} "${ometiff}"

        if [[ "${params.omero_metadata_ns ?: ''}" != "" ]]; then
            omero metadata populate --file ${meta.id}_omero_upload.json --namespace "${params.omero_metadata_ns}"
        fi
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        omero-cli: \$(omero --version 2>&1 | sed -n '1p' || echo 'not-installed')
    END_VERSIONS
    """

    stub:
    """
    cat <<'JSON' > ${meta.id}_omero_upload.json
    {
      "sample": "${meta.id}",
      "input_ometiff": "${ometiff}",
      "status": "stub-upload"
    }
    JSON

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        omero-cli: "stub"
    END_VERSIONS
    """
}
