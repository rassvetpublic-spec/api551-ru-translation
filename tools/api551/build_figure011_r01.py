#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont
import pypdfium2 as pdfium


FIGURE = 11
REVISION = "R01"
PDF_PAGE_INDEX = 44
CROP = (82, 465, 542, 672)
SCALE = 4
SIZE = (1840, 828)
FONT_SHA256 = "7c25be4d78155523080ab85b10277150657ff7dabbcad7037bdd536c9b6d0d08"

LABELS = {
    "block-002": {"original":"Uncertainty in Degrees Celsius","ru":"Неопределённость, градусы Цельсия","strategy":"vertical_axis_title","cleanup":[22,145,82,600]},
    "block-003": {"original":"Temperature in Celsius","ru":"Температура, градусы Цельсия","strategy":"horizontal_axis_title","cleanup":[620,790,1210,827]},
    "block-004": {"original":"Legend","ru":"Легенда","strategy":"legend_table_cell","cell":[1277,223,1811,255],"font":22},
    "block-005": {"original":"Description","ru":"Описание","strategy":"legend_table_cell","cell":[1277,255,1526,286],"font":20},
    "block-006": {"original":"Line Type","ru":"Тип линии","strategy":"legend_table_cell","cell":[1526,255,1811,286],"font":20},
    "block-007": {"original":"Wire Wound (Class A)","ru":"Проволочный RTD (класс A)","strategy":"legend_table_cell","cell":[1277,286,1526,318],"font":16},
    "block-008": {"original":"Thin Film (Class A)","ru":"Тонкоплёночный RTD (класс A)","strategy":"legend_table_cell","cell":[1277,318,1526,349],"font":15},
    "block-009": {"original":"Wire Wound (Class B)","ru":"Проволочный RTD (класс B)","strategy":"legend_table_cell","cell":[1277,349,1526,381],"font":16},
    "block-010": {"original":"Thin Film (Class B)","ru":"Тонкоплёночный RTD (класс B)","strategy":"legend_table_cell","cell":[1277,381,1526,412],"font":15},
    "block-011": {"original":"Thermistor (±0.1°C)","ru":"Термистор (±0,1 °C)","strategy":"legend_table_cell","cell":[1277,412,1526,444],"font":18},
    "block-012": {"original":"Thermistor (±0.2°C)","ru":"Термистор (±0,2 °C)","strategy":"legend_table_cell","cell":[1277,444,1526,475],"font":18},
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def check_gate(path: Path) -> dict:
    gate = load_json(path)
    if gate.get("figure") != "011" or gate.get("revision") != REVISION or gate.get("status") != "PASS":
        raise SystemExit("Figure 011 R01 strategy gate is not PASS")
    actual = {row["block_id"]: row["strategy"] for row in gate.get("labels", [])}
    expected = {key: row["strategy"] for key, row in LABELS.items()}
    if actual != expected:
        raise SystemExit("strategy gate does not match builder labels")
    return gate


def render_source(repo: Path) -> Image.Image:
    pdf = pdfium.PdfDocument(str(repo / "source" / "API 551 2016 (R2024).pdf"))
    page = pdf[PDF_PAGE_INDEX].render(scale=SCALE).to_pil().convert("RGB")
    crop = page.crop(tuple(int(v * SCALE) for v in CROP))
    if crop.size != SIZE:
        raise SystemExit(f"unexpected crop size {crop.size}")
    return crop


def cleanup_rects() -> dict[str, list[int]]:
    rects: dict[str, list[int]] = {}
    for block, row in LABELS.items():
        if row["strategy"].endswith("axis_title"):
            rects[block] = row["cleanup"]
        else:
            x1, y1, x2, y2 = row["cell"]
            rects[block] = [x1 + 1, y1 + 1, x2 - 1, y2 - 1]
    return rects


def command_clean(args: argparse.Namespace) -> None:
    repo = Path(args.repo_root).resolve()
    out = Path(args.output_dir).resolve()
    out.mkdir(parents=True, exist_ok=True)
    gate = check_gate(Path(args.gate_json).resolve())
    source = render_source(repo)
    cleaned = source.copy()
    mask = Image.new("L", source.size, 0)
    draw = ImageDraw.Draw(mask)
    rects = cleanup_rects()
    for rect in rects.values():
        draw.rectangle(rect, fill=255)
        ImageDraw.Draw(cleaned).rectangle(rect, fill="white")
    # Restore protected legend-table border pixels from the fresh source.
    for x1, y1, x2, y2 in [
        (1276,222,1280,477), (1809,222,1813,477), (1524,254,1528,477),
        (1276,222,1813,225), (1276,254,1813,257), (1276,285,1813,288),
        (1276,317,1813,320), (1276,348,1813,351), (1276,380,1813,383),
        (1276,411,1813,414), (1276,443,1813,446), (1276,474,1813,477),
    ]:
        cleaned.paste(source.crop((x1,y1,x2,y2)), (x1,y1))
    diff = ImageChops.difference(source, cleaned).convert("L")
    outside = ImageChops.multiply(diff, ImageChops.invert(mask))
    if outside.getbbox() is not None:
        raise SystemExit("cleanup changed pixels outside cleanup mask")
    source_path = out / "figure_011.source_crop.png"
    cleaned_path = out / "figure_011.cleaned_only.png"
    mask_path = out / "figure_011.cleanup_mask.png"
    source.save(source_path)
    cleaned.save(cleaned_path)
    mask.save(mask_path)
    write_json(out / "figure_011.cleanup_qa.json", {
        "figure":11,"revision":REVISION,"status":"PENDING_VISUAL_QA",
        "production_source":"original_pdf_page_45","crop":list(CROP),"size":list(SIZE),
        "source_sha256":sha(source_path),"cleaned_sha256":sha(cleaned_path),"mask_sha256":sha(mask_path),
        "outside_mask_changes":0,"protected_graphics_policy":"graph/grid/ticks/table borders/line samples unchanged",
        "rects":rects,"strategy_gate_sha256":sha(Path(args.gate_json).resolve()),"gate_status":gate["status"]
    })
    print(f"[PASS] Figure 011 cleaned-only: {cleaned_path}")


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    if sha(path) != FONT_SHA256:
        raise SystemExit("Nimbus Sans font SHA-256 mismatch")
    return ImageFont.truetype(str(path), size)


def centered(draw: ImageDraw.ImageDraw, box: tuple[int,int,int,int], text: str, ft: ImageFont.FreeTypeFont) -> list[int]:
    bbox = draw.textbbox((0, 0), text, font=ft)
    width, height = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = box[0] + (box[2] - box[0] - width) // 2 - bbox[0]
    y = box[1] + (box[3] - box[1] - height) // 2 - bbox[1]
    draw.text((x, y), text, font=ft, fill=(42,42,42))
    return [int(v) for v in draw.textbbox((x, y), text, font=ft)]


def command_render(args: argparse.Namespace) -> None:
    out = Path(args.output_dir).resolve()
    gate = check_gate(Path(args.gate_json).resolve())
    verification = load_json(Path(args.verification_json).resolve())
    cleaned_path = out / "figure_011.cleaned_only.png"
    if verification.get("status") != "PASS" or verification.get("cleaned_only_inspected") is not True:
        raise SystemExit("cleaned-only visual verification is not PASS")
    if verification.get("cleaned_sha256") != sha(cleaned_path):
        raise SystemExit("cleaned-only verification hash mismatch")
    font_path = Path(args.font_path).resolve()
    image = Image.open(cleaned_path).convert("RGB")
    draw = ImageDraw.Draw(image)
    rows = []

    # Vertical source title reads bottom-to-top; preserve that page direction.
    axis_ft = font(font_path, 30)
    text = LABELS["block-002"]["ru"]
    tb = ImageDraw.Draw(Image.new("RGB", (1,1))).textbbox((0,0), text, font=axis_ft)
    layer = Image.new("RGBA", (tb[2]-tb[0]+8, tb[3]-tb[1]+8), (255,255,255,0))
    ImageDraw.Draw(layer).text((4-tb[0],4-tb[1]), text, font=axis_ft, fill=(42,42,42,255))
    rotated = layer.rotate(90, expand=True)
    px = 31
    py = (SIZE[1] - rotated.height) // 2 - 8
    image.paste(rotated, (px, py), rotated)
    rows.append({"block_id":"block-002","strategy":"vertical_axis_title","text_bbox":[px,py,px+rotated.width,py+rotated.height],"frame_required":False,"frame_bbox":None,"source_cleanup_complete":True,"protected_graphics_intersection":False,"visual_result":"pending"})

    x_bbox = centered(draw, (620, 790, 1210, 827), LABELS["block-003"]["ru"], font(font_path, 30))
    rows.append({"block_id":"block-003","strategy":"horizontal_axis_title","text_bbox":x_bbox,"frame_required":False,"frame_bbox":None,"source_cleanup_complete":True,"protected_graphics_intersection":False,"visual_result":"pending"})

    for block in [f"block-{n:03d}" for n in range(4,13)]:
        row = LABELS[block]
        cell = tuple(row["cell"])
        text_bbox = centered(draw, cell, row["ru"], font(font_path, row["font"]))
        if not (cell[0] < text_bbox[0] and cell[1] < text_bbox[1] and text_bbox[2] < cell[2] and text_bbox[3] < cell[3]):
            raise SystemExit(f"{block}: translated text does not fit protected legend cell")
        rows.append({
            "block_id":block,"strategy":"legend_table_cell","text_bbox":text_bbox,"frame_required":False,
            "frame_bbox":list(cell),"frame_kind":"protected_existing_table_cell","frame_preserved":True,
            "cell_padding_px":{"left":text_bbox[0]-cell[0],"top":text_bbox[1]-cell[1],"right":cell[2]-text_bbox[2],"bottom":cell[3]-text_bbox[3]},
            "source_cleanup_complete":True,"protected_graphics_intersection":False,"line_sample_cell_unchanged":True,"visual_result":"pending"
        })
    final = out / "figure_011.png"
    image.save(final)
    write_json(out / "figure_011.frame_qa.json", {
        "figure":11,"revision":REVISION,"status":"PENDING_VISUAL_QA","production_source":"original_pdf_page_45",
        "caption_inside_png":False,"cleaned_only_intermediate_verified":True,"fresh_extracted_png_inspected":False,
        "leader_line_callouts":0,"invented_callout_frames":0,"protected_table_frames_required":9,"final_png_sha256":sha(final),
        "font":{"family":"Nimbus Sans","sha256":FONT_SHA256},"strategy_gate_sha256":sha(Path(args.gate_json).resolve()),
        "labels":[dict({"original":LABELS[r["block_id"]]["original"],"approved_ru":LABELS[r["block_id"]]["ru"]},**r) for r in rows],
        "gate_status":gate["status"]
    })
    print(f"[PASS] Figure 011 rendered pending visual QA: {final}")


def command_finalize(args: argparse.Namespace) -> None:
    qa_path = Path(args.qa_json).resolve()
    qa = load_json(qa_path)
    approval = load_json(Path(args.visual_approval_json).resolve())
    working = Path(args.working_png).resolve()
    fresh = Path(args.fresh_png).resolve()
    if sha(working) != sha(fresh) or sha(fresh) != qa.get("final_png_sha256"):
        raise SystemExit("fresh-extracted PNG hash mismatch")
    if approval.get("overall") != "PASS" or approval.get("fresh_extracted_png_inspected") is not True:
        raise SystemExit("fresh-extracted visual approval is not PASS")
    results = approval.get("labels", {})
    if set(results) != set(LABELS) or any(v.get("visual_result") != "PASS" for v in results.values()):
        raise SystemExit("per-label visual approval incomplete")
    for row in qa["labels"]:
        row["visual_result"] = "PASS"
        row["notes"] = results[row["block_id"]].get("notes", "")
    qa["fresh_extracted_png_inspected"] = True
    qa["fresh_extracted_png_sha256"] = sha(fresh)
    qa["status"] = "PASS"
    write_json(qa_path, qa)
    print(f"[PASS] Figure 011 QA finalized: {qa_path}")


def command_self_test(args: argparse.Namespace) -> None:
    font_path = Path(args.font_path).resolve()
    canvas = Image.new("RGB", SIZE, "white")
    draw = ImageDraw.Draw(canvas)
    for block in [f"block-{n:03d}" for n in range(4,13)]:
        row = LABELS[block]
        bbox = centered(draw, tuple(row["cell"]), row["ru"], font(font_path, row["font"]))
        cell = row["cell"]
        if not (cell[0] < bbox[0] and cell[1] < bbox[1] and bbox[2] < cell[2] and bbox[3] < cell[3]):
            raise SystemExit(f"{block}: self-test cell fit failed")
    print("[PASS] Figure 011 builder self-test: 9 protected legend cells fit")


def parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="command", required=True)
    p = sub.add_parser("clean"); p.add_argument("--repo-root", required=True); p.add_argument("--gate-json", required=True); p.add_argument("--output-dir", required=True); p.set_defaults(func=command_clean)
    p = sub.add_parser("render"); p.add_argument("--output-dir", required=True); p.add_argument("--gate-json", required=True); p.add_argument("--verification-json", required=True); p.add_argument("--font-path", required=True); p.set_defaults(func=command_render)
    p = sub.add_parser("finalize"); p.add_argument("--qa-json", required=True); p.add_argument("--visual-approval-json", required=True); p.add_argument("--working-png", required=True); p.add_argument("--fresh-png", required=True); p.set_defaults(func=command_finalize)
    p = sub.add_parser("self-test"); p.add_argument("--font-path", required=True); p.set_defaults(func=command_self_test)
    return ap


def main() -> None:
    args = parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
