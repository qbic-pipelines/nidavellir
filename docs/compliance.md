# nf-core compliance maintenance plan

This repository was checked with `nf-core/tools 3.5.2` using:

```bash
nf-core pipelines lint -d . --plain-text
```

## Immediate updates applied

- Bumped `.nf-core.yml` `nf_core_version` to `3.5.2`.
- Updated README template badge to `3.5.2`.
- Synced `ro-crate-metadata.json` description with `README.md` (auto-fix from lint).

## Recommended next actions

1. **Template sync for unchanged template files**
   - Sync from the latest nf-core template so these files match upstream:
     - `.github/workflows/linting.yml`
     - `.github/workflows/linting_comment.yml`
     - `.prettierignore`
     - `docs/README.md`

2. **Resolve TODO placeholders that trigger lint warnings**
   - Replace template TODO text in:
     - `nextflow.config`
     - `conf/base.config`
     - `conf/test.config`
     - `conf/test_full.config`
     - `assets/methods_description_template.yml`
     - `README.md`
     - `main.nf`
     - `.github/workflows/awsfulltest.yml`

3. **Subworkflow metadata hygiene**
   - Add missing `meta.yml` files for local subworkflows:
     - `subworkflows/local/data_storage_omero/`
     - `subworkflows/local/generate_ometiff/`
     - `subworkflows/local/utils_nfcore_nidavellir_pipeline/`

4. **Module / subworkflow refresh**
   - Update nf-core components flagged as outdated:
     - `modules/nf-core/bioformats2raw`
     - `modules/nf-core/multiqc`
     - `subworkflows/nf-core/utils_nextflow_pipeline`
     - `subworkflows/nf-core/utils_nfcore_pipeline`
     - `subworkflows/nf-core/utils_nfschema_plugin`

5. **Release-readiness**
   - Replace Zenodo placeholders (`zenodo.XXXXXXX`) once first release DOI exists.

## Suggested cadence

- Run standard lint weekly:

```bash
nf-core pipelines lint -d . --plain-text
```

- Run release lint before tagging a release:

```bash
nf-core pipelines lint -d . --release --plain-text
```

