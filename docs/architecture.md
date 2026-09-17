# Nidavellir: Architecture

## System overview

Nidavellir is a Nextflow / nf-core based workflow system for FAIR and reproducible bioimage machine learning pipelines. The long-term architecture is split into three connected workflow tracks:

1. **Inference pipeline**
2. **Training and transfer-learning pipeline**
3. **Data storage pipeline**

Each track is designed to exchange machine-readable outputs (for example OME-Zarr data, model/publication descriptors, and RO-Crate metadata) to support provenance tracking and iterative model improvement.

## Technology stack

| Technology                                                                    | Role in Nidavellir                                                                                                                    |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Nextflow                                                                      | Workflow orchestration and scalable execution on local/HPC/cloud platforms.                                                           |
| nf-core                                                                       | Pipeline standards, community conventions, schema-driven parameters, and reusable modules.                                            |
| OMERO                                                                         | Image and annotation management for staging training data and writing curated labels/metadata back to storage.                        |
| [OMERO Bifrost](https://github.com/luiskuhn/omero-bifrost/tree/forward-cycle) | Nidavellir companion providing Nextflow-ready query/push/pull operations for single OMERO servers and federated OMERO constellations. |
| OME-Zarr (NGFF)                                                               | Cloud- and analysis-friendly image format for staged training/inference inputs and downstream interoperability.                       |
| PyTorch                                                                       | Deep-learning framework for model training and evaluation (for example segmentation models such as U-Net).                            |
| BioImage Model Zoo                                                            | Source for pretrained models and destination for publishing validated model artifacts.                                                |
| RO-Crate                                                                      | FAIR packaging layer for data/model/provenance outputs with machine-readable metadata.                                                |

## Workflow tracks

### Federated repository access through OMERO Bifrost

OMERO Bifrost is part of the Nidavellir ecosystem and is designed for integration
with Nextflow/nf-core, including this pipeline. It supplies the remote-repository
boundary; trainers and Nidavellir Tools work on staged artifacts rather than
embedding institution-specific server logic. A constellation is a collection of
independent OMERO endpoints with separate credentials, group scopes, and access
policies—not automatic cross-site replication or a shared authorization domain.

On the linked `forward-cycle` branch, the CLI targets one profile per invocation.
Bifrost's Python federation APIs support multi-server operations; alternatively,
Nextflow can dispatch one task per selected profile. Downstream records must
retain the server profile together with each local object ID, plus provenance
and failure information. Keep secrets out of channels and published metadata.

The intended connections are:

- Query/pull image data for inference and image/annotation pairs for training.
- Push curated outputs and metadata back to explicitly selected OMERO sites.
- Keep BioImage Archive access separate; it is not an OMERO constellation member.
- Keep model-registry staging in Nidavellir Tools; Bifrost supplies image data,
  not the inference model.

Current pipeline upload still uses the OMERO CLI directly. Bifrost wrappers and
constellation-aware workflow channels remain integration work. See the
[README federation section](../README.md#omero-bifrost-and-federated-constellations),
[Bifrost architecture](https://github.com/luiskuhn/omero-bifrost/blob/forward-cycle/docs/architecture.md),
and [Nextflow integration guide](https://github.com/luiskuhn/omero-bifrost/blob/forward-cycle/docs/nextflow-nfcore.md).

### Training pipeline

Intended capabilities:

- Stage datasets and an optional compatible parent model.
- Train/fine-tune with the selected use-case application and evaluate held-out performance.
- Build and validate a BioImage.IO child model package with Nidavellir Tools.
- Optionally publish to a model repository and reuse the package as the next parent.
- Collect workflow-level provenance in a separate RO-Crate.

This is the target sequence in the graphical abstract, not the current six-stage
placeholder implementation. See the [README](../README.md#target-full-lifecycle-architecture).

### Inference pipeline

Current capabilities (partial implementation):

- Convert input images to OME-Zarr (NGFF) using `bioformats2raw`.
- Execute a **placeholder scaffold** for model inference (explicit pass-through hook).
- Export pass-through images to OME-TIFF using `raw2ometiff`; the mask/labelled
  filenames are placeholders, not actual segmentations or scientific predictions.

Design notes:

- The placeholder isolates the intended inference boundary. A real runner must
  still implement compatible input/output contracts and any required format adapters.
- Export branches use suffix-aware naming (`_mask`, `_labelled`) to keep artefacts distinct per sample.

### Data storage pipeline

Intended capabilities:

1. Convert images to the required OME representation.
2. Structure curated images and metadata files in the supported BioImage Archive-style layout.
3. Push and annotate in selected OMERO servers through OMERO-Bifrost.

The middle stage is planned dataset/metadata preparation, not a general Archive
submission validator or uploader. Bifrost's final step targets OMERO; BioImage
Archive is a separate source/destination. Current code implements conversion and
a direct-OMERO-CLI upload manifest path, not this complete target sequence.

## Human-in-the-loop learning

Nidavellir is designed to support human-in-the-loop workflows: corrected predictions from inference can be written back as curated labels and reused as new training data in subsequent training cycles.

## Implementation status

- **Implemented / partially implemented**: Data storage track with conversion (`bioformats2raw -> raw2ometiff`), FAIR training-input metadata export, and OMERO upload scaffold (manifest-first; optional live upload).
- **Scaffolded / structurally wired**: `training` track now runs an explicit six-stage DAG with stable inter-stage contracts and placeholder internals for model execution logic.
- **Partially implemented**: `inference` track with OME-Zarr conversion and OME-TIFF export plus model-step placeholder scaffold.
- **Planned**: Full production training/evaluation execution, live model publication integration, end-to-end module wiring for all training artifacts, production inference engines/manifests, and richer OMERO write-back workflows.
