# Nidavellir: Output

## Introduction

This document describes outputs currently produced by implemented data storage/conversion paths, inference exports, and scaffolded training-track contracts.

File outputs depend on the selected track. Training-stage values below are
in-memory contracts, not necessarily files. Published paths are relative to the
results directory unless stated otherwise.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and currently performs the following steps:

- [Bioimage staging](#bioimage-staging) - Convert input images to OME-Zarr with `bioformats2raw`
- [OME-TIFF conversion](#ome-tiff-conversion) - Convert staged OME-Zarr to OME-TIFF with `raw2ometiff`
- [Inference export scaffold](#inference-export-scaffold) - Produce mask and labelled-image OME-TIFF exports with a placeholder inference step
- [OMERO upload scaffold](#omero-upload-scaffold) - Emit OMERO upload manifests (or optionally perform upload)
- [FAIR metadata summary](#fair-metadata-summary) - Emit line-delimited JSON records for staged training inputs
- [Training scaffold outputs](#training-scaffold-outputs) - Structured stage contracts and reusable module artifacts for stages 1-6
- [Pipeline information](#pipeline-information) - Nextflow reports and collated software versions

## FAIR lifecycle mapping

| Current output artifact                             | Produced now                            | Downstream FAIR/ML lifecycle role                                                                               |
| --------------------------------------------------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `bioformats2raw/<sample>.ome.zarr/`                 | Conversion/storage and inference tracks | Standardised image representation; suitability for analysis depends on the downstream reader and preprocessing. |
| `metadata/fair_training_inputs.ndjson`              | Conversion/storage tracks               | Machine-readable provenance records linking sample IDs, optional OMERO IDs, staged paths, and data formats.     |
| `ometiff/`                                          | Conditional                             | Converted OME-TIFF files created by `raw2ometiff`.                                                              |
| `omero/`                                            | Conditional                             | JSON upload manifests (or live upload traces) for OMERO upload and metadata annotation.                         |
| `pipeline_info/` reports + `params.json`            | Yes                                     | Reproducibility and execution provenance (run parameters, software/report traceability).                        |
| `ro-crate-metadata.json` (repository root template) | Template present                        | Anchor metadata for future RO-Crate packaging of workflow artifacts.                                            |

### Bioimage staging

<details markdown="1">
<summary>Output files</summary>

- `bioformats2raw/<sample>.ome.zarr/` directories generated from input images

</details>

Staged OME-Zarr outputs are emitted from the `BIOFORMATS2RAW` process. Consumers
must support that representation; the current NuxNet/Nidavellir Tools dataset
reader needs paired OME-TIFF images and annotations, not these stores directly.

### OME-TIFF conversion

<details markdown="1">
<summary>Output files</summary>

- `ometiff/`
  - `<sample>.ome.tif` converted from staged OME-Zarr stores

</details>

OME-TIFF outputs are emitted from the `RAW2OMETIFF` process. They are produced in `--data_storage_mode generate_ometiff` and `--data_storage_mode full` runs.

### Inference export scaffold

<details markdown="1">
<summary>Output files</summary>

- `ometiff/`
  - `<sample>_mask.ome.tif` pass-through image with a placeholder mask suffix
  - `<sample>_labelled.ome.tif` pass-through image with a placeholder labelled suffix

</details>

The inference workflow now executes the following detailed sequence:

1. `BIOFORMATS2RAW`: convert each input image into `<sample>.ome.zarr`.
2. Inference placeholder scaffold: forward staged OME-Zarr into two semantic branches (`mask` and `labelled`).
3. `RAW2OMETIFF`: export branch outputs as `<sample>_mask.ome.tif` and `<sample>_labelled.ome.tif`.

The model inference stage is intentionally a placeholder pass-through and should be replaced by the real model runner in a follow-up change.

### OMERO upload scaffold

<details markdown="1">
<summary>Output files</summary>

- `omero/`
  - `<sample>_omero_upload.json` upload manifest / trace records

</details>

OMERO manifest outputs are produced in `--data_storage_mode full`. Live upload behaviour depends on OMERO credentials and `--omero_dry_run`.

### FAIR metadata summary

<details markdown="1">
<summary>Output files</summary>

- `metadata/`
  - `fair_training_inputs.ndjson`: line-delimited JSON records with sample ID, optional OMERO ID, staged dataset path, and data format.

</details>

This metadata summary is intended as machine-readable input for downstream RO-Crate and provenance packaging steps.

### Training scaffold outputs

The `--workflow_track training` path is now structurally wired as a six-stage DAG with deterministic contracts between stages:

1. Stage dataset from OMERO (placeholder descriptor).
2. Stage parent model from BioImage Model Zoo (structured artifact descriptor).
3. Cross-validation training scaffold (trained-model placeholder artifact contract).
4. Evaluation scaffold (metrics summary contract).
5. Publication scaffold (BioImage.IO publication-record contract).
6. RO-Crate packaging scaffold (RO-Crate artifact path contract).

In this repository revision, these are in-memory placeholder metadata contracts.
The training workflow does not write trained weights, evaluation results, a live
publication, or the ZIP named by its RO-Crate path string. Reusable local modules also exist for:

- BioImage.IO parent-model staging and publication-record generation.
- RO-Crate artifact construction with OMERO dataset/tag/server references, parent-model linkage, training hyperparameters, and publication identifiers.

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Nextflow execution reports such as `execution_report_<timestamp>.html`, `execution_timeline_<timestamp>.html`, `execution_trace_<timestamp>.txt`, and `pipeline_dag_<timestamp>.html`.
  - Collated software versions: `nf_core_nidavellir_mqc_versions.yml` (conversion/storage tracks).
  - Run parameters snapshot: `params_<timestamp>.json`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides rich execution and provenance reports that support reproducibility and troubleshooting.

## Planned outputs (roadmap)

The following artifact groups are expected as lifecycle components are added:

- **Training outputs (planned hardening)**: replace placeholder contracts with production training artifacts, fold metrics, and publication transactions.
- **Inference outputs (planned additions)**: production model predictions, confidence/uncertainty maps, and inference run manifests.
- **Data storage outputs (planned)**: OMERO synchronisation logs, object identifiers, and dataset-level annotation metadata.
- **RO-Crate packaging (partially implemented)**: local packaging module generates training RO-Crate artifacts; full end-to-end workflow wiring and release automation remain to be completed.
