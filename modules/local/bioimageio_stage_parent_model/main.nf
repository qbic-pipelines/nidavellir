process BIOIMAGEIO_STAGE_PARENT_MODEL {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), val(parent_ref)

    output:
    tuple val(meta), path("*_bioimageio_parent_model.json"), emit: parent_model
    path "versions.yml"                                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def output_json = "${prefix}_bioimageio_parent_model.json"

    """
    python ${moduleDir}/bin/stage_parent_model.py \\
        --parent-ref ${parent_ref ? "\"${parent_ref}\"" : "\"\""} \\
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
    def output_json = "${prefix}_bioimageio_parent_model.json"

    """
    cat <<'JSON' > ${output_json}
    {
      "descriptor": {},
      "error": null,
      "parent_ref": "${parent_ref}",
      "resolved_source": null,
      "status": "stub",
      "staged_path": null
    }
    JSON

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: "stub"
        bioimageio-spec: "stub"
    END_VERSIONS
    """
}
