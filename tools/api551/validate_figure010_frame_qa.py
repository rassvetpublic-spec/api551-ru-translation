#!/usr/bin/env python3
from __future__ import annotations
import argparse
import json
from pathlib import Path
import sys

REQUIRED_FRAMED = {
    "block-002",
    "block-003",
    "block-004",
    "block-006",
    "block-008",
    "block-009",
    "block-010",
    "block-011",
}
REQUIRED_ALL = REQUIRED_FRAMED | {"block-005", "block-007"}

def fail(msg: str) -> None:
    print(f"[FAIL] {msg}")
    raise SystemExit(1)

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("qa_json")
    args = ap.parse_args()
    path = Path(args.qa_json)
    data = json.loads(path.read_text(encoding="utf-8-sig"))

    if data.get("figure") not in (10, "010", "10"):
        fail("figure must be 010")
    if data.get("revision") not in ("R02", "R03", "R04"):
        fail("revision must be R02 or later")
    if data.get("production_source") != "original_pdf_page_43":
        fail("production_source must be original_pdf_page_43")
    if data.get("used_r01_as_production_source") is not False:
        fail("R01 must not be used as production source")
    if data.get("cleaned_only_intermediate_verified") is not True:
        fail("cleaned-only intermediate must be verified")
    if data.get("caption_inside_png") is not False:
        fail("caption must be outside PNG")
    if data.get("fresh_extracted_png_inspected") is not True:
        fail("fresh-extracted PNG must be inspected")

    labels = {x.get("block_id"): x for x in data.get("labels", [])}
    missing = sorted(REQUIRED_ALL - set(labels))
    if missing:
        fail(f"missing labels: {missing}")

    for block in sorted(REQUIRED_FRAMED):
        row = labels[block]
        if row.get("strategy") not in ("leader_line_callout", "multi_leader_line_callout"):
            fail(f"{block}: wrong strategy")
        if row.get("frame_present") is not True:
            fail(f"{block}: frame is required")
        pads = row.get("padding_px") or {}
        for side in ("left", "top", "right", "bottom"):
            val = pads.get(side)
            if not isinstance(val, (int, float)) or not 3 <= val <= 5:
                fail(f"{block}: {side} padding must be 3..5 px, got {val!r}")
        if row.get("relation_to_leader_line") not in ("touches", "minimal_safe_gap"):
            fail(f"{block}: invalid leader relation")
        if row.get("protected_graphics_intersection") not in (False, "none"):
            fail(f"{block}: protected graphics intersection")
        if row.get("source_cleanup_complete") is not True:
            fail(f"{block}: source cleanup incomplete")
        if row.get("residual_source_text") not in (False, "none"):
            fail(f"{block}: residual source text remains")
        if not row.get("text_bbox") or not row.get("frame_bbox"):
            fail(f"{block}: text/frame bbox missing")

    block5 = labels["block-005"]
    if block5.get("strategy") not in ("source_free_text_no_leader", "leader_line_callout"):
        fail("block-005: strategy must be source_free_text_no_leader or leader_line_callout")
    if block5.get("strategy") == "source_free_text_no_leader" and not block5.get("source_visual_evidence"):
        fail("block-005: source visual evidence required for no-leader strategy")

    block7 = labels["block-007"]
    if block7.get("strategy") != "protected_dimension":
        fail("block-007 must be protected_dimension")
    if block7.get("original_preserved") is not True:
        fail("block-007 original 3 in. must be preserved")

    print("[PASS] Figure 010 frame QA schema and mandatory gates")

if __name__ == "__main__":
    main()
