#!/usr/bin/env python3

import argparse
import json
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List
from uuid import NAMESPACE_URL, uuid5


def _slug(value: str) -> str:
    return re.sub(r"[^a-zA-Z0-9._-]+", "-", value).strip("-") or "item"


def _is_uri(value: str) -> bool:
    return bool(re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*://", value) or value.startswith("urn:"))


def _as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def _entity_ref(entity_id: str) -> Dict[str, str]:
    return {"@id": entity_id}


def build_rocrate(metadata: Dict[str, Any], output_prefix: str) -> Dict[str, Any]:
    sample_id = metadata.get("sample_id") or output_prefix
    run = metadata.get("training_run") or {}
    run_id = run.get("id") or f"training-run-{sample_id}"
    crate_uuid = uuid5(NAMESPACE_URL, f"rocrate:{run_id}")
    crate_id = metadata.get("crate_id") or f"urn:uuid:{crate_uuid}"
    base_uri = metadata.get("base_uri") or f"https://example.org/rocrate/{crate_uuid}"

    crate_dir = Path(f"{output_prefix}_training_rocrate")
    crate_dir.mkdir(parents=True, exist_ok=True)

    root_data_entity = {
        "@id": "./",
        "@type": "Dataset",
        "name": f"Training RO-Crate for {sample_id}",
        "identifier": crate_id,
        "datePublished": datetime.now(timezone.utc).isoformat(),
        "hasPart": [],
    }

    graph: List[Dict[str, Any]] = [
        {
            "@id": "ro-crate-metadata.json",
            "@type": "CreativeWork",
            "conformsTo": {"@id": "https://w3id.org/ro/crate/1.1"},
            "about": {"@id": "./"},
        },
        root_data_entity,
    ]

    omero = metadata.get("omero") or {}
    dataset_entities = []
    image_entities = []
    server_entities = []
    tag_entities = []

    server_uris = [str(x) for x in _as_list(omero.get("server_uris")) if x]
    dataset_ids = [str(x) for x in _as_list(omero.get("dataset_ids")) if x]
    image_ids = [str(x) for x in _as_list(omero.get("image_ids")) if x]
    tags = [str(x) for x in _as_list(omero.get("tags")) if x]

    for server_uri in server_uris:
        server_entities.append(
            {
                "@id": server_uri,
                "@type": "DataCatalog",
                "name": f"OMERO server {server_uri}",
                "url": server_uri,
            }
        )

    for tag in tags:
        tag_id = f"{base_uri}#omero-tag-{_slug(tag)}"
        tag_entities.append(
            {
                "@id": tag_id,
                "@type": "DefinedTerm",
                "name": tag,
                "inDefinedTermSet": {"@id": f"{base_uri}#omero-tags"},
            }
        )

    for dataset_id in dataset_ids:
        entity_id = f"{base_uri}#omero-dataset-{_slug(dataset_id)}"
        dataset_entity = {
            "@id": entity_id,
            "@type": "Dataset",
            "name": f"OMERO Dataset {dataset_id}",
            "identifier": dataset_id,
            "isPartOf": [_entity_ref(uri) for uri in server_uris],
            "keywords": tags,
            "subjectOf": [_entity_ref(tag["@id"]) for tag in tag_entities],
        }
        dataset_entities.append(dataset_entity)

    fallback_server = server_uris[0] if server_uris else None
    for image_id in image_ids:
        image_entity_id = f"{base_uri}#omero-image-{_slug(image_id)}"
        image_entity = {
            "@id": image_entity_id,
            "@type": "ImageObject",
            "name": f"OMERO Image {image_id}",
            "identifier": image_id,
            "about": [_entity_ref(ds["@id"]) for ds in dataset_entities],
            "keywords": tags,
        }
        if fallback_server:
            image_entity["isPartOf"] = _entity_ref(fallback_server)
        image_entities.append(image_entity)

    parent_model = metadata.get("parent_model") or {}
    parent_model_id = parent_model.get("id") or f"{base_uri}#parent-model"
    parent_model_uri = parent_model.get("uri") or parent_model_id
    parent_model_version = parent_model.get("version")

    parent_model_entity = {
        "@id": parent_model_uri if _is_uri(str(parent_model_uri)) else f"{base_uri}#parent-model",
        "@type": "CreativeWork",
        "name": "Parent / pretrained model",
        "identifier": parent_model_id,
    }
    if parent_model_version:
        parent_model_entity["version"] = str(parent_model_version)

    trained_model = metadata.get("trained_model") or {}
    trained_model_id = trained_model.get("id") or f"{sample_id}-trained-model"
    trained_model_uri = trained_model.get("url") or trained_model.get("uri") or f"{base_uri}#trained-model"

    trained_model_entity = {
        "@id": trained_model_uri if _is_uri(str(trained_model_uri)) else f"{base_uri}#trained-model",
        "@type": "SoftwareApplication",
        "name": f"Trained model for {sample_id}",
        "identifier": trained_model_id,
        "isBasedOn": _entity_ref(parent_model_entity["@id"]),
        "derivedFrom": [_entity_ref(ds["@id"]) for ds in dataset_entities],
        "url": trained_model.get("url") or trained_model.get("uri"),
    }
    if trained_model.get("doi"):
        trained_model_entity["sameAs"] = f"https://doi.org/{trained_model['doi']}"

    publication = metadata.get("publication") or {}
    publication_identifier = publication.get("doi") or publication.get("id") or f"{base_uri}#publication"
    publication_entity = {
        "@id": publication.get("url") or (f"https://doi.org/{publication['doi']}" if publication.get("doi") else f"{base_uri}#publication"),
        "@type": "ScholarlyArticle",
        "name": publication.get("title") or f"Publication record for {sample_id} trained model",
        "identifier": publication_identifier,
        "about": _entity_ref(trained_model_entity["@id"]),
    }

    run_entity_id = f"{base_uri}#training-run-{_slug(run_id)}"
    framework = run.get("framework") or {}
    framework_entity_id = f"{base_uri}#framework-{_slug(str(framework.get('name') or 'framework'))}"
    framework_entity = {
        "@id": framework_entity_id,
        "@type": "SoftwareApplication",
        "name": framework.get("name") or "Training framework",
        "softwareVersion": framework.get("version") or "unknown",
    }

    run_entity = {
        "@id": run_entity_id,
        "@type": "CreateAction",
        "name": run.get("name") or f"Model training run {run_id}",
        "identifier": run_id,
        "instrument": _entity_ref(framework_entity_id),
        "object": [_entity_ref(parent_model_entity["@id"])] + [_entity_ref(ds["@id"]) for ds in dataset_entities],
        "result": _entity_ref(trained_model_entity["@id"]),
        "description": "Model training execution with dataset/model provenance.",
        "endTime": run.get("completed_at") or datetime.now(timezone.utc).isoformat(),
        "additionalProperty": [
            {
                "@type": "PropertyValue",
                "name": "hyperparameters",
                "value": run.get("hyperparameters") or {},
            },
            {
                "@type": "PropertyValue",
                "name": "cross_validation_scheme",
                "value": run.get("cv_scheme") or "unspecified",
            },
        ],
    }

    trained_model_entity["isBasedOn"] = _entity_ref(parent_model_entity["@id"])
    trained_model_entity["derivedFrom"] = [_entity_ref(ds["@id"]) for ds in dataset_entities] + [
        _entity_ref(img["@id"]) for img in image_entities
    ]
    trained_model_entity["subjectOf"] = _entity_ref(publication_entity["@id"])

    graph.extend(server_entities)
    graph.extend(tag_entities)
    graph.extend(dataset_entities)
    graph.extend(image_entities)
    graph.extend([parent_model_entity, framework_entity, run_entity, trained_model_entity, publication_entity])

    root_data_entity["hasPart"].extend([_entity_ref(entity["@id"]) for entity in dataset_entities])
    root_data_entity["hasPart"].append(_entity_ref(trained_model_entity["@id"]))
    root_data_entity["mentions"] = [_entity_ref(run_entity_id), _entity_ref(parent_model_entity["@id"])]

    rocrate_metadata = {
        "@context": "https://w3id.org/ro/crate/1.1/context",
        "@graph": graph,
    }

    metadata_path = crate_dir / "ro-crate-metadata.json"
    metadata_path.write_text(json.dumps(rocrate_metadata, indent=2), encoding="utf-8")

    zip_output = bool(metadata.get("zip_output", True))
    artifact_path: Path
    crate_format: str
    if zip_output:
        archive_base = str(crate_dir)
        zip_file = Path(shutil.make_archive(archive_base, "zip", root_dir=str(crate_dir.parent), base_dir=crate_dir.name))
        artifact_path = zip_file
        crate_format = "zip"
    else:
        artifact_path = crate_dir
        crate_format = "directory"

    summary = {
        "sample_id": sample_id,
        "crate_identifier": crate_id,
        "artifact_path": str(artifact_path),
        "crate_format": crate_format,
        "training_run": run_entity_id,
        "dataset_count": len(dataset_entities),
        "image_count": len(image_entities),
        "omero_server_count": len(server_entities),
        "trained_model": trained_model_entity["@id"],
        "parent_model": parent_model_entity["@id"],
        "publication": publication_entity["@id"],
    }

    return {
        "summary": summary,
        "artifact_path": artifact_path,
        "crate_dir": crate_dir,
        "crate_format": crate_format,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate RO-Crate metadata for a training run.")
    parser.add_argument("--metadata-json", required=True, help="Path to input metadata JSON")
    parser.add_argument("--output-prefix", required=True, help="Prefix for output files")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    metadata = json.loads(Path(args.metadata_json).read_text(encoding="utf-8"))
    result = build_rocrate(metadata=metadata, output_prefix=args.output_prefix)

    prefix = args.output_prefix
    summary_path = Path(f"{prefix}_training_rocrate_summary.json")
    summary_path.write_text(json.dumps(result["summary"], indent=2), encoding="utf-8")

    artifact_path_file = Path(f"{prefix}_training_rocrate_artifact_path.txt")
    artifact_path_file.write_text(f"{result['artifact_path']}\n", encoding="utf-8")


if __name__ == "__main__":
    main()
