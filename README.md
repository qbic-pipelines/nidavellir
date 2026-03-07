<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/nf-core-nidavellir_logo_dark.png">
    <img alt="nf-core/nidavellir" src="docs/images/nf-core-nidavellir_logo_light.png">
  </picture>
</h1>

[![GitHub Actions CI Status](https://github.com/nf-core/nidavellir/actions/workflows/ci.yml/badge.svg)](https://github.com/nf-core/nidavellir/actions/workflows/ci.yml)
[![GitHub Actions Linting Status](https://github.com/nf-core/nidavellir/actions/workflows/linting.yml/badge.svg)](https://github.com/nf-core/nidavellir/actions/workflows/linting.yml)[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/nidavellir/results)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A524.04.2-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-3.5.2-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/3.5.2)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/nf-core/nidavellir)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23nidavellir-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/nidavellir)[![Follow on Bluesky](https://img.shields.io/badge/bluesky-%40nf__core-1185fe?labelColor=000000&logo=bluesky)](https://bsky.app/profile/nf-co.re)[![Follow on Mastodon](https://img.shields.io/badge/mastodon-nf__core-6364ff?labelColor=FFFFFF&logo=mastodon)](https://mstdn.science/@nf_core)[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

**nf-core/nidavellir** is a Nextflow / nf-core workflow system for FAIR and reproducible bioimage machine learning pipelines.

### Current implemented capabilities (MVP)

This repository currently provides an initial staging workflow that standardises microscopy image inputs into **OME-Zarr** and writes structured metadata for downstream provenance and RO-Crate packaging.

Default implemented steps include:

1. Read a bioimage training samplesheet and stage image inputs.
2. Convert source images to **OME-Zarr** using `bioformats2raw`.
3. Write machine-readable training-input metadata (`fair_training_inputs.ndjson`).
4. Track software versions for reproducibility.

### Target full lifecycle architecture

Nidavellir is being developed as a modular system that covers the full ML lifecycle for microscopy and medical imaging segmentation.

- **Training pipeline**
  - Stage datasets from OMERO
  - Stage pretrained models (BioImage Model Zoo)
  - Run cross-validation training (for example PyTorch models such as U-Net)
  - Evaluate model performance
  - Publish trained models
  - Package outputs as FAIR RO-Crate artifacts with full provenance
- **Inference pipeline**
  - Convert images to OME-Zarr (NGFF)
  - Run model inference
  - Export segmentation masks and labelled images
- **Data storage pipeline**
  - Store images and labels in OMERO
  - Annotate datasets with metadata

The architecture supports human-in-the-loop learning workflows where corrected predictions are persisted as new training data.

> [!NOTE]
> Some lifecycle components described above are planned and may not yet be implemented in the current release.

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet with your input image data:

`samplesheet.csv`:

```csv
sample,image_path,omero_id
cell_001,/data/images/cell_001.ome.tiff,OMERO:Image:123
cell_002,/data/images/cell_002.czi,
```

Required columns:
- `sample`: Unique sample identifier.
- `image_path`: Local path to an input image file supported by Bio-Formats.

Optional columns:
- `omero_id`: Upstream OMERO object identifier for provenance tracking.

Now, you can run the pipeline using:

```bash
nextflow run nf-core/nidavellir \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/nidavellir/usage) and the [parameter documentation](https://nf-co.re/nidavellir/parameters).

### Workflow track selection

Use `--workflow_track` to select the high-level flow:

- `data_storage`: data storage flow (supports `--data_storage_mode full|generate_ometiff`)
- `generate_ometiff`: conversion-only shortcut (`bioformats2raw -> raw2ometiff`)
- `training`: scaffold track (stage plan logged; implementation pending)
- `inference`: implemented conversion/export scaffold (`bioformats2raw -> [placeholder inference] -> raw2ometiff` for mask + labelled outputs)

`--pipeline_track` is retained as a backward-compatible alias. If both are set, `--workflow_track` takes precedence.

### Inference pipeline (current implementation details)

The `inference` track currently executes a concrete conversion + export path and a clearly marked model-inference placeholder:

1. **Input staging to OME-Zarr** (`BIOFORMATS2RAW`)
   - Converts each input image into `<sample>.ome.zarr` for analysis-friendly NGFF representation.
2. **Model inference placeholder scaffold**
   - Temporary pass-through that duplicates each staged OME-Zarr into two channels representing:
     - segmentation mask export (`output_suffix: mask`)
     - labelled image export (`output_suffix: labelled`)
   - This is a deliberate scaffold and should be replaced by a real model runner in a follow-up update.
3. **OME-TIFF exports** (`RAW2OMETIFF`)
   - Produces `<sample>_mask.ome.tif` and `<sample>_labelled.ome.tif`.

To run this track:

```bash
nextflow run nf-core/nidavellir \
  --input ./samplesheet.csv \
  --outdir ./results \
  --workflow_track inference \
  -profile docker
```


## Pipeline output

To see the results of an example test run with a full size dataset refer to the [results](https://nf-co.re/nidavellir/results) tab on the nf-core website pipeline page.
For more details about the output files and reports, please refer to the
[output documentation](https://nf-co.re/nidavellir/output).

## Credits

nf-core/nidavellir was originally written by Luis Kuhn Cuellar, Carolin Schwitalla, Sabrina Krakau.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#nidavellir` channel](https://nfcore.slack.com/channels/nidavellir) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use nf-core/nidavellir for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
