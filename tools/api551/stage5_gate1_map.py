#!/usr/bin/env python3
"""Build the API 551 Stage 5 Gate 1 source map from the verified source PDF.

The rendered page is the primary OCR source. The embedded PDF text layer is
used only for secondary comparison and QA metrics.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import math
import os
import re
import statistics
import subprocess
import sys
from collections import Counter, defaultdict
from concurrent.futures import ProcessPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import fitz
import pdfplumber


SCHEMA_VERSION = "1.0"
DEFAULT_DPI = 150
DEFAULT_CHUNK_SIZE = 16
TOKEN_RE = re.compile(r"[A-Za-z0-9]+(?:[./+\-][A-Za-z0-9]+)*")
FIGURE_CAPTION_RE = re.compile(r"^\s*Figure\s+(\d+)\s*[—–-]\s*(.+)", re.I)
TABLE_CAPTION_RE = re.compile(
    r"^\s*Table\s+([A-Z]?\d+(?:\.\d+)?)\s*[—–-]\s*(.+?)(?:\s*\(Continued\))?\s*$",
    re.I,
)
NOTE_RE = re.compile(r"^\s*NOTE(?:\s+(\d+))?\b[:.\s—–-]*(.*)", re.I)
NUMBERED_SECTION_RE = re.compile(
    r"^\s*(\d+(?:\.\d+){0,5})\s+([A-Z][A-Za-z]{2,})(?:\s|$)"
)
SPECIAL_SECTION_RE = re.compile(
    r"^\s*(Annex\s+[A-Z]|Bibliography|Contents|Foreword|Introduction|Scope)\b",
    re.I,
)
LIST_RE = re.compile(r"^\s*(?:[•●▪◦\-–—]|[a-z]\)|\([a-z]\)|\d+\)|\(\d+\))\s+", re.I)
REF_RE = re.compile(
    r"\b(Figure|Table|Section|Clause|Annex)\s+([A-Z]?\d+(?:\.\d+)*|[A-Z])\b",
    re.I,
)
REPEAT_HEADER_RE = re.compile(
    r"^(?:\d+\s+)?(?:API\s+RECOMMENDED\s+PRACTICE\s+551|PROCESS\s+MEASUREMENT)(?:\s+\d+)?$",
    re.I,
)
CONTROL_RE = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f]")

_DOC: fitz.Document | None = None
_PDF_PATH = ""
_DPI = DEFAULT_DPI
_TESS_ENV: dict[str, str] = {}


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def clean_text(text: str) -> str:
    text = CONTROL_RE.sub("�", text)
    return re.sub(r"\s+", " ", text).strip()


def tokens(text: str) -> list[str]:
    return [m.group(0).lower() for m in TOKEN_RE.finditer(text)]


def multiset_recall(primary: list[str], secondary: list[str]) -> float | None:
    if not secondary:
        return None
    a = Counter(primary)
    b = Counter(secondary)
    matched = sum(min(a[token], count) for token, count in b.items())
    return round(matched / max(1, sum(b.values())), 4)


def norm_bbox_px(bbox: list[int], width: int, height: int) -> list[float]:
    x0, y0, x1, y1 = bbox
    return [
        round(x0 / width, 6),
        round(y0 / height, 6),
        round(x1 / width, 6),
        round(y1 / height, 6),
    ]


def union_bbox(items: list[dict[str, Any]]) -> list[int]:
    return [
        min(item["left"] for item in items),
        min(item["top"] for item in items),
        max(item["left"] + item["width"] for item in items),
        max(item["top"] + item["height"] for item in items),
    ]


def slug(text: str) -> str:
    value = clean_text(text).lower()
    value = re.sub(r"[^a-z0-9]+", "-", value).strip("-")
    return value[:80] or "unnamed"


def anchor_for_reference(kind: str, value: str) -> str:
    kind = kind.lower()
    if kind == "clause":
        kind = "section"
    return f"{kind}-{slug(value)}"


def section_key(text: str) -> str | None:
    numbered = NUMBERED_SECTION_RE.match(text)
    if numbered:
        return numbered.group(1)
    special = SPECIAL_SECTION_RE.match(text)
    if special:
        return special.group(1)
    return None


def init_worker(pdf_path: str, dpi: int) -> None:
    global _DOC, _PDF_PATH, _DPI, _TESS_ENV
    _PDF_PATH = pdf_path
    _DPI = dpi
    _DOC = fitz.open(pdf_path)
    _TESS_ENV = dict(os.environ)
    _TESS_ENV["OMP_THREAD_LIMIT"] = "1"


def parse_tesseract_tsv(tsv_text: str) -> list[dict[str, Any]]:
    words: list[dict[str, Any]] = []
    reader = csv.DictReader(io.StringIO(tsv_text), delimiter="\t")
    for row in reader:
        if row.get("level") != "5":
            continue
        text = clean_text(row.get("text", ""))
        if not text:
            continue
        try:
            conf = float(row.get("conf", "-1"))
            left = int(row["left"])
            top = int(row["top"])
            width = int(row["width"])
            height = int(row["height"])
        except (TypeError, ValueError, KeyError):
            continue
        words.append(
            {
                "block": int(row.get("block_num", 0) or 0),
                "paragraph": int(row.get("par_num", 0) or 0),
                "line": int(row.get("line_num", 0) or 0),
                "word": int(row.get("word_num", 0) or 0),
                "left": left,
                "top": top,
                "width": width,
                "height": height,
                "confidence": conf,
                "text": text,
            }
        )
    return words


def group_ocr_lines(words: list[dict[str, Any]]) -> list[dict[str, Any]]:
    grouped: dict[tuple[int, int, int], list[dict[str, Any]]] = defaultdict(list)
    for word in words:
        grouped[(word["block"], word["paragraph"], word["line"])].append(word)
    lines: list[dict[str, Any]] = []
    for key, items in grouped.items():
        items.sort(key=lambda item: (item["left"], item["word"]))
        text = clean_text(" ".join(item["text"] for item in items))
        if not text:
            continue
        weights = [max(1, len(item["text"])) for item in items]
        valid = [(item["confidence"], weight) for item, weight in zip(items, weights) if item["confidence"] >= 0]
        confidence = (
            sum(conf * weight for conf, weight in valid) / sum(weight for _, weight in valid)
            if valid
            else -1.0
        )
        bbox = union_bbox(items)
        lines.append(
            {
                "key": key,
                "text": text,
                "bbox_px": bbox,
                "confidence": round(confidence, 2),
                "word_count": len(items),
                "mean_word_height_px": round(statistics.fmean(item["height"] for item in items), 2),
            }
        )
    lines.sort(key=lambda item: (item["bbox_px"][1], item["bbox_px"][0]))
    return lines


def embedded_lines(page: fitz.Page) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    data = page.get_text("dict")
    for block in data.get("blocks", []):
        if block.get("type") != 0:
            continue
        for line in block.get("lines", []):
            spans = line.get("spans", [])
            text = clean_text("".join(span.get("text", "") for span in spans))
            if not text:
                continue
            result.append(
                {
                    "text": text,
                    "bbox_pt": [round(float(v), 3) for v in line.get("bbox", (0, 0, 0, 0))],
                    "max_font_size_pt": round(max((float(span.get("size", 0)) for span in spans), default=0), 2),
                }
            )
    return result


def nearest_embedded(
    line: dict[str, Any],
    embedded: list[dict[str, Any]],
    scale: float,
) -> dict[str, Any] | None:
    if not embedded:
        return None
    x0, y0, x1, y1 = line["bbox_px"]
    cy = (y0 + y1) / 2
    candidates: list[tuple[float, dict[str, Any]]] = []
    for item in embedded:
        bx = item["bbox_pt"]
        bcy = ((bx[1] + bx[3]) / 2) * scale
        distance = abs(cy - bcy)
        if distance <= max(15.0, (y1 - y0) * 1.8):
            candidates.append((distance, item))
    if not candidates:
        return None
    candidates.sort(key=lambda pair: pair[0])
    return candidates[0][1]


def classify_line(
    page_no: int,
    text: str,
    bbox_norm: list[float],
    height_px: float,
    median_height: float,
    repeated_header: bool,
) -> tuple[str, str]:
    if repeated_header:
        return "service_zone", "repeating_header_regex"
    if bbox_norm[1] >= 0.94 and re.fullmatch(r"\d{1,3}", text):
        return "service_zone", "footer_page_number_geometry"
    if FIGURE_CAPTION_RE.match(text):
        return "figure_caption", "ocr_caption_regex"
    if TABLE_CAPTION_RE.match(text):
        return "table_caption", "ocr_caption_regex"
    if NOTE_RE.match(text):
        return "note", "ocr_note_regex"
    if bbox_norm[1] >= 0.76 and height_px < median_height * 0.9 and re.match(r"^\s*(?:\d+|[*†‡])\s+", text):
        return "footnote", "ocr_footer_geometry"
    if section_key(text) is not None and page_no <= 8:
        return "toc_entry", "ocr_toc_geometry"
    if section_key(text) is not None:
        return "heading", "ocr_section_regex"
    if LIST_RE.match(text):
        return "list_item", "ocr_list_regex"
    if height_px >= median_height * 1.38 and len(text) <= 120:
        return "heading_candidate", "ocr_line_height"
    return "paragraph_line", "ocr_default"


def process_page(
    page_no: int,
    figures: list[dict[str, Any]],
    table_regions_pt: list[list[float]],
    table_captions_expected: list[str],
) -> dict[str, Any]:
    if _DOC is None:
        raise RuntimeError("worker document is not initialized")
    page = _DOC[page_no - 1]
    scale = _DPI / 72.0
    matrix = fitz.Matrix(scale, scale)
    pix = page.get_pixmap(matrix=matrix, colorspace=fitz.csGRAY, alpha=False)
    png = pix.tobytes("png")
    command = [
        "tesseract",
        "stdin",
        "stdout",
        "-l",
        "eng",
        "--psm",
        "3",
        "tsv",
    ]
    proc = subprocess.run(
        command,
        input=png,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
        timeout=180,
        env=_TESS_ENV,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            f"tesseract failed on page {page_no}: {proc.stderr.decode('utf-8', 'replace')[:500]}"
        )
    words = parse_tesseract_tsv(proc.stdout.decode("utf-8", "replace"))
    lines = group_ocr_lines(words)
    embedded = embedded_lines(page)
    heights = [line["mean_word_height_px"] for line in lines if line["mean_word_height_px"] > 0]
    median_height = statistics.median(heights) if heights else 1.0

    blocks: list[dict[str, Any]] = []
    anchors: list[dict[str, Any]] = [
        {
            "anchor_id": f"page-{page_no:03d}",
            "kind": "page",
            "page": page_no,
            "block_id": None,
            "label": f"PDF page {page_no}",
        }
    ]
    references: list[dict[str, Any]] = []
    ambiguities: list[dict[str, Any]] = []
    figure_caption_y: dict[int, float] = {}
    for line in lines:
        match = FIGURE_CAPTION_RE.match(line["text"])
        if match:
            figure_caption_y[int(match.group(1))] = (
                line["bbox_px"][1] + line["bbox_px"][3]
            ) / 2
    note_counter = 0
    heading_counter = 0

    for idx, line in enumerate(lines, start=1):
        bbox_norm = norm_bbox_px(line["bbox_px"], pix.width, pix.height)
        repeated_header = bool(REPEAT_HEADER_RE.fullmatch(line["text"]))
        block_type, method = classify_line(
            page_no,
            line["text"],
            bbox_norm,
            line["mean_word_height_px"],
            median_height,
            repeated_header,
        )
        block_id = f"p{page_no:03d}-b{idx:04d}"
        near = nearest_embedded(line, embedded, scale)
        block: dict[str, Any] = {
            "block_id": block_id,
            "type": block_type,
            "text": line["text"],
            "bbox_px": line["bbox_px"],
            "bbox_norm": bbox_norm,
            "ocr_confidence": line["confidence"],
            "word_count": line["word_count"],
            "classification_method": method,
            "primary_source": "rendered_page_ocr",
        }
        if near is not None:
            block["secondary_text_match"] = {
                "embedded_text": near["text"],
                "embedded_max_font_size_pt": near["max_font_size_pt"],
                "token_recall": multiset_recall(tokens(line["text"]), tokens(near["text"])),
            }

        if block_type == "heading":
            heading_counter += 1
            key = section_key(line["text"]) or str(heading_counter)
            anchor_id = anchor_for_reference("section", key)
            if any(item["anchor_id"] == anchor_id for item in anchors):
                anchor_id = f"{anchor_id}-p{page_no:03d}-{heading_counter:02d}"
            anchors.append(
                {
                    "anchor_id": anchor_id,
                    "kind": "heading",
                    "page": page_no,
                    "block_id": block_id,
                    "label": line["text"],
                }
            )
            block["anchor_id"] = anchor_id

        figure_match = FIGURE_CAPTION_RE.match(line["text"])
        if figure_match:
            number = int(figure_match.group(1))
            anchor_id = f"figure-{number}"
            block["anchor_id"] = anchor_id
            anchors.append(
                {
                    "anchor_id": anchor_id,
                    "kind": "figure",
                    "page": page_no,
                    "block_id": block_id,
                    "label": line["text"],
                }
            )

        table_match = TABLE_CAPTION_RE.match(line["text"])
        if table_match:
            number = table_match.group(1)
            anchor_id = anchor_for_reference("table", number)
            block["anchor_id"] = anchor_id
            anchors.append(
                {
                    "anchor_id": anchor_id,
                    "kind": "table",
                    "page": page_no,
                    "block_id": block_id,
                    "label": line["text"],
                }
            )

        note_match = NOTE_RE.match(line["text"])
        if note_match:
            note_counter += 1
            note_no = note_match.group(1) or str(note_counter)
            anchor_id = f"page-{page_no:03d}-note-{slug(note_no)}"
            block["anchor_id"] = anchor_id
            note_center_y = (line["bbox_px"][1] + line["bbox_px"][3]) / 2
            applicable_figures = [
                number for number, caption_y in figure_caption_y.items() if note_center_y < caption_y
            ]
            if applicable_figures:
                block["note_scope"] = "figure_candidate"
                block["scope_figure_numbers"] = applicable_figures
                if len(applicable_figures) > 1:
                    ambiguities.append(
                        {
                            "code": "note_scope_requires_manual_review",
                            "severity": "review",
                            "block_id": block_id,
                            "reason": "NOTE precedes more than one Figure caption; exact Figure scope requires visual confirmation.",
                        }
                    )
            elif figures and figure_caption_y:
                block["note_scope"] = "main_text"
            elif figures:
                block["note_scope"] = "main_text_or_unresolved"
                ambiguities.append(
                    {
                        "code": "note_scope_requires_manual_review",
                        "severity": "review",
                        "block_id": block_id,
                        "reason": "NOTE is on a Figure page but OCR geometry does not prove its scope.",
                    }
                )
            else:
                block["note_scope"] = "main_text"
            anchors.append(
                {
                    "anchor_id": anchor_id,
                    "kind": "note",
                    "page": page_no,
                    "block_id": block_id,
                    "label": line["text"][:160],
                }
            )

        for ref_match in REF_RE.finditer(line["text"]):
            kind = ref_match.group(1).lower()
            value = ref_match.group(2)
            references.append(
                {
                    "source_block_id": block_id,
                    "kind": kind,
                    "label": ref_match.group(0),
                    "target_anchor_id": anchor_for_reference(kind, value),
                }
            )

        if 0 <= line["confidence"] < 45 and len(tokens(line["text"])) >= 2:
            ambiguities.append(
                {
                    "code": "low_confidence_ocr_block",
                    "severity": "review",
                    "block_id": block_id,
                    "reason": f"Mean OCR confidence is {line['confidence']:.2f}.",
                }
            )
        if "�" in line["text"]:
            ambiguities.append(
                {
                    "code": "ocr_control_character_replaced",
                    "severity": "review",
                    "block_id": block_id,
                    "reason": "OCR text contained a forbidden control character and was normalized.",
                }
            )
        blocks.append(block)

    ocr_text = "\n".join(block["text"] for block in blocks)
    embedded_text = "\n".join(item["text"] for item in embedded)
    primary_tokens = tokens(ocr_text)
    secondary_tokens = tokens(embedded_text)
    page_recall = multiset_recall(primary_tokens, secondary_tokens)
    valid_conf = [word["confidence"] for word in words if word["confidence"] >= 0]
    mean_conf = round(statistics.fmean(valid_conf), 2) if valid_conf else None
    if page_recall is not None and len(secondary_tokens) >= 20 and page_recall < 0.72:
        ambiguities.append(
            {
                "code": "page_text_layer_mismatch",
                "severity": "review",
                "block_id": None,
                "reason": f"OCR covers only {page_recall:.4f} of embedded-text tokens.",
            }
        )
    if mean_conf is not None and len(primary_tokens) >= 20 and mean_conf < 62:
        ambiguities.append(
            {
                "code": "low_page_ocr_confidence",
                "severity": "review",
                "block_id": None,
                "reason": f"Mean word confidence is {mean_conf:.2f}.",
            }
        )
    if len(primary_tokens) < 8 and len(secondary_tokens) >= 20:
        ambiguities.append(
            {
                "code": "sparse_ocr_against_text_layer",
                "severity": "review",
                "block_id": None,
                "reason": "Rendered-page OCR is sparse relative to the embedded text layer.",
            }
        )

    figure_entries: list[dict[str, Any]] = []
    for figure in figures:
        number = int(figure["figure_no"])
        caption_block = next(
            (
                block
                for block in blocks
                if block["type"] == "figure_caption"
                and FIGURE_CAPTION_RE.match(block["text"])
                and int(FIGURE_CAPTION_RE.match(block["text"]).group(1)) == number
            ),
            None,
        )
        entry = {
            "figure_no": number,
            "anchor_id": f"figure-{number}",
            "caption_original_approved": figure["caption_original"],
            "caption_ru_approved": figure["caption_ru"],
            "accepted_object_folder": figure["folder"],
            "accepted_status": figure["status"],
            "caption_block_id": caption_block["block_id"] if caption_block else None,
            "graphics_bbox": None,
            "mapping_source": "accepted_catalog_plus_rendered_page_ocr",
        }
        figure_entries.append(entry)
        if caption_block is None:
            ambiguities.append(
                {
                    "code": "figure_caption_not_confirmed_by_ocr",
                    "severity": "review",
                    "block_id": None,
                    "reason": f"Accepted Figure {number} is mapped to this page but its caption was not confirmed by OCR.",
                }
            )
        ambiguities.append(
            {
                "code": "figure_graphics_bbox_requires_manual_review",
                "severity": "review",
                "block_id": caption_block["block_id"] if caption_block else None,
                "reason": f"Figure {number} graphics boundary is not guessed from vector strokes; verify against the rendered page.",
            }
        )

    table_entries: list[dict[str, Any]] = []
    for idx, bbox_pt in enumerate(table_regions_pt, start=1):
        bbox_px = [int(round(value * scale)) for value in bbox_pt]
        caption = table_captions_expected[idx - 1] if idx - 1 < len(table_captions_expected) else None
        table_id = None
        if caption:
            match = TABLE_CAPTION_RE.match(caption)
            table_id = match.group(1) if match else None
        table_entries.append(
            {
                "table_id": table_id,
                "anchor_id": anchor_for_reference("table", table_id) if table_id else f"page-{page_no:03d}-table-{idx:02d}",
                "caption_expected": caption,
                "bbox_pt": [round(float(v), 3) for v in bbox_pt],
                "bbox_px": bbox_px,
                "bbox_norm": norm_bbox_px(bbox_px, pix.width, pix.height),
                "detection": "rendered_page_caption_ocr_with_secondary_vector_geometry",
                "manual_structure_review_required": True,
            }
        )
    if table_captions_expected and not table_regions_pt:
        ambiguities.append(
            {
                "code": "table_caption_without_detected_grid",
                "severity": "review",
                "block_id": None,
                "reason": "A table caption exists but secondary geometry did not yield a table region.",
            }
        )
    if table_regions_pt:
        ambiguities.append(
            {
                "code": "table_structure_requires_manual_review",
                "severity": "review",
                "block_id": None,
                "reason": "Rows, columns, merged cells, headers, and notes must be manually confirmed before Gate 2.",
            }
        )

    service_blocks = [block["block_id"] for block in blocks if block["type"] == "service_zone"]
    return {
        "pdf_page": page_no,
        "pdf_page_label": page.get_label(),
        "page_size_pt": [round(page.rect.width, 3), round(page.rect.height, 3)],
        "render": {
            "dpi": _DPI,
            "pixel_width": pix.width,
            "pixel_height": pix.height,
            "colorspace": "grayscale",
            "retained": False,
        },
        "ocr": {
            "engine": "tesseract",
            "language": "eng",
            "psm": 3,
            "word_count": len(words),
            "block_count": len(blocks),
            "mean_word_confidence": mean_conf,
            "text_sha256": sha256_bytes(ocr_text.encode("utf-8")),
        },
        "secondary_text_layer": {
            "line_count": len(embedded),
            "token_count": len(secondary_tokens),
            "text_sha256": sha256_bytes(embedded_text.encode("utf-8")),
            "ocr_token_recall": page_recall,
            "role": "secondary_control_only",
        },
        "blocks": blocks,
        "figures": figure_entries,
        "tables": table_entries,
        "anchors": anchors,
        "references": references,
        "service_block_ids": service_blocks,
        "ambiguities": ambiguities,
        "manual_review_required": bool(ambiguities),
    }


def scan_tables(pdf_path: Path) -> tuple[dict[int, list[list[float]]], dict[int, list[str]]]:
    regions: dict[int, list[list[float]]] = {}
    captions: dict[int, list[str]] = {}
    with pdfplumber.open(pdf_path) as pdf:
        for page_no, page in enumerate(pdf.pages, start=1):
            text = page.extract_text() or ""
            page_captions = [
                clean_text(match.group(0))
                for match in re.finditer(
                    r"(?im)^\s*Table\s+[A-Z]?\d+(?:\.\d+)?\s*[—–-]\s*.+$",
                    text,
                )
            ]
            if not page_captions:
                continue
            found = page.find_tables()
            captions[page_no] = page_captions
            regions[page_no] = [[float(v) for v in table.bbox] for table in found]
    return regions, captions


def load_figures(catalog_path: Path) -> dict[int, list[dict[str, Any]]]:
    catalog = json.loads(catalog_path.read_text(encoding="utf-8-sig"))
    figures = catalog.get("figures", [])
    if len(figures) != 69:
        raise SystemExit(f"catalog must contain 69 figures, got {len(figures)}")
    if catalog.get("stats") != {"total": 69, "accepted": 69, "changed": 0, "not_accepted": 0}:
        raise SystemExit("catalog Stage 4 status is not 69/69 accepted")
    by_page: dict[int, list[dict[str, Any]]] = defaultdict(list)
    for figure in figures:
        if figure.get("status") != "accepted":
            raise SystemExit(f"Figure {figure.get('figure_no')} is not accepted")
        by_page[int(figure["pdf_page"])].append(figure)
    return dict(by_page)


def output_document(
    pages: list[dict[str, Any]],
    pdf_path: Path,
    output_dir: Path,
    dpi: int,
    chunk_size: int,
) -> list[Path]:
    generated_at = utc_now()
    output_dir.mkdir(parents=True, exist_ok=True)
    page_dir = output_dir / "page_map"
    page_dir.mkdir(parents=True, exist_ok=True)

    common = {
        "schema_version": SCHEMA_VERSION,
        "project": "API 551 RU Translation / Stage 5 Gate 1",
        "generated_at_utc": generated_at,
        "source_pdf": {
            "name": "API 551 2016 (R2024).pdf",
            "pages": len(pages),
            "bytes": pdf_path.stat().st_size,
            "sha256": sha256_file(pdf_path),
        },
        "primary_method": f"rendered page at {dpi} DPI -> Tesseract OCR eng psm 3",
        "secondary_method": "embedded PDF text layer comparison and vector table geometry",
        "ambiguity_policy": "flag for manual review; do not guess",
    }

    seen_anchor_ids: set[str] = set()
    disambiguated_anchor_ids: list[dict[str, Any]] = []
    for page in pages:
        block_by_id = {block["block_id"]: block for block in page["blocks"]}
        for sequence, anchor in enumerate(page["anchors"], start=1):
            original = anchor["anchor_id"]
            if original not in seen_anchor_ids:
                seen_anchor_ids.add(original)
                continue
            suffix = f"p{page['pdf_page']:03d}-{sequence:03d}"
            candidate = f"{original}-{suffix}"
            counter = 2
            while candidate in seen_anchor_ids:
                candidate = f"{original}-{suffix}-{counter}"
                counter += 1
            anchor["anchor_id"] = candidate
            seen_anchor_ids.add(candidate)
            block_id = anchor.get("block_id")
            if block_id and block_id in block_by_id and block_by_id[block_id].get("anchor_id") == original:
                block_by_id[block_id]["anchor_id"] = candidate
            disambiguated_anchor_ids.append(
                {
                    "original": original,
                    "replacement": candidate,
                    "page": page["pdf_page"],
                    "block_id": block_id,
                }
            )

    chunk_paths: list[Path] = []
    chunk_records: list[dict[str, Any]] = []
    for start in range(0, len(pages), chunk_size):
        subset = pages[start : start + chunk_size]
        first = subset[0]["pdf_page"]
        last = subset[-1]["pdf_page"]
        path = page_dir / f"API551_STAGE5_GATE1_PAGE_MAP_{first:03d}_{last:03d}.json"
        payload = {
            **common,
            "page_range": [first, last],
            "page_count": len(subset),
            "pages": subset,
        }
        path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        chunk_paths.append(path)
        chunk_records.append(
            {
                "path": path.relative_to(output_dir).as_posix(),
                "page_range": [first, last],
                "page_count": len(subset),
                "bytes": path.stat().st_size,
                "sha256": sha256_file(path),
            }
        )

    all_anchors: dict[str, dict[str, Any]] = {}
    all_references: list[dict[str, Any]] = []
    duplicate_anchors: list[str] = []
    for page in pages:
        for anchor in page["anchors"]:
            anchor_id = anchor["anchor_id"]
            if anchor_id in all_anchors:
                duplicate_anchors.append(anchor_id)
            else:
                all_anchors[anchor_id] = anchor
        for ref in page["references"]:
            all_references.append({"page": page["pdf_page"], **ref})
    anchor_path = output_dir / "API551_STAGE5_GATE1_ANCHOR_REGISTRY.json"
    resolved_anchor_ids = set(all_anchors)
    unresolved_reference_targets = sorted(
        {
            ref["target_anchor_id"]
            for ref in all_references
            if ref["target_anchor_id"] not in resolved_anchor_ids
        }
    )
    anchor_payload = {
        **common,
        "anchor_count": len(all_anchors),
        "duplicate_anchor_ids": sorted(set(duplicate_anchors)),
        "disambiguated_anchor_ids": disambiguated_anchor_ids,
        "anchors": list(all_anchors.values()),
        "reference_count": len(all_references),
        "references": all_references,
        "unresolved_reference_target_count": len(unresolved_reference_targets),
        "unresolved_reference_targets": unresolved_reference_targets,
    }
    anchor_path.write_text(
        json.dumps(anchor_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    type_counts = Counter(
        block["type"] for page in pages for block in page["blocks"]
    )
    ambiguity_counts = Counter(
        ambiguity["code"] for page in pages for ambiguity in page["ambiguities"]
    )
    manual_pages = [page["pdf_page"] for page in pages if page["manual_review_required"]]
    figure_numbers = sorted(
        figure["figure_no"] for page in pages for figure in page["figures"]
    )
    table_ids = [
        table["table_id"] for page in pages for table in page["tables"] if table["table_id"]
    ]
    recall_values = [
        page["secondary_text_layer"]["ocr_token_recall"]
        for page in pages
        if page["secondary_text_layer"]["ocr_token_recall"] is not None
    ]
    confidence_values = [
        page["ocr"]["mean_word_confidence"]
        for page in pages
        if page["ocr"]["mean_word_confidence"] is not None
    ]

    qa_path = output_dir / "API551_STAGE5_GATE1_QA_REPORT.json"
    qa_payload = {
        **common,
        "status": "machine_map_complete_manual_review_pending",
        "coverage": {
            "expected_pages": 244,
            "mapped_pages": len(pages),
            "missing_pages": sorted(set(range(1, 245)) - {page["pdf_page"] for page in pages}),
            "duplicate_pages": [],
            "figures_expected": 69,
            "figures_mapped": len(figure_numbers),
            "figure_numbers": figure_numbers,
            "tables_detected": len(table_ids),
            "table_ids": table_ids,
        },
        "block_type_counts": dict(sorted(type_counts.items())),
        "ocr_metrics": {
            "mean_page_word_confidence": round(statistics.fmean(confidence_values), 4)
            if confidence_values
            else None,
            "mean_embedded_token_recall": round(statistics.fmean(recall_values), 4)
            if recall_values
            else None,
            "minimum_embedded_token_recall": round(min(recall_values), 4)
            if recall_values
            else None,
        },
        "manual_review": {
            "required_page_count": len(manual_pages),
            "pages": manual_pages,
            "ambiguity_count": sum(ambiguity_counts.values()),
            "ambiguity_counts": dict(sorted(ambiguity_counts.items())),
        },
        "anchor_registry": {
            "anchors": len(all_anchors),
            "references": len(all_references),
            "duplicate_anchor_ids": sorted(set(duplicate_anchors)),
            "disambiguated_anchor_count": len(disambiguated_anchor_ids),
            "unresolved_reference_target_count": len(unresolved_reference_targets),
            "unresolved_reference_targets": unresolved_reference_targets,
        },
        "gate1_acceptance": {
            "machine_coverage_pass": len(pages) == 244 and figure_numbers == list(range(1, 70)),
            "manual_review_complete": False,
            "gate1_accepted": False,
            "reason": "Gate 1 cannot be accepted until flagged ambiguities and table/Figure boundaries are manually reviewed.",
        },
    }
    qa_path.write_text(
        json.dumps(qa_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    index_path = output_dir / "API551_STAGE5_GATE1_PAGE_MAP_INDEX.json"
    index_payload = {
        **common,
        "status": qa_payload["status"],
        "page_count": len(pages),
        "chunks": chunk_records,
        "anchor_registry": {
            "path": anchor_path.name,
            "bytes": anchor_path.stat().st_size,
            "sha256": sha256_file(anchor_path),
        },
        "qa_report": {
            "path": qa_path.name,
            "bytes": qa_path.stat().st_size,
            "sha256": sha256_file(qa_path),
        },
    }
    index_path.write_text(
        json.dumps(index_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return [index_path, anchor_path, qa_path, *chunk_paths]


def validate_outputs(paths: list[Path], expected_pdf_sha: str) -> dict[str, Any]:
    for path in paths:
        json.loads(path.read_text(encoding="utf-8"))
    index = json.loads(paths[0].read_text(encoding="utf-8"))
    qa = json.loads(paths[2].read_text(encoding="utf-8"))
    if index["source_pdf"]["sha256"] != expected_pdf_sha:
        raise SystemExit("source PDF SHA-256 mismatch in generated index")
    coverage = qa["coverage"]
    if coverage["mapped_pages"] != 244 or coverage["missing_pages"]:
        raise SystemExit("page coverage is not 244/244")
    if coverage["figures_mapped"] != 69 or coverage["figure_numbers"] != list(range(1, 70)):
        raise SystemExit("Figure coverage is not 69/69")
    if qa["anchor_registry"]["duplicate_anchor_ids"]:
        raise SystemExit("duplicate anchor IDs found")
    return {
        "json_files": len(paths),
        "pages": coverage["mapped_pages"],
        "figures": coverage["figures_mapped"],
        "tables": coverage["tables_detected"],
        "anchors": qa["anchor_registry"]["anchors"],
        "references": qa["anchor_registry"]["references"],
        "manual_review_pages": qa["manual_review"]["required_page_count"],
        "ambiguities": qa["manual_review"]["ambiguity_count"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Build API 551 Stage 5 Gate 1 page map")
    parser.add_argument("--pdf", type=Path, required=True)
    parser.add_argument("--catalog", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--dpi", type=int, default=DEFAULT_DPI)
    parser.add_argument("--workers", type=int, default=max(1, min(4, os.cpu_count() or 1)))
    parser.add_argument("--chunk-size", type=int, default=DEFAULT_CHUNK_SIZE)
    args = parser.parse_args()

    expected_pdf_sha = "d458b3a899902f216767e753aa5737a9745b61adcab02f85c9521937a9d3e270"
    if not args.pdf.is_file():
        raise SystemExit(f"PDF not found: {args.pdf}")
    if args.pdf.stat().st_size != 8_089_772:
        raise SystemExit(f"unexpected PDF size: {args.pdf.stat().st_size}")
    actual_pdf_sha = sha256_file(args.pdf)
    if actual_pdf_sha != expected_pdf_sha:
        raise SystemExit(f"unexpected PDF SHA-256: {actual_pdf_sha}")
    with fitz.open(args.pdf) as doc:
        if doc.page_count != 244:
            raise SystemExit(f"unexpected PDF page count: {doc.page_count}")

    figures_by_page = load_figures(args.catalog)
    table_regions, table_captions = scan_tables(args.pdf)
    jobs = [
        (
            page_no,
            figures_by_page.get(page_no, []),
            table_regions.get(page_no, []),
            table_captions.get(page_no, []),
        )
        for page_no in range(1, 245)
    ]

    pages: dict[int, dict[str, Any]] = {}
    with ProcessPoolExecutor(
        max_workers=args.workers,
        initializer=init_worker,
        initargs=(str(args.pdf), args.dpi),
    ) as pool:
        futures = {pool.submit(process_page, *job): job[0] for job in jobs}
        completed = 0
        for future in as_completed(futures):
            page_no = futures[future]
            pages[page_no] = future.result()
            completed += 1
            if completed % 20 == 0 or completed == 244:
                print(f"mapped {completed}/244", flush=True)

    ordered = [pages[page_no] for page_no in range(1, 245)]
    paths = output_document(
        ordered,
        args.pdf,
        args.output,
        args.dpi,
        args.chunk_size,
    )
    summary = validate_outputs(paths, expected_pdf_sha)
    print(json.dumps(summary, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
