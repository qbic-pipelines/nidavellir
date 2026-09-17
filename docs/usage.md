# Nidavellir: Usage

See the [parameter schema](../nextflow_schema.json) for declared options and the
[README](../README.md) for the target architecture and implementation boundaries.

## Introduction

`luiskuhn/nidavellir` currently provides an MVP FAIR bioimage staging workflow. It validates an image-centric samplesheet, converts source images to OME-Zarr with `bioformats2raw`, and writes machine-readable metadata records for downstream provenance packaging.

## Workflow model

Nidavellir is developed as a multi-stage bioimage ML workflow system with three connected tracks:

| Workflow track | Scope                                                                 | Status in this repository                                                                                                  |
| -------------- | --------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Training       | Stage data/models, run training and evaluation, package FAIR outputs. | **Scaffolded + structurally wired** (explicit six-stage DAG with stable output contracts and placeholder stage internals). |
| Inference      | Convert images, run model inference, export masks/labelled outputs.   | **Partially implemented** (conversion + exports implemented; model inference step is a placeholder scaffold).              |
| Data storage   | Persist images/labels and metadata in OMERO.                          | **Partially implemented** (`generate_ometiff` conversion path + OMERO upload manifest scaffold; optional live upload).     |

Current command-line execution supports implemented data staging/storage workflows and a partially implemented inference track (with explicit placeholder for the model execution step). Future releases will expose remaining lifecycle components as dedicated modules/subworkflows while preserving FAIR provenance outputs.

## Samplesheet input

Provide a comma-separated samplesheet with the required columns `sample,image_path` and optional `omero_id`:

```bash
--input '[path to samplesheet file]'
```

### Required / optional columns

| Column       | Required | Description                                                                        |
| ------------ | -------- | ---------------------------------------------------------------------------------- |
| `sample`     | Yes      | Unique sample identifier. Spaces are not allowed.                                  |
| `image_path` | Yes      | Absolute or relative path to a Bio-Formats compatible image file to stage.         |
| `omero_id`   | No       | Upstream OMERO identifier (for example `OMERO:Image:123`) recorded for provenance. |

Example:

```csv title="samplesheet.csv"
sample,image_path,omero_id
cell_001,/data/images/cell_001.ome.tiff,OMERO:Image:123
cell_002,/data/images/cell_002.czi,
```

An [example samplesheet](../assets/samplesheet.csv) is included in this repository.

### OMERO data storage scaffold

The data storage pipeline now runs as reusable subworkflows: `generate_ometiff` (which chains `bioformats2raw -> raw2ometiff`) followed by `omero_upload_ometiff`.

By default, uploads run in dry-run mode and only emit JSON manifests. The current
live-upload scaffold uses `omero_dry_run: false`, `omero_host`, `omero_user`, and
`omero_password` parameters.

> [!WARNING]
> This legacy module interpolates the password into a task script; ordinary
> parameter reporting may also retain it. A params file alone does not make this
> secret-safe. Keep dry-run enabled for shared/published runs until secure
> credential handling is integrated. Do not commit credentials or publish work
> directories or parameter reports containing them. Bifrost profile integration
> remains planned and does not fix this existing module automatically.

Optional: `--omero_project`, `--omero_dataset`, `--omero_metadata_ns`.

### Selecting workflow type and data storage mode

Use `--workflow_track` to select which workflow scaffold to run:

- `data_storage` (implemented)
- `generate_ometiff` (implemented conversion-only shortcut)
- `training` (scaffold DAG implemented: explicit stages 1-6, stable contracts, placeholder internals for execution logic)
- `inference` (partially implemented: OME-Zarr staging + mask/labelled OME-TIFF export, with placeholder model step)

`--pipeline_track` is retained as a backward-compatible alias. If both are set, `--workflow_track` takes precedence.

For `--workflow_track data_storage`, use `--data_storage_mode` to choose:

- `full`: `generate_ometiff` + OMERO upload scaffold
- `generate_ometiff`: conversion-only path (`bioformats2raw -> raw2ometiff`)

Example (conversion only):

```bash
nextflow run luiskuhn/nidavellir -r dev \
  --input ./samplesheet.csv \
  --outdir ./results \
  --workflow_track generate_ometiff \
  -profile docker
```

### Training scaffold parameters (stages 1-6)

