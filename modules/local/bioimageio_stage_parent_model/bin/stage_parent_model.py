#!/usr/bin/env python3
"""Stage a parent BioImage.io model by ID/DOI/URI and emit deterministic JSON."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
from pathlib import Path
from typing import Any
from urllib.parse import urlparse


DETERMINISTIC_KEYS = [
    "status",
    "parent_ref",
    "resolved_source",
    "staged_path",
    "descriptor",
    "error",
]


def _default_record(parent_ref: str | None) -> dict[str, Any]:
    return {
        "status": "error",
        "parent_ref": parent_ref,
        "resolved_source": None,
        "staged_path": None,
        "descriptor": {
            "id": None,
            "uri": None,
            "doi": None,
            "sha256": None,
        },
        "error": "unknown error",
    }


def _write_record(path: Path, record: dict[str, Any]) -> None:
    ordered_record = {k: record.get(k) for k in DETERMINISTIC_KEYS}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(ordered_record, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def _parse_ref(parent_ref: str) -> tuple[str | None, str | None, str | None]:
    ref = parent_ref.strip()
    if not ref:
        return None, None, None

    if ref.lower().startswith("doi:") or "doi.org/" in ref.lower():
        doi = ref.removeprefix("doi:")
        return None, doi, ref

    parsed = urlparse(ref)
    if parsed.scheme in {"http", "https", "s3", "file"}:
        return None, None, ref

    return ref, None, None


def _load_with_bioimageio(model_id: str | None, doi: str | None, uri: str | None) -> tuple[str, str | None, dict[str, Any]]:
    target = uri or (f"doi:{doi}" if doi else model_id)
    if not target:
        raise ValueError("No BioImage.io model target was provided.")

    try:
        from bioimageio.spec import load_description
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(
            "Missing BioImage.io dependency. Install `bioimageio.spec` (or a compatible BioImage.io client) in the runtime environment."
        ) from exc

    desc = load_description(target)
    desc_path = getattr(desc, "original_file_name", None) or getattr(desc, "source", None)
    resolved_uri = str(desc_path) if desc_path is not None else str(target)

    descriptor = {
        "id": getattr(desc, "id", None),
        "uri": resolved_uri,
        "doi": doi,
        "sha256": None,
    }

    return str(target), str(desc_path) if desc_path else None, descriptor


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--parent-ref", help="Parent model reference (ID, DOI, or URI).")
    parser.add_argument("--model-id", help="BioImage.io model ID.")
    parser.add_argument("--doi", help="Model DOI, with or without doi: prefix.")
    parser.add_argument("--uri", help="Model URI (http(s), s3, file).")
    parser.add_argument("--output", required=True, help="Output JSON path.")
    parser.add_argument("--staging-dir", default=".", help="Directory where staged material is stored.")
    args = parser.parse_args()

    output_path = Path(args.output)
    record = _default_record(args.parent_ref)

    try:
        model_id = args.model_id
        doi = args.doi
        uri = args.uri

        if args.parent_ref and not any([model_id, doi, uri]):
            model_id, doi, uri = _parse_ref(args.parent_ref)

        if not any([model_id, doi, uri]):
            raise ValueError(
                "Missing required parent model reference. Provide one of --parent-ref, --model-id, --doi, or --uri."
            )

        target, source_path, descriptor = _load_with_bioimageio(model_id, doi, uri)
        record["parent_ref"] = target
        record["resolved_source"] = descriptor["uri"]
        record["descriptor"] = descriptor

        if source_path:
            src = Path(source_path)
            if src.exists() and src.is_file():
                staging_dir = Path(args.staging_dir)
                staging_dir.mkdir(parents=True, exist_ok=True)
                staged = staging_dir / src.name
                if src.resolve() != staged.resolve():
                    shutil.copy2(src, staged)
                descriptor["sha256"] = _sha256(staged)
                record["staged_path"] = str(staged.resolve())
            elif src.exists() and src.is_dir():
                record["staged_path"] = str(src.resolve())

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
