# nf-core/nidavellir: Usage

## :warning: Please read this documentation on the nf-core website: [https://nf-co.re/nidavellir/usage](https://nf-co.re/nidavellir/usage)

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Introduction

`nf-core/nidavellir` currently provides an MVP FAIR bioimage staging workflow. It validates an image-centric samplesheet, converts source images to OME-Zarr with `bioformats2raw`, and writes machine-readable metadata records for downstream provenance packaging.

## Samplesheet input

Provide a comma-separated samplesheet with the required columns `sample,image_path` and optional `omero_id`:

```bash
--input '[path to samplesheet file]'
```

### Required / optional columns

| Column       | Required | Description |
| ------------ | -------- | ----------- |
| `sample`     | Yes      | Unique sample identifier. Spaces are not allowed. |
| `image_path` | Yes      | Absolute or relative path to a Bio-Formats compatible image file to stage. |
| `omero_id`   | No       | Upstream OMERO identifier (for example `OMERO:Image:123`) recorded for provenance. |

Example:

```csv title="samplesheet.csv"
sample,image_path,omero_id
cell_001,/data/images/cell_001.ome.tiff,OMERO:Image:123
cell_002,/data/images/cell_002.czi,
```

An [example samplesheet](../assets/samplesheet.csv) is included in this repository.

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run nf-core/nidavellir --input ./samplesheet.csv --outdir ./results -profile docker
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the Nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other Nextflow hidden files, e.g. run history and old logs.
```

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

> [!WARNING]
> Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), other infrastructural tweaks (such as output directories), or module arguments (args).

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run nf-core/nidavellir -profile docker -params-file params.yaml
```

with:

```yaml title="params.yaml"
input: './samplesheet.csv'
outdir: './results/'
<...>
```

You can also generate such `YAML`/`JSON` files via [nf-core/launch](https://nf-co.re/launch).

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. To make sure that you're running the latest version of the pipeline, update the cached version regularly:

```bash
nextflow pull nf-core/nidavellir
```

### Reproducibility

For reproducibility, specify a pipeline release/tag and archive run artifacts (`pipeline_info/`, params, and metadata outputs).

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
NXF_OPTS='-Xms1g -Xmx4g'
```