The training track now executes an explicit six-stage scaffold DAG and emits stable stage contracts. Current logic is still placeholder-oriented for OMERO querying, model training, evaluation, and live publication calls, but stage boundaries and output schemas are in place for incremental hardening. The parameter groups below are declared planning placeholders. The current workflow does not consume most of them or persist them as stage outputs; do not interpret their presence in the schema as implemented behavior. In particular, current stage logic reads `parent_model_id` and `cv_folds`, not the similarly named `training_stage*` options.

1. **Stage (1) OMERO query scaffold inputs**
   - `--training_stage1_omero_tags`
   - `--training_stage1_omero_kv_filters`
   - `--training_stage1_omero_server_ref`
2. **Stage (2) parent model selection scaffold metadata**
   - `--training_stage2_parent_model_id`
   - `--training_stage2_parent_model_doi`
   - `--training_stage2_parent_model_uri`
   - `--training_stage2_parent_model_version`
3. **Stages (3)/(4) training/eval scaffold metadata**
   - `--training_stage34_fold_count`
   - `--training_stage34_seed`
   - `--training_stage34_hyperparams_json`
4. **Stage (5) publication scaffold metadata**
   - `--training_stage5_target_collection`
   - `--training_stage5_target_account`
   - `--training_stage5_publication_metadata_json`
5. **Stage (6) RO-Crate scaffold metadata**
   - `--training_stage6_rocrate_creator`
   - `--training_stage6_rocrate_organization`
   - `--training_stage6_rocrate_license`
   - `--training_stage6_rocrate_run_title`

Example (training scaffold only; no model training or publication):

```bash
nextflow run luiskuhn/nidavellir -r dev \
  --input ./samplesheet.csv \
  --outdir ./results \
  --workflow_track training \
  -profile docker
```

### Inference pipeline details

The `--workflow_track inference` path currently implements:

1. **Image conversion to OME-Zarr** using `bioformats2raw` (`BIOFORMATS2RAW` process).
2. **Model inference placeholder scaffold** that currently passes staged OME-Zarr forward while splitting outputs into two semantic branches (mask + labelled).
3. **Export to OME-TIFF** using `raw2ometiff` (`RAW2OMETIFF` process), creating:
   - `<sample>_mask.ome.tif`
   - `<sample>_labelled.ome.tif`

The placeholder in step (2) passes through source pixels: neither exported file is an actual segmentation. No uncertainty estimation or model execution occurs in this track yet.

Example (inference scaffold run):

```bash
nextflow run luiskuhn/nidavellir -r dev \
  --input ./samplesheet.csv \
  --outdir ./results \
  --workflow_track inference \
  -profile docker
```

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run luiskuhn/nidavellir -r dev --input ./samplesheet.csv --outdir ./results --workflow_track generate_ometiff -profile docker
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the Nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow.log       # Log file from Nextflow
# Other Nextflow hidden files, e.g. run history and old logs.
```

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

> [!WARNING]
> Prefer `-params-file` for pipeline parameters, including `outdir`. Reserve `-c` for [process resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), infrastructure, and module arguments. The existing `raw2ometiff.config` preset has a legacy parameter fallback; see the README for its supported override pattern.

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run luiskuhn/nidavellir -r dev -profile docker -params-file params.yaml
```

with:

```yaml title="params.yaml"
input: "./samplesheet.csv"
outdir: "./results/"
workflow_track: "generate_ometiff"
```

Use the repository's parameter templates and `nextflow_schema.json` to select supported settings.

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. To make sure that you're running the latest version of the pipeline, update the cached version regularly:

```bash
nextflow pull luiskuhn/nidavellir -r dev
```

### Reproducibility

Examples use the moving `dev` branch. For reproducibility, specify a tested commit or release/tag and archive run artifacts (`pipeline_info/`, params, and metadata outputs).

### Core Nextflow arguments

> _NB: These options are part of Nextflow and use a single hyphen (pipeline options use a double-hyphen)._  
> Please refer to the [Nextflow documentation](https://www.nextflow.io/docs/latest/cli.html) for more details.

### Custom configuration

Please refer to the [nf-core website](https://nf-co.re/docs/usage/configuration) for more information about custom config files and module parameterisation.

### Running in the background

Use Nextflow `-bg`, `screen`, or `tmux` if you want to detach from the terminal while jobs continue running.

### Nextflow memory requirements

In some environments, you may need to constrain JVM memory:

```bash
export NXF_OPTS='-Xms1g -Xmx4g'
```
