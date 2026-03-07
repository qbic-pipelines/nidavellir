# nf-core/nidavellir: Architecture

## System overview

Nidavellir is a Nextflow / nf-core based workflow system for FAIR and reproducible bioimage machine learning pipelines. The long-term architecture is split into three connected workflow tracks:

1. **Training pipeline**
2. **Inference pipeline**
3. **Data storage pipeline**

Each track is designed to exchange machine-readable outputs (for example OME-Zarr data and metadata records) to support provenance tracking and iterative model improvement.

## Technology stack

| Technology | Role in Nidavellir |
| ---------- | ------------------ |
| Nextflow | Workflow orchestration and scalable execution on local/HPC/cloud platforms. |
| nf-core | Pipeline standards, community conventions, schema-driven parameters, and reusable modules. |
| OMERO | Image and annotation management for staging training data and writing curated labels/metadata back to storage. |
| OME-Zarr (NGFF) | Cloud- and analysis-friendly image format for staged training/inference inputs and downstream interoperability. |
| PyTorch | Deep-learning framework for model training and evaluation (for example segmentation models such as U-Net). |
| BioImage Model Zoo | Source for pretrained models and destination for publishing validated model artifacts. |
| RO-Crate | FAIR packaging layer for data/model/provenance outputs with machine-readable metadata. |

## Workflow tracks

### Training pipeline

Intended capabilities:

- Stage datasets from OMERO.
- Stage pretrained models from BioImage Model Zoo.
- Run cross-validation training (for example PyTorch segmentation models).
- Evaluate model performance.
- Publish trained models.
- Package results as FAIR RO-Crate artifacts with full provenance.

### Inference pipeline

Intended capabilities:

- Convert images to OME-Zarr (NGFF).
- Run model inference.
- Export segmentation masks and labelled images.

### Data storage pipeline

Intended capabilities:

- Store images and labels in OMERO.
- Annotate datasets with metadata.

## Human-in-the-loop learning

Nidavellir is designed to support human-in-the-loop workflows: corrected predictions from inference can be written back as curated labels and reused as new training data in subsequent training cycles.

## Implementation status

- **Implemented / partially implemented**: Data storage track with conversion (`bioformats2raw -> raw2ometiff`), FAIR training-input metadata export, and OMERO upload scaffold (manifest-first; optional live upload).
- **Scaffolded**: `training` and `inference` tracks are selectable and currently emit stage-plan logs only.
- **Planned**: Full lifecycle components for training/evaluation/publication, inference outputs, and richer OMERO write-back workflows.
