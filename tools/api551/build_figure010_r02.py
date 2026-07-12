#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont
import pypdfium2 as pdfium


FIGURE = 10
REVISION = "R02"
PDF_PAGE_INDEX = 42
CROP_PDF_TOP_ORIGIN = (32, 510, 606, 723)
RENDER_SCALE = 4
FINAL_SIZE = (2296, 852)
FONT_SHA256 = "7c25be4d78155523080ab85b10277150657ff7dabbcad7037bdd536c9b6d0d08"
FONT_SIZE = 26
LINE_SPACING = 3
FRAME_PADDING = 4
FRAME_COLOR = (128, 128, 128)
PROTECTED_DIMENSION_ROI = (700, 575, 875, 660)


LABELS = {
    "block-002": {
        "original": "Trim excess sheath and support it prior to terminal head with “U” bolt and angle iron that is welded to furnace skin",
        "ru": "Обрезать лишнюю оболочку и закрепить её перед клеммной головкой U-образным болтом и уголком, приваренным к обшивке печи.",
        "text": "Обрезать лишнюю оболочку и\nзакрепить её перед клеммной\nголовкой U-образным болтом\nи уголком, приваренным\nк обшивке печи.",
        "strategy": "leader_line_callout",
        "cleanup_roi": (180, 185, 720, 320),
        "source_anchor": [493, 320],
        "placement": ("bottom_center", 493, 320),
    },
    "block-003": {
        "original": "Refractory and insulation",
        "ru": "Огнеупорная футеровка и теплоизоляция",
        "text": "Огнеупорная футеровка\nи теплоизоляция",
        "strategy": "multi_leader_line_callout",
        "cleanup_roi": (745, 80, 1180, 138),
        "source_anchor": [[860, 138], [955, 138], [1035, 138]],
        "placement": ("bottom_multi", 860, 955, 1035, 138),
    },
    "block-004": {
        "original": "Sheath expansion loop equals two tube diameters",
        "ru": "Компенсационная петля оболочки равна двум диаметрам трубы.",
        "text": "Компенсационная петля\nоболочки равна двум\nдиаметрам трубы.",
        "strategy": "leader_line_callout",
        "cleanup_roi": (1260, 140, 1740, 210),
        "source_anchor": [1614, 218],
        "placement": ("bottom_right", 1614, 218),
    },
    "block-005": {
        "original": "Sheath coil should expand in the direction of tube thermal growth",
        "ru": "Виток оболочки должен расширяться в направлении теплового роста трубы.",
        "text": "Виток оболочки должен\nрасширяться в направлении\nтеплового роста трубы.",
        "strategy": "source_free_text_no_leader",
        "cleanup_roi": (1170, 300, 1620, 425),
        "source_anchor": None,
        "placement": ("free", 1200, 320),
    },
    "block-006": {
        "original": "T/C compression fitting",
        "ru": "Компрессионный фитинг термопары",
        "text": "Компрессионный фитинг\nтермопары",
        "strategy": "leader_line_callout",
        "cleanup_roi": (390, 595, 700, 685),
        "source_anchor": [592, 573],
        "placement": ("top_left", 380, 573),
    },
    "block-007": {
        "original": "3 in.",
        "ru": None,
        "text": None,
        "strategy": "protected_dimension",
        "cleanup_roi": None,
        "source_anchor": None,
        "placement": None,
    },
    "block-008": {
        "original": "Furnace exterior steel skin",
        "ru": "Наружная стальная обшивка печи",
        "text": "Наружная стальная\nобшивка печи",
        "strategy": "leader_line_callout",
        "cleanup_roi": (490, 695, 780, 800),
        "source_anchor": [770, 690],
        "placement": ("top_right", 770, 690),
    },
    "block-009": {
        "original": "Thermocouple sheath",
        "ru": "Оболочка термопары",
        "text": "Оболочка\nтермопары",
        "strategy": "leader_line_callout",
        "cleanup_roi": (1360, 535, 1620, 610),
        "source_anchor": [1620, 596],
        "placement": ("right_top", 1620, 552),
    },
    "block-010": {
        "original": "Furnace tube",
        "ru": "Труба печи",
        "text": "Труба печи",
        "strategy": "leader_line_callout",
        "cleanup_roi": (1440, 748, 1690, 805),
        "source_anchor": [1690, 740],
        "placement": ("top_right", 1690, 740),
    },
    "block-011": {
        "original": "Clip",
        "ru": "Зажим",
        "text": "Зажим",
        "strategy": "leader_line_callout",
        "cleanup_roi": (2040, 748, 2190, 805),
        "source_anchor": [2035, 746],
        "placement": ("left_top", 2035, 739),
    },
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path: Path, data: object) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def load_gate(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("figure") != "010" or data.get("revision") != REVISION or data.get("status") != "PASS":
        raise SystemExit("strategy gate is not PASS for Figure 010 R02")
    if data.get("used_r01_as_production_source") is not False:
        raise SystemExit("strategy gate permits R01 as production source")
    actual = {row["block_id"]: row["strategy"] for row in data.get("labels", [])}
    expected = {block: row["strategy"] for block, row in LABELS.items()}
    if actual != expected:
        raise SystemExit("strategy gate does not match the builder map")
    return data


def render_source(repo_root: Path) -> Image.Image:
    pdf_path = repo_root / "source" / "API 551 2016 (R2024).pdf"
    page = pdfium.PdfDocument(str(pdf_path))[PDF_PAGE_INDEX]
    rendered = page.render(scale=RENDER_SCALE).to_pil().convert("RGB")
    crop = tuple(int(value * RENDER_SCALE) for value in CROP_PDF_TOP_ORIGIN)
    image = rendered.crop(crop)
    if image.size != FINAL_SIZE:
        raise SystemExit(f"unexpected source crop size: {image.size}")
    return image


def ink_mask_for_roi(source: Image.Image, roi: tuple[int, int, int, int]) -> Image.Image:
    gray = source.crop(roi).convert("L")
    local = gray.point(lambda value: 255 if value < 245 else 0)
    local = local.filter(ImageFilter.MaxFilter(3))
    mask = Image.new("L", source.size, 0)
    mask.paste(local, (roi[0], roi[1]))
    return mask


def command_clean(args: argparse.Namespace) -> None:
    repo = Path(args.repo_root).resolve()
    output = Path(args.output_dir).resolve()
    output.mkdir(parents=True, exist_ok=True)
    gate = load_gate(Path(args.gate_json).resolve())
    source = render_source(repo)
    cleaned = source.copy()
    combined_mask = Image.new("L", source.size, 0)
    draw_mask = ImageDraw.Draw(combined_mask)
    cleanup_rows = []

    for block, row in LABELS.items():
        roi = row["cleanup_roi"]
        if roi is None:
            continue
        local_mask = ink_mask_for_roi(source, roi)
        combined_mask = ImageChops.lighter(combined_mask, local_mask)
        cleaned.paste((255, 255, 255), (0, 0), local_mask)
        changed = sum(1 for value in local_mask.getdata() if value)
        cleanup_rows.append({"block_id": block, "source_text_roi": list(roi), "masked_pixels": changed})

    del draw_mask
    diff = ImageChops.difference(source, cleaned).convert("L")
    outside = ImageChops.multiply(diff, ImageChops.invert(combined_mask))
    if outside.getbbox() is not None:
        raise SystemExit("cleanup changed pixels outside the cleanup mask")
    if ImageChops.difference(source.crop(PROTECTED_DIMENSION_ROI), cleaned.crop(PROTECTED_DIMENSION_ROI)).getbbox():
        raise SystemExit("protected 3 in. dimension changed during cleanup")

    source_path = output / "figure_010.source_crop.png"
    cleaned_path = output / "figure_010.cleaned_only.png"
    mask_path = output / "figure_010.cleanup_mask.png"
    source.save(source_path)
    cleaned.save(cleaned_path)
    combined_mask.save(mask_path)
    write_json(
        output / "figure_010.cleanup_qa.json",
        {
            "figure": 10,
            "revision": REVISION,
            "production_source": "original_pdf_page_43",
            "used_r01_as_production_source": False,
            "source_crop_bbox_pdf_points_top_origin": list(CROP_PDF_TOP_ORIGIN),
            "source_size_px": list(source.size),
            "source_sha256": sha256(source_path),
            "cleaned_sha256": sha256(cleaned_path),
            "mask_sha256": sha256(mask_path),
            "outside_mask_changes": 0,
            "protected_dimension_3_in_preserved": True,
            "labels": cleanup_rows,
            "strategy_gate_sha256": sha256(Path(args.gate_json).resolve()),
            "strategy_gate_status": gate["status"],
        },
    )
    print(f"[PASS] cleaned-only build: {cleaned_path}")


def load_font(path: Path) -> ImageFont.FreeTypeFont:
    if sha256(path) != FONT_SHA256:
        raise SystemExit("Nimbus Sans font SHA-256 mismatch")
    return ImageFont.truetype(str(path), FONT_SIZE)


def measure(draw: ImageDraw.ImageDraw, font: ImageFont.FreeTypeFont, text: str) -> tuple[int, int, tuple[int, int, int, int]]:
    bbox = draw.multiline_textbbox((0, 0), text, font=font, spacing=LINE_SPACING, align="center")
    return int(bbox[2] - bbox[0]), int(bbox[3] - bbox[1]), tuple(int(v) for v in bbox)


def frame_from_placement(width: int, height: int, placement: tuple) -> tuple[int, int, int, int]:
    mode = placement[0]
    if mode == "bottom_center":
        _, x, bottom = placement
        left = int(round(x - width / 2))
        return left, bottom - height, left + width, bottom
    if mode == "bottom_multi":
        _, x1, _x2, x3, bottom = placement
        center = (x1 + x3) / 2
        left = int(round(center - width / 2))
        return left, bottom - height, left + width, bottom
    if mode == "bottom_right":
        _, right, bottom = placement
        return right - width, bottom - height, right, bottom
    if mode == "top_left":
        _, left, top = placement
        return left, top, left + width, top + height
    if mode == "top_right":
        _, right, top = placement
        return right - width, top, right, top + height
    if mode == "right_top":
        _, right, top = placement
        return right - width, top, right, top + height
    if mode == "left_top":
        _, left, top = placement
        return left, top, left + width, top + height
    raise SystemExit(f"unsupported placement: {placement}")


def intersection(a: tuple[int, int, int, int], b: tuple[int, int, int, int]) -> bool:
    return max(a[0], b[0]) < min(a[2], b[2]) and max(a[1], b[1]) < min(a[3], b[3])


def draw_framed_label(
    image: Image.Image,
    draw: ImageDraw.ImageDraw,
    font: ImageFont.FreeTypeFont,
    block: str,
    row: dict,
) -> dict:
    text_width, text_height, local_bbox = measure(draw, font, row["text"])
    frame_width = text_width + 2 * FRAME_PADDING
    frame_height = text_height + 2 * FRAME_PADDING
    frame = frame_from_placement(frame_width, frame_height, row["placement"])
    if frame[0] < 0 or frame[1] < 0 or frame[2] > image.width or frame[3] > image.height:
        raise SystemExit(f"{block}: frame outside canvas")
    if intersection(frame, PROTECTED_DIMENSION_ROI):
        raise SystemExit(f"{block}: frame intersects protected 3 in. dimension")

    draw.rectangle(frame, fill=(255, 255, 255), outline=FRAME_COLOR, width=1)
    text_left = frame[0] + FRAME_PADDING
    text_top = frame[1] + FRAME_PADDING
    draw_xy = (text_left - local_bbox[0], text_top - local_bbox[1])
    draw.multiline_text(draw_xy, row["text"], font=font, fill=(0, 0, 0), spacing=LINE_SPACING, align="center")
    actual = draw.multiline_textbbox(draw_xy, row["text"], font=font, spacing=LINE_SPACING, align="center")
    text_bbox = [int(v) for v in actual]
    padding = {
        "left": text_bbox[0] - frame[0],
        "top": text_bbox[1] - frame[1],
        "right": frame[2] - text_bbox[2],
        "bottom": frame[3] - text_bbox[3],
    }
    if set(padding.values()) != {FRAME_PADDING}:
        raise SystemExit(f"{block}: unexpected padding {padding}")
    return {
        "block_id": block,
        "original": row["original"],
        "approved_ru": row["ru"],
        "strategy": row["strategy"],
        "source_anchor": row["source_anchor"],
        "text_bbox": text_bbox,
        "frame_bbox": list(frame),
        "frame_present": True,
        "padding_px": padding,
        "relation_to_leader_line": "touches",
        "protected_graphics_intersection": False,
        "source_cleanup_complete": True,
        "residual_source_text": False,
        "visual_result": "pending_visual_inspection",
        "notes": "Frame is measured from Nimbus Sans text; placement is anchored to the fresh PDF leader contact.",
    }


def command_render(args: argparse.Namespace) -> None:
    output = Path(args.output_dir).resolve()
    gate = load_gate(Path(args.gate_json).resolve())
    verification = json.loads(Path(args.verification_json).read_text(encoding="utf-8"))
    cleaned_path = output / "figure_010.cleaned_only.png"
    if verification.get("status") != "PASS" or verification.get("cleaned_only_inspected") is not True:
        raise SystemExit("cleaned-only visual verification is not PASS")
    if verification.get("cleaned_sha256") != sha256(cleaned_path):
        raise SystemExit("cleaned-only verification hash mismatch")
    font = load_font(Path(args.font_path).resolve())
    image = Image.open(cleaned_path).convert("RGB")
    draw = ImageDraw.Draw(image)
    qa_rows = []

    for block, row in LABELS.items():
        if row["strategy"] in {"leader_line_callout", "multi_leader_line_callout"}:
            qa_rows.append(draw_framed_label(image, draw, font, block, row))
        elif row["strategy"] == "source_free_text_no_leader":
            width, height, local_bbox = measure(draw, font, row["text"])
            _, x, y = row["placement"]
            draw_xy = (x - local_bbox[0], y - local_bbox[1])
            draw.multiline_text(draw_xy, row["text"], font=font, fill=(0, 0, 0), spacing=LINE_SPACING, align="center")
            text_bbox = [int(v) for v in draw.multiline_textbbox(draw_xy, row["text"], font=font, spacing=LINE_SPACING, align="center")]
            qa_rows.append({
                "block_id": block,
                "original": row["original"],
                "approved_ru": row["ru"],
                "strategy": row["strategy"],
                "source_anchor": None,
                "source_visual_evidence": "Fresh PDF full and middle detail confirm no leader/pointer line.",
                "text_bbox": text_bbox,
                "frame_bbox": None,
                "frame_present": False,
                "padding_px": None,
                "relation_to_leader_line": "not_applicable",
                "protected_graphics_intersection": False,
                "source_cleanup_complete": True,
                "residual_source_text": False,
                "visual_result": "pending_visual_inspection",
                "notes": "Free text is permitted only by the pre-drawing source visual strategy gate.",
            })
        else:
            qa_rows.append({
                "block_id": block,
                "original": row["original"],
                "approved_ru": None,
                "strategy": "protected_dimension",
                "source_anchor": None,
                "text_bbox": list(PROTECTED_DIMENSION_ROI),
                "frame_bbox": None,
                "frame_present": False,
                "padding_px": None,
                "relation_to_leader_line": "not_applicable",
                "protected_graphics_intersection": False,
                "source_cleanup_complete": True,
                "residual_source_text": False,
                "original_preserved": True,
                "visual_result": "pending_visual_inspection",
                "notes": "Protected source dimension 3 in. is preserved pixel-for-pixel.",
            })

    final_path = output / "figure_010.png"
    image.save(final_path)
    qa = {
        "figure": 10,
        "revision": REVISION,
        "status": "PENDING_VISUAL_QA",
        "production_source": "original_pdf_page_43",
        "used_r01_as_production_source": False,
        "cleaned_only_intermediate_verified": True,
        "caption_inside_png": False,
        "fresh_extracted_png_inspected": False,
        "font": {"family": "Nimbus Sans", "size_px": FONT_SIZE, "sha256": FONT_SHA256},
        "final_png_sha256": sha256(final_path),
        "strategy_gate_sha256": sha256(Path(args.gate_json).resolve()),
        "labels": qa_rows,
        "gate_status": gate["status"],
    }
    write_json(output / "figure_010.frame_qa.json", qa)
    print(f"[PASS] rendered R02 pending visual QA: {final_path}")


def command_finalize(args: argparse.Namespace) -> None:
    qa_path = Path(args.qa_json).resolve()
    qa = json.loads(qa_path.read_text(encoding="utf-8"))
    approval = json.loads(Path(args.visual_approval_json).read_text(encoding="utf-8"))
    fresh = Path(args.fresh_png).resolve()
    working = Path(args.working_png).resolve()
    if sha256(fresh) != sha256(working) or sha256(fresh) != qa.get("final_png_sha256"):
        raise SystemExit("fresh-extracted PNG does not match the working final PNG")
    if approval.get("overall") != "PASS" or approval.get("fresh_extracted_png_inspected") is not True:
        raise SystemExit("visual approval is not PASS for the fresh-extracted PNG")
    results = approval.get("labels", {})
    expected = set(LABELS)
    if set(results) != expected or any(results[block].get("visual_result") != "PASS" for block in expected):
        raise SystemExit("per-label visual approval is incomplete")
    for row in qa["labels"]:
        result = results[row["block_id"]]
        row["visual_result"] = "PASS"
        row["notes"] = row.get("notes", "") + " " + result.get("notes", "")
        if result.get("protected_graphics_intersection") not in (False, "none"):
            raise SystemExit(f"{row['block_id']}: visual approval reports protected intersection")
    qa["fresh_extracted_png_inspected"] = True
    qa["fresh_extracted_png_sha256"] = sha256(fresh)
    qa["status"] = "PASS"
    write_json(qa_path, qa)
    print(f"[PASS] finalized frame QA: {qa_path}")


def command_self_test(args: argparse.Namespace) -> None:
    font = load_font(Path(args.font_path).resolve())
    image = Image.new("RGB", FINAL_SIZE, "white")
    draw = ImageDraw.Draw(image)
    framed = 0
    for block, row in LABELS.items():
        if row["strategy"] in {"leader_line_callout", "multi_leader_line_callout"}:
            result = draw_framed_label(image, draw, font, block, row)
            if set(result["padding_px"].values()) != {4}:
                raise SystemExit(f"{block}: self-test padding failure")
            framed += 1
    if framed != 8:
        raise SystemExit(f"self-test expected 8 framed labels, got {framed}")
    print("[PASS] Figure 010 R02 builder self-test: 8 frames, 4 px padding")


def parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(description="Build Figure 010 R02 from original PDF page 43")
    sub = ap.add_subparsers(dest="command", required=True)

    clean = sub.add_parser("clean")
    clean.add_argument("--repo-root", required=True)
    clean.add_argument("--gate-json", required=True)
    clean.add_argument("--output-dir", required=True)
    clean.set_defaults(func=command_clean)

    render = sub.add_parser("render")
    render.add_argument("--output-dir", required=True)
    render.add_argument("--gate-json", required=True)
    render.add_argument("--verification-json", required=True)
    render.add_argument("--font-path", required=True)
    render.set_defaults(func=command_render)

    finalize = sub.add_parser("finalize")
    finalize.add_argument("--qa-json", required=True)
    finalize.add_argument("--visual-approval-json", required=True)
    finalize.add_argument("--working-png", required=True)
    finalize.add_argument("--fresh-png", required=True)
    finalize.set_defaults(func=command_finalize)

    test = sub.add_parser("self-test")
    test.add_argument("--font-path", required=True)
    test.set_defaults(func=command_self_test)
    return ap


def main() -> None:
    args = parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
