process OMERO_STAGE_TRAINING_DATASET {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), val(omero_query)

    output:
    tuple val(meta), path("*_dataset_descriptor.json"), path("*_query_descriptor.yml"), emit: dataset_contract
    path "versions.yml"                                                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def kvNamespace = omero_query?.key_value?.namespace ?: ''
    def kvPairs = omero_query?.key_value?.pairs ?: [:]
    def tagInclude = omero_query?.tags?.include ?: []
    def tagExclude = omero_query?.tags?.exclude ?: []

    """
    # TODO(stage-1): Replace placeholder descriptor generation with OMERO query execution.
    # TODO(stage-1): Resolve image IDs and emit a concrete dataset artifact list.

    cat <<'JSON' > ${meta.id}_dataset_descriptor.json
    {
      "stage": 1,
      "module": "OMERO_STAGE_TRAINING_DATASET",
      "sample": "${meta.id}",
      "query_mode": "placeholder",
      "status": "todo-implement-omero-query",
      "resolved_images": []
    }
    JSON

    cat <<'YAML' > ${meta.id}_query_descriptor.yml
    stage: 1
    module: OMERO_STAGE_TRAINING_DATASET
    sample: "${meta.id}"
    query_contract:
      key_value:
        namespace: "${kvNamespace}"
        pairs: ${groovy.json.JsonOutput.toJson(kvPairs)}
      tags:
        include: ${groovy.json.JsonOutput.toJson(tagInclude)}
        exclude: ${groovy.json.JsonOutput.toJson(tagExclude)}
    TODO:
      - replace this placeholder with OMERO key-value and tag query logic
      - emit concrete dataset item URIs and metadata from OMERO
    YAML

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scaffold: "1.0"
    END_VERSIONS
    """

    stub:
    """
    cat <<'JSON' > ${meta.id}_dataset_descriptor.json
    {
      "stage": 1,
      "module": "OMERO_STAGE_TRAINING_DATASET",
      "sample": "${meta.id}",
      "status": "stub"
    }
    JSON

    cat <<'YAML' > ${meta.id}_query_descriptor.yml
    stage: 1
    module: OMERO_STAGE_TRAINING_DATASET
    sample: "${meta.id}"
    status: stub
    YAML

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scaffold: "stub"
    END_VERSIONS
    """
}
