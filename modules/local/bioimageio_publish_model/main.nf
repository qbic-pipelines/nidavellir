process BIOIMAGEIO_PUBLISH_MODEL {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(trained_model_metadata)

    output:
    tuple val(meta), path("*_bioimageio_publication.json"), emit: publication
    path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def output_json = "${prefix}_bioimageio_publication.json"

    """
    python ${moduleDir}/bin/publish_model.py \\
        --trained-model-metadata \"${trained_model_metadata}\" \\
        --output \"${output_json}\"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed -n '1p')
        bioimageio-spec: \$(python - <<'PY'
import importlib
for pkg in ("bioimageio.spec", "bioimageio.core"):
    try:
        mod = importlib.import_module(pkg)
        print(getattr(mod, "__version__", "unknown"))
        break
    except Exception:
        continue
else:
    print("not-installed")
PY
)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def output_json = "${prefix}_bioimageio_publication.json"

    """
    cat <<'JSON' > ${output_json}
    {
      "error": null,
      "publication": {},
      "source_package": null,
      "status": "stub"
    }
    JSON

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: "stub"
        bioimageio-spec: "stub"
    END_VERSIONS
    """
}
