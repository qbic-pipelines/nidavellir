# Graphical abstract

Asset: [nidavellir-graphical-abstract.png](nidavellir-graphical-abstract.png)

Created with the built-in image-generation tool using a user-supplied graphical
abstract as a visual reference. The original attachment is not redistributed.
Microscopy panels, heatmaps, and metric plots are schematic illustrations, not
experimental measurements. The image describes the target architecture; it does
not certify implemented integrations, standards compliance, or model performance.

The two incoming inference arrows deliberately distinguish image data from data
repositories and trained models from model repositories. The inference output
leads to expert review. Repository-to-training handoffs are summarized in text
to avoid crowded connector routing; see the README for their precise contracts.

## Initial generation brief

```text
Use case: infographic-diagram. Create a new polished version of the attached graphical abstract, using it as the composition and visual-style reference. Keep its white background, navy text, blue inference region, green storage/training regions, purple model repository region, scientific iconography, three-track architecture and central repositories, but simplify dense text for readability. Landscape 3:2, high-resolution. This is a conceptual TARGET architecture, not completed end-to-end software. Do not copy misleading edges.
Exact title "Nidavellir Data Engine"
Subtitle "FAIR-oriented bioimage learning with human-in-the-loop cycles"
Prominent status line "Target architecture · Nextflow integration in development"
Top left blue panel: "1  Inference" with three small stages "Prepare images" -> "Model + MC dropout" -> "Predictions + uncertainty". Below small "OME-Zarr conversion · use-case runner".
Top center human review block, linked from predictions: "Expert review" and "Correct / add spatial labels". Use stylized nuclei masks and heatmap inset.
Top right green panel "3  Data storage": stages "OME conversion" -> "Store in OMERO" -> "Images + labels + metadata"; small note "REMBI / MIFA-aligned curation".
Middle left blue repository box: "Data repositories" / "OMERO · BioImage Archive" / "OME-TIFF / OME-Zarr". Connect Expert review to Data storage, Data storage DOWN to Data repositories, Data repositories to inference and down to training dataset input. Do NOT connect curated data to model repositories.
Middle right purple repository box: "Model repositories" / "BioImage Model Zoo · Hugging Face" / "BioImage.IO packages + model cards". Arrow from this box to inference labelled "Inference model"; arrow DOWN to training parent input labelled "Parent model". Arrow from training publish step UP to model repositories labelled "Explicit publication". Route arrows cleanly outside panels with no ambiguous collisions.
Bottom broad green panel "2  Training and transfer learning". Five clearly labelled stages:
"Stage dataset" -> "Stage parent model" -> "Train / fine-tune" -> "Evaluate" -> "Package + validate".
Under Stage dataset: "Supported OME-TIFF layout".
Under Stage parent model: "Optional weight initialization".
Under Train / fine-tune: "NuxNet · PyTorch".
Under Evaluate: "Held-out metrics".
Under Package + validate: "BioImage.IO + provenance".
Add a small output block or label "Child package → next parent" and explicit publication connection to model repositories, conveying repeated parent-child runs. Place "Workflow RO-Crate (target)" as separate workflow output, not equivalent to model package.
Bottom three compact responsibility rows or strips:
"Nextflow: routes workflows, resources and artifacts"
"NuxNet: owns model and training logic; imports Nidavellir Tools"
"Nidavellir Tools: Python library + CLI; thin Nextflow wrappers planned"
Footer "MC dropout guides review; experts produce labels. Standards alignment is not full metadata compliance."
All labels spelled correctly (Nidavellir, NuxNet, BioImage.IO). Avoid uncertain logos, guarantees of accuracy, automated expert annotation, automatic Zoo acceptance, claim Zarr is loaded by current trainer, deterministic guarantees, DOI assigned automatically. No URLs or long bulleted paragraphs. Use calm gradients and rounded panels matching reference. Render new image, do not preserve incidental incorrect text or connectors.
```

## Final arrow correction prompt

Intermediate revisions simplified repository connectors and removed ambiguous
cross-panel arrows. The final targeted edit restored only the two inference inputs:

```text
Make one precise edit to this graphical abstract: add EXACTLY TWO incoming arrows into the blue "1 Inference" subworkflow, keeping its existing outgoing arrow to Expert review. Everything else must remain unchanged except moving/removing the left middle explanatory caption as needed for these two arrows.
Incoming arrow A: SOURCE is the LEFT EDGE of the blue "Data repositories" box (around x430 y500 in the 1536x1024 reference). Route LEFT into whitespace to x170, then UP, arrowhead entering the BOTTOM of the blue Inference panel below Prepare images (around x170 y416). Label "Image data". The arrow must visibly START at Data repositories, not at Model repositories.
Incoming arrow B: SOURCE is the TOP EDGE of the purple "Model repositories" box (around x850 y453). Route UP to the narrow whitespace at y433, then LEFT to x575, then UP with arrowhead entering the BOTTOM RIGHT of blue Inference panel around x575 y416. Label "Trained model" along the horizontal segment, readable without covering panels. The arrow must visibly START at Model repositories, not Data repositories. It must not touch Expert review or Data storage.
Replace or remove the old "Curated datasets feed training and inference" text only if needed to make room for arrow A and its label.
Preserve the existing single outgoing horizontal arrow from Inference to Expert review; no other incoming inference arrows or outgoing inference arrows.
Keep every other panel, icon, caption, stage, color and text unchanged, including no other repository cross-links. Review each arrow start/end carefully.
```
