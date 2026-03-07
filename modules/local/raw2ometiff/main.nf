process RAW2OMETIFF {
    tag "$meta.id"
    label 'process_high'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://openmicroscopy/raw2ometiff:latest' :
        'openmicroscopy/raw2ometiff:latest'}"

    input:
    tuple val(meta), path(omezarr)

    output:
    tuple val(meta), path("*.ome.tif"), emit: ometiff
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    raw2ometiff \\
        $omezarr \\
        ${prefix}.ome.tif \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        raw2ometiff: \
            \$(raw2ometiff --version 2>&1 | sed -n '1p')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.ome.tif

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        raw2ometiff: "stub"
    END_VERSIONS
    """
}
