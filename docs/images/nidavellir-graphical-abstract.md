# Graphical abstract

Asset: [nidavellir-graphical-abstract.png](nidavellir-graphical-abstract.png)

Created with the built-in image-generation tool using a user-supplied graphical
abstract as a visual reference. The original attachment is not redistributed.
Microscopy panels, heatmaps, and metric plots are schematic illustrations, not
experimental measurements. The image describes the target architecture; it does
not certify implemented integrations, standards compliance, or model performance.

The two incoming inference arrows deliberately distinguish image data from data
repositories and trained models from model repositories. The inference output
leads to expert review. Storage returns curated images and labels to the data
repositories. Separate arrows carry training datasets and parent weights into
their respective staging steps; child packages return to model repositories.
The green/purple crossing is not a connection. See the README for the precise
artifact contracts and implementation status.

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

## Restore training and storage connections

```text
Edit the supplied graphical abstract to RESTORE four missing arrows for workflows 2 and 3 while preserving the corrected inference connections EXACTLY. Keep panels, contents, colors, text and icons. You may increase vertical spacing between panels to route arrows cleanly.
KEEP these existing three arrows: Data repositories -> Inference labelled Image data; Model repositories -> Inference labelled Trained model; Inference -> Expert review. KEEP Expert review -> Data storage. Keep all internal arrows.

ADD precisely these four directed connectors:
A. Data storage panel -> Data repositories box. Label "Curated images + labels". Source is lower edge of GREEN Data storage; destination arrowhead is upper edge of BLUE Data repositories, NOT Model repositories. Route an elbow path through the middle white space. If crossing another line is unavoidable, use a visible bridge crossing WITHOUT a junction dot. This line must not terminate in or connect to purple Model repositories.
B. Data repositories -> Stage dataset card in training. Label "Training dataset". Start at bottom-left of Data repositories; route LEFT along whitespace below the repository then DOWN. Arrowhead must enter top of FIRST training card Stage dataset, NOT second Stage parent model. Do not run through training heading text.
C. Model repositories -> Stage parent model card in training. Label "Parent weights". Start at bottom of purple Model repositories, route LEFT along a SEPARATE whitespace lane between repositories and training, then DOWN with arrowhead entering SECOND training card Stage parent model. Never connect it to Evaluate or dataset card. No arrowhead toward Model repositories on this line. Can increase whitespace before training and move heading slightly to avoid line/text collisions.
D. Child package output in training -> Model repositories. Label "Publish child model". Start from RIGHT edge of Child package output; route RIGHT then UP along far-right margin then LEFT with arrowhead entering RIGHT edge of purple Model repositories. Keep child package -> next parent wording. Move/remove standalone "Publish child packages; reuse as parent models" caption to provide room for this line and label.

Exact endpoint accuracy is more important than similarity of placement. There are now 8 inter-panel directed connections total: two inference inputs; inference to expert; expert to storage; storage to data repository; data to training dataset; model to training parent; child model to model repository. Do not add any others. Draw arrowheads only at destinations. Preserve all existing content and status caveats. Make routing readable.
```

## Endpoint correction

```text
Make ONLY these three small connector corrections to the attached image. Preserve ALL other arrows, panels, labels and contents exactly:
1) Restore missing trained-model input to inference. Draw a PURPLE arrow starting at top of Model repositories box near x870 y465, going UP to y398, then LEFT to x613 with arrowhead pointing LEFT into right edge of blue Inference panel near its lower-right corner y398. Label "Trained model" along horizontal segment y398 above it (around x730 y390). This must start from Model repositories and end in Inference, NOT expert review. At crossing with green curated-data line near y439 use a small bridge/hop and no junction dot. Keep the green curated-data arrow intact.
2) Blue Training dataset arrow currently ends at x255 y680 on heading. Move only its final vertical leg LEFT to x135 and extend it DOWN to y724 so arrowhead points into TOP of FIRST card "Stage dataset". Route the elbow left from Data repositories at y558 to x135, and then down. It will cross the heading row around x135; shift "Training and transfer learning" heading right to x290 if needed to avoid collision.
3) Purple Parent weights arrow currently enters THIRD training card Train/fine-tune. Move only its last vertical leg from x525 to x380; point arrowhead DOWN into TOP of SECOND card "Stage parent model" at x380 y724. Keep source at Model repositories and label Parent weights. Route last segment behind no text: leave a whitespace gap in training heading or place heading at x540 if necessary.
Critical: no existing arrows may be deleted. Inference must have BOTH image-data input and trained-model input plus outgoing expert-review arrow. Keep storage->data repo, child package->model repo, all internal arrows. Rendering of arrow endpoints is the only goal.
```

## Final visual cleanup

```text
Only fix two visual overlaps in this image. Do not change any arrow endpoints or delete any lines.
1. Move heading "Training and transfer learning" from x165 y700 to x550 y700, within the same green header band, so purple parent-weights vertical line at x470 no longer crosses the heading. Keep numbered circle 2 where it is.
2. Where the purple Trained model vertical arrow crosses the green Curated images + labels horizontal line (approximately x899 y439), add a small bridge/hop or white line break to show the two paths are NOT connected. Move label "Curated images + labels" to right along its green line, centered around x1090 y425, so the purple vertical does not cross this label.
Preserve all other text, panels, icons, arrows, colors, geometry and all eight cross-panel connector endpoints exactly. No additional arrows.
```
