#!/usr/bin/env python3
"""Publish/register a trained model package and emit deterministic JSON."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


DETERMINISTIC_KEYS = [
    "status",
    "source_package",
    "publication",
    "error",
]


def _default_record() -> dict[str, Any]:
    return {
        "status": "error",
        "source_package": None,
        "publication": {
            "zoo_id": None,
            "concept_doi": None,
            "record_doi": None,
            "url": None,
            "raw_response": None,
        },
        "error": "unknown error",
    }


def _write_record(path: Path, record: dict[str, Any]) -> None:
    ordered_record = {k: record.get(k) for k in DETERMINISTIC_KEYS}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(ordered_record, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def _load_metadata(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise ValueError(f"Trained model metadata file does not exist: {path}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise ValueError(f"Invalid JSON in trained model metadata: {path}") from exc


def _resolve_package(metadata: dict[str, Any], explicit_package: str | None) -> str:
    package = explicit_package or metadata.get("package_path") or metadata.get("model_package") or metadata.get("uri")
    if not package:
        raise ValueError(
            "Missing package reference. Provide --package or include one of: package_path, model_package, uri in metadata JSON."
        )
    return str(package)


def _publish_with_bioimageio(package_ref: str, dry_run: bool) -> dict[str, Any]:
    try:
        from bioimageio.spec import load_description
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(
            "Missing BioImage.io dependency. Install `bioimageio.spec` (or a compatible BioImage.io client) in the runtime environment."
        ) from exc

    # Validate that the package is parseable by BioImage.io tooling.
    _ = load_description(package_ref)

    if dry_run:
        return {
            "zoo_id": None,
            "concept_doi": None,
            "record_doi": None,
            "url": None,
            "raw_response": {"mode": "dry-run", "validated": True},
        }

    # Actual publication APIs vary by deployment/credentials. Keep an extensible path.
    # If no publisher client is installed/configured, return a clear failure message.
    try:
        from bioimageio.core import __version__ as _core_version  # noqa: F401
    except Exception:
        pass

    raise RuntimeError(
        "No publish client configured for this environment. Run with --dry-run for validation only, "
        "or extend this script with your deployment-specific BioImage.io publication API integration."
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--trained-model-metadata", required=True, help="JSON metadata for the trained model package.")
    parser.add_argument("--package", help="Explicit package reference to publish (path/URI).")
    parser.add_argument("--output", required=True, help="Output JSON path.")
    parser.add_argument("--dry-run", action="store_true", help="Validate only; do not attempt remote publication.")
    args = parser.parse_args()

    output_path = Path(args.output)
    record = _default_record()

    try:
        metadata = _load_metadata(Path(args.trained_model_metadata))
        package_ref = _resolve_package(metadata, args.package)

        record["source_package"] = package_ref
        publication = _publish_with_bioimageio(package_ref, args.dry_run)

        record["publication"] = publication
        record["status"] = "ok"
        record["error"] = None
        _write_record(output_path, record)
        return 0

    except Exception as exc:  # noqa: BLE001
        record["status"] = "error"
        record["error"] = str(exc)
        _write_record(output_path, record)
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
