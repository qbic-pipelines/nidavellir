# Graphical abstract

[View the graphical abstract](nidavellir-graphical-abstract.png).

## Scope and visual language

This is the **target architecture**, not a claim that every step is implemented
in the Nextflow pipeline. The README's implementation-status table is authoritative.
Track numbers identify subworkflows, not execution order or software layers.

The flat metro-style layout is inspired by the
[nf-core/mcmicro diagram](https://nf-co.re/mcmicro/2.0.0/).
Small entity marks identify OMERO, OME-TIFF, OME-Zarr, BioImage Model Zoo, and
Hugging Face. These generated marks are illustrative, not canonical brand assets
or an assertion of endorsement.

## Track order

1. **Inference:** prepare images → predict with optional MC dropout →
   predictions and uncertainty → expert review.
2. **Training and transfer learning:** stage dataset → optionally stage parent
   model → train/fine-tune → evaluate → package and validate → child model package.
   A workflow RO-Crate is a separate target output, not the model package itself.
3. **Data storage:** OME conversion →
   **Structure curated images + metadata files (BioImage Archive format)** →
   **Push + annotate (OMERO-Bifrost)**.

BioImage Archive-style file preparation is planned. It does not mean automatic
submission to the archive; the final push step targets OMERO.

## Connector contract

- Data repositories → inference: image data.
- Model repositories → inference: trained model.
- Inference → expert review: predictions and optional uncertainty.
- Expert review → data storage: corrected images/labels and metadata.
- Final OMERO push/annotation step → data repositories: curated images and labels.
- Data repositories → training: training dataset.
- Model repositories → parent-model staging: parent weights.
- Child model package → model repositories: publication.

OMERO-Bifrost serves the **OMERO portion** of the data-repository layer.
BioImage Archive is a separate repository, not an OMERO endpoint. Bifrost supports
federated OMERO constellations through Python APIs or profile-specific Nextflow
tasks; each CLI invocation selects one server profile.

## Asset provenance

Created and edited with the built-in image-generation tool using the user's
supplied reference, then visually reviewed. The original reference is not
redistributed here. Earlier prompts and design iterations remain in Git history.

The final edit moved **Push + annotate (OMERO-Bifrost)** to the last storage
station and renamed the middle station to the BioImage Archive-format structuring
step. The return connector now originates at the final push station. All inference,
training, repository, and expert-review connections were retained.
