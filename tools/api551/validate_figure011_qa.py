#!/usr/bin/env python3
import json
from pathlib import Path
import sys

path = Path(sys.argv[1])
qa = json.loads(path.read_text(encoding="utf-8-sig"))
expected = {f"block-{n:03d}" for n in range(2, 13)}
rows = {row.get("block_id"): row for row in qa.get("labels", [])}
if qa.get("figure") != 11 or qa.get("revision") != "R01" or qa.get("status") != "PASS":
    raise SystemExit("[FAIL] Figure 011 top-level QA gate")
if qa.get("caption_inside_png") is not False or qa.get("fresh_extracted_png_inspected") is not True:
    raise SystemExit("[FAIL] Figure 011 package/visual gate")
if qa.get("leader_line_callouts") != 0 or qa.get("invented_callout_frames") != 0:
    raise SystemExit("[FAIL] Figure 011 invented callout frame")
if set(rows) != expected:
    raise SystemExit("[FAIL] Figure 011 label set")
for block, row in rows.items():
    if row.get("visual_result") != "PASS" or row.get("source_cleanup_complete") is not True:
        raise SystemExit(f"[FAIL] {block}: cleanup/visual")
    if row.get("protected_graphics_intersection") is not False:
        raise SystemExit(f"[FAIL] {block}: protected intersection")
    if row.get("strategy") == "legend_table_cell":
        if row.get("frame_kind") != "protected_existing_table_cell" or row.get("frame_preserved") is not True:
            raise SystemExit(f"[FAIL] {block}: table frame")
        if row.get("line_sample_cell_unchanged") is not True:
            raise SystemExit(f"[FAIL] {block}: legend line sample")
print("[PASS] Figure 011 cleanup/placement/frame QA")
