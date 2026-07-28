#!/usr/bin/env python3
"""Repo-local API551 Stage 4 toolkit.

Read-only checks are the default. Write actions never commit, push, merge, or delete branches.
"""

from __future__ import annotations

import argparse
from datetime import date
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path
from typing import Any

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
LFS_POINTER_PREFIX = b"version https://git-lfs.github.com/spec/v1"


class Api551Error(RuntimeError):
    pass


def fail(message: str) -> None:
    raise Api551Error(message)


def figure_id(value: str | int) -> str:
    try:
        return f"{int(value):03d}"
    except Exception as exc:
        raise Api551Error(f"bad Figure number: {value!r}") from exc


def repo_root(start: Path | None = None) -> Path:
    current = (start or Path.cwd()).resolve()
    for path in [current, *current.parents]:
        if (path / "catalog.json").is_file() and (path / "source").is_dir():
            return path
    fail("Cannot locate API551 repo root; run from inside the repository.")


def rel_path(root: Path, value: str | Path) -> Path:
    return root / Path(str(value).replace("/", os.sep))


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def write(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")


def read_json(path: Path) -> Any:
    return json.loads(read_text(path))


def load_config(root: Path) -> dict[str, Any]:
    path = root / "tools" / "api551" / "api551.config.json"
    if not path.is_file():
        fail(f"missing toolkit config: {path}")
    return read_json(path)


def ensure_file(root: Path, name: str) -> Path:
    path = rel_path(root, name)
    if not path.is_file():
        fail(f"missing required file: {name}")
    return path


def ensure_dir(root: Path, name: str) -> Path:
    path = rel_path(root, name)
    if not path.is_dir():
        fail(f"missing required directory: {name}")
    return path


def is_png_or_lfs(path: Path) -> bool:
    if not path.is_file():
        return False
    data = path.read_bytes()
    return data.startswith(PNG_SIGNATURE) or data.startswith(LFS_POINTER_PREFIX)


def require_real_png_bytes(data: bytes, name: str) -> None:
    if data.startswith(LFS_POINTER_PREFIX):
        fail(f"package contains LFS pointer instead of real PNG: {name}")
    if not data.startswith(PNG_SIGNATURE):
        fail(f"package PNG has invalid signature: {name}")


def has_tool_marker(text: str) -> bool:
    return "tools/api551/api551.ps1" in text or ".\\tools\\api551\\api551.ps1" in text


def is_accepted_approval_status(value: Any, cfg: dict[str, Any]) -> bool:
    if value in set(cfg.get("accepted_status_values", ["accepted", "approved", None])):
        return True
    text = "" if value is None else str(value)
    prefixes = cfg.get("accepted_status_prefixes", ["accepted_by_user_"])
    return any(text.startswith(prefix) for prefix in prefixes)


def catalog_stats(catalog: dict[str, Any]) -> dict[str, Any]:
    figures = catalog.get("figures", [])
    accepted = sorted(int(f["figure_no"]) for f in figures if f.get("status") == "accepted")
    changed = sorted(int(f["figure_no"]) for f in figures if str(f.get("status", "")).startswith("измененно_"))
    not_accepted = sorted(int(f["figure_no"]) for f in figures if f.get("status") == "not_accepted")
    return {
        "total": len(figures),
        "accepted": len(accepted),
        "changed": len(changed),
        "not_accepted": len(not_accepted),
        "accepted_figures": accepted,
        "changed_figures": changed,
        "not_accepted_figures": not_accepted,
    }


def validate_status_sync(root: Path) -> dict[str, Any]:
    catalog = read_json(root / "catalog.json")
    handoff = read_json(root / "docs" / "project" / "API551_STAGE4_HANDOFF_CURRENT.json")
    stats = catalog_stats(catalog)
    if stats["total"] != 69:
        fail(f"catalog must contain 69 figures, got {stats['total']}")
    expected_catalog_stats = {
        "total": stats["total"],
        "accepted": stats["accepted"],
        "changed": stats["changed"],
        "not_accepted": stats["not_accepted"],
    }
    if catalog.get("stats", {}) != expected_catalog_stats:
        fail(f"catalog.stats mismatch: {catalog.get('stats', {})} != {expected_catalog_stats}")
    for key, value in {
        "figures_total": stats["total"],
        "figures_accepted": stats["accepted"],
        "figures_changed": stats["changed"],
        "figures_not_accepted": stats["not_accepted"],
    }.items():
        if handoff.get(key) != value:
            fail(f"handoff {key} mismatch: {handoff.get(key)} != {value}")
    if sorted(map(int, handoff.get("accepted_figures", []))) != stats["accepted_figures"]:
        fail("handoff accepted_figures mismatch")
    return stats


def docs_sync_check(root: Path, quiet: bool = False) -> dict[str, Any]:
    stats = validate_status_sync(root)
    docs = [
        root / "README.md",
        root / "docs" / "API551_PROJECT_QUICK_START_CURRENT.md",
        root / "docs" / "project" / "API551_NEW_CHAT_START_RU.md",
        root / "docs" / "project" / "API551_TOOLING_CURRENT.md",
        root / "docs" / "project" / "API551_SOURCE_GATE_CURRENT.md",
    ]
    for doc in docs:
        if not doc.is_file():
            fail(f"missing documentation file: {doc.relative_to(root).as_posix()}")
        text = read_text(doc)
        if "source-gate" not in text:
            fail(f"documentation does not mention source-gate: {doc.relative_to(root).as_posix()}")
    bootstrap = read_text(root / "docs" / "project" / "API551_NEW_CHAT_START_RU.md")
    for marker in [f"accepted: {stats['accepted']}/69", f"not_accepted: {stats['not_accepted']}/69", f"changed/review: {stats['changed']}"]:
        if marker not in bootstrap:
            fail(f"bootstrap marker missing: {marker}")
    for doc in [root / "README.md", root / "docs" / "API551_PROJECT_QUICK_START_CURRENT.md", root / "docs" / "project" / "API551_NEW_CHAT_START_RU.md"]:
        text = read_text(doc)
        if "docs/project/API551_STAGE4_HANDOFF_CURRENT.json" not in text:
            fail(f"{doc.relative_to(root).as_posix()} does not mention handoff JSON")
        if not has_tool_marker(text):
            fail(f"{doc.relative_to(root).as_posix()} does not mention repo-local toolkit entrypoint")
    if not quiet:
        print("docs/status sync OK")
    return stats


def source_gate(args: argparse.Namespace) -> None:
    root = repo_root()
    cfg = load_config(root)
    for dirname in cfg["required_dirs"]:
        ensure_dir(root, dirname)
    for filename in cfg["mandatory_source_files"]:
        ensure_file(root, filename)
    for filename in cfg["current_rule_files"]:
        text = read_text(ensure_file(root, filename))
        if "CURRENT" not in text or "active" not in text.lower():
            fail(f"rule file does not declare CURRENT active status: {filename}")
    for filename in [
        "catalog.json",
        "index.html",
        ".github/workflows/structure-check.yml",
        ".github/workflows/api551-tooling-check.yml",
        "tools/api551/api551.ps1",
        "tools/api551/api551.py",
    ]:
        ensure_file(root, filename)
    stats = docs_sync_check(root, quiet=True)
    if (root / ".git").exists() and not args.ci:
        try:
            branch = subprocess.check_output(["git", "branch", "--show-current"], cwd=root, text=True, stderr=subprocess.DEVNULL).strip()
            allowed = {cfg["working_branch"], "tools/api551-stage4-toolkit-v1"}
            allowed_prefixes = ("accept-", "fix-", "fix/", "tools/", "docs/", "ci/", "rules/")
            if branch and branch not in allowed and not branch.startswith(allowed_prefixes):
                fail(f"current branch is {branch!r}; expected one of {sorted(allowed)} or work branch prefixes {allowed_prefixes}")
        except subprocess.CalledProcessError:
            pass
    print("source-gate OK")
    print(json.dumps(stats, ensure_ascii=False, indent=2))


def status(args: argparse.Namespace) -> None:
    stats = validate_status_sync(repo_root())
    if args.json:
        print(json.dumps(stats, ensure_ascii=False, indent=2))
        return
    print(f"total: {stats['total']}")
    print(f"accepted: {stats['accepted']}/69")
    print(f"changed/review: {stats['changed']}")
    print(f"not_accepted: {stats['not_accepted']}/69")
    print("accepted_figures: " + ",".join(map(str, stats["accepted_figures"])))


def find_catalog_figure_in(catalog: dict[str, Any], fig_id: str) -> dict[str, Any]:
    for item in catalog.get("figures", []):
        if figure_id(item.get("figure_no")) == fig_id:
            return item
    fail(f"Figure {fig_id} not found in catalog")


def find_catalog_figure(root: Path, fig_id: str) -> dict[str, Any]:
    return find_catalog_figure_in(read_json(root / "catalog.json"), fig_id)


def validate_image_refs(html_path: Path) -> None:
    text = read_text(html_path)
    for src in re.findall(r"<img[^>]+src=[\"']([^\"']+)[\"']", text, flags=re.I):
        if src.startswith(("http://", "https://", "data:")):
            continue
        target = (html_path.parent / src).resolve()
        if not target.is_file():
            fail(f"broken image reference in {html_path}: {src}")


def figure_check(args: argparse.Namespace) -> None:
    root = repo_root()
    cfg = load_config(root)
    catalog = read_json(root / "catalog.json")
    figures = ([figure_id(f.get("figure_no")) for f in catalog.get("figures", []) if f.get("status") == "accepted"] if args.all_known else [figure_id(args.figure)])
    checked = 0
    for fig_id in figures:
        fig = find_catalog_figure(root, fig_id)
        status = fig.get("status")
        if status == "accepted":
            for key in ["folder", "html", "json", "png", "source_crop", "out_html"]:
                value = fig.get(key)
                if not value:
                    fail(f"Figure {fig_id} missing catalog key: {key}")
                if not rel_path(root, value).exists():
                    fail(f"Figure {fig_id} catalog path missing for {key}: {value}")
            html_path = rel_path(root, fig["html"])
            json_path = rel_path(root, fig["json"])
            out_path = rel_path(root, fig["out_html"])
            png_path = rel_path(root, fig["png"])
            source_crop_path = rel_path(root, fig["source_crop"])
        else:
            fig_dir = root / "workspace" / "figures" / fig_id
            if not fig_dir.is_dir():
                fail(f"Figure {fig_id} is {status!r} in catalog and has no review folder: {fig_dir.relative_to(root).as_posix()}")
            html_path = fig_dir / f"figure_{fig_id}.object.html"
            json_path = fig_dir / f"figure_{fig_id}.object.json"
            out_path = fig_dir / f"figure_{fig_id}.out.html"
            png_path = fig_dir / f"figure_{fig_id}.png"
            source_crop_path = fig_dir / f"figure_{fig_id}.source_crop.png"
            for path in [html_path, json_path, out_path, png_path, source_crop_path]:
                if not path.exists():
                    fail(f"Figure {fig_id} review path missing: {path.relative_to(root).as_posix()}")
        for path, key in [(png_path, "png"), (source_crop_path, "source_crop")]:
            if not is_png_or_lfs(path):
                fail(f"Figure {fig_id} {key} is neither PNG nor LFS pointer: {path.relative_to(root).as_posix()}")
        obj = read_json(json_path)
        if status == "accepted":
            if not is_accepted_approval_status(obj.get("approval_status"), cfg):
                fail(f"Figure {fig_id} object JSON approval_status is not recognized as accepted")
            if "review_only_not_accepted" in json.dumps(obj, ensure_ascii=False):
                fail(f"Figure {fig_id} object JSON contains review_only_not_accepted")
        validate_image_refs(html_path)
        validate_image_refs(out_path)
        html_text = read_text(html_path)
        out_text = read_text(out_path)
        if status == "accepted" and "review_only_not_accepted" in html_text:
            fail(f"Figure {fig_id} object HTML contains review_only_not_accepted")
        for marker in cfg.get("service_markers_forbidden_in_out_html", []):
            if marker in out_text:
                fail(f"Figure {fig_id} out.html contains service marker: {marker}")
        checked += 1
    print(f"figure-check OK ({checked} figure(s))")


def package_roots(names: list[str]) -> list[str]:
    return sorted({name.split("/", 1)[0] for name in names if "/" in name and name.split("/", 1)[0]})


def package_check(args: argparse.Namespace) -> None:
    root = repo_root()
    cfg = load_config(root)
    zip_path = Path(args.package_zip).expanduser().resolve()
    if not zip_path.is_file():
        fail(f"package ZIP not found: {zip_path}")
    fig_id = figure_id(args.figure) if args.figure else None
    with zipfile.ZipFile(zip_path) as zf:
        bad = zf.testzip()
        if bad:
            fail(f"ZIP integrity failed at {bad}")
        names = [name.replace("\\", "/") for name in zf.namelist()]
        if any(name.lower().endswith(".pdf") for name in names):
            fail("package must not include PDF files")
        roots = package_roots(names)
        if fig_id is None:
            if len(roots) != 1 or not re.fullmatch(r"\d{3}", roots[0]):
                fail(f"package must contain exactly one NNN root folder, got {roots}")
            fig_id = roots[0]
        if roots != [fig_id]:
            fail(f"package must contain only root folder {fig_id}/, got {roots}")
        required = [
            f"{fig_id}/figure_{fig_id}.caption_ru.txt",
            f"{fig_id}/figure_{fig_id}.object.html",
            f"{fig_id}/figure_{fig_id}.object.json",
            f"{fig_id}/figure_{fig_id}.out.html",
            f"{fig_id}/figure_{fig_id}.png",
            f"{fig_id}/figure_{fig_id}.source_crop.png",
        ]
        missing = [name for name in required if name not in names]
        if missing:
            fail("package missing required files: " + ", ".join(missing))
        for name in [n for n in names if n.lower().endswith((".html", ".json", ".md", ".txt", ".csv"))]:
            text = zf.read(name).decode("utf-8-sig", errors="replace")
            if "file:///C:/Users/" in text or "C:/Users/" in text or "C:\\Users\\" in text:
                fail(f"package contains forbidden local user path: {name}")
            if name.endswith(".out.html"):
                for marker in cfg.get("service_markers_forbidden_in_out_html", []):
                    if marker in text:
                        fail(f"out.html contains service marker {marker}: {name}")
        obj_text = zf.read(f"{fig_id}/figure_{fig_id}.object.json").decode("utf-8-sig")
        obj = json.loads(obj_text)
        if is_accepted_approval_status(obj.get("approval_status"), cfg) and "review_only_not_accepted" in obj_text:
            fail("accepted object JSON contains review_only_not_accepted")
        for name in required:
            if name.lower().endswith(".png"):
                require_real_png_bytes(zf.read(name), name)
        name_set = set(names)
        for html_name in [f"{fig_id}/figure_{fig_id}.object.html", f"{fig_id}/figure_{fig_id}.out.html"]:
            html = zf.read(html_name).decode("utf-8-sig", errors="replace")
            if is_accepted_approval_status(obj.get("approval_status"), cfg) and "review_only_not_accepted" in html:
                fail(f"accepted HTML contains review_only_not_accepted: {html_name}")
            for src in re.findall(r"<img[^>]+src=[\"']([^\"']+)[\"']", html, flags=re.I):
                if src.startswith(("http://", "https://", "data:")):
                    continue
                resolved = f"{fig_id}/{src}" if not src.startswith(f"{fig_id}/") else src
                if resolved not in name_set:
                    fail(f"broken package image reference {src} in {html_name}")
    print(f"package-check OK: {zip_path}")


def safe_extract_figure_root(zf: zipfile.ZipFile, destination: Path, fig_id: str) -> None:
    base = destination.resolve()
    prefix = f"{fig_id}/"
    members = []
    for info in zf.infolist():
        name = info.filename.replace(chr(92), "/")
        if not name.startswith(prefix):
            fail(f"refusing to extract non-selected package member: {name}")
        target = (destination / name).resolve()
        if not str(target).startswith(str(base) + os.sep):
            fail(f"refusing unsafe ZIP path: {name}")
        members.append((info, name, target))
    for info, name, target in members:
        if info.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        try:
            with zf.open(info) as src, open(target, "wb") as dst:
                shutil.copyfileobj(src, dst)
        except PermissionError as exc:
            fail(
                f"cannot write extracted file due to Windows permission/file-lock: {target}. "
                "Close Explorer preview, image viewers, browser tabs, and retry. "
                f"Original error: {exc}"
            )


def remove_tree_for_install(target: Path) -> None:
    if not target.exists():
        return

    def onerror(func, path, exc_info):
        try:
            os.chmod(path, 0o700)
            func(path)
        except PermissionError as exc:
            fail(
                f"cannot remove existing install target due to Windows permission/file-lock: {path}. "
                "Close Explorer preview, image viewers, browser tabs, and retry. "
                f"Original error: {exc}"
            )

    try:
        shutil.rmtree(target, onerror=onerror)
    except PermissionError as exc:
        fail(
            f"cannot remove existing install target due to Windows permission/file-lock: {target}. "
            "Close Explorer preview, image viewers, browser tabs, and retry. "
            f"Original error: {exc}"
        )


def install_package(args: argparse.Namespace) -> None:
    package_check(args)
    root = repo_root()
    fig_id = figure_id(args.figure) if args.figure else None
    with zipfile.ZipFile(Path(args.package_zip).expanduser().resolve()) as zf:
        names = [name.replace(chr(92), "/") for name in zf.namelist()]
        if fig_id is None:
            fig_id = package_roots(names)[0]
        target = root / "workspace" / "figures" / fig_id
        remove_tree_for_install(target)
        safe_extract_figure_root(zf, root / "workspace" / "figures", fig_id)
    print(f"installed package to workspace/figures/{fig_id}")



def write_json(path: Path, data: Any) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def update_catalog_stats(catalog: dict[str, Any]) -> dict[str, Any]:
    stats = catalog_stats(catalog)
    catalog["stats"] = {
        "total": stats["total"],
        "accepted": stats["accepted"],
        "changed": stats["changed"],
        "not_accepted": stats["not_accepted"],
    }
    return stats


def html_escape(value: Any) -> str:
    text = "" if value is None else str(value)
    return (text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace('"', "&quot;"))


def render_index_html(catalog: dict[str, Any]) -> str:
    stats = catalog_stats(catalog)
    rows: list[str] = []
    for fig in catalog.get("figures", []):
        no = int(fig.get("figure_no"))
        status = str(fig.get("status", ""))
        caption = html_escape(fig.get("caption_ru") or fig.get("caption_original") or f"Figure {no}")
        cls = "accepted" if status == "accepted" else ("changed" if status.startswith("измененно_") else "pending")
        if status == "accepted" and fig.get("out_html"):
            export = f'<a href="{html_escape(fig.get("out_html"))}">{caption}</a>'
            service = f'<a href="{html_escape(fig.get("html"))}">service</a>' if fig.get("html") else ""
        else:
            export = caption
            service = ""
        source_link = fig.get("source_pdf_link", "")
        source = f'<a href="{html_escape(source_link)}">PDF</a>' if source_link else ""
        rows.append(f'<tr class="{cls}"><td>{no}</td><td>{html_escape(status)}</td><td>{export}</td><td>{service}</td><td>{source}</td></tr>')
    return """<!doctype html>
<html lang="ru"><head><meta charset="utf-8"><title>API 551 Stage 4 - Figure catalog</title>
<style>body{font-family:Arial,sans-serif;margin:24px;color:#111827;background:#f6f7f9}main{max-width:1240px;margin:0 auto;background:#fff;border:1px solid #d9dee7;padding:22px}h1{margin:0 0 8px;font-size:22px}.meta{color:#4b5563;margin-bottom:16px}table{width:100%;border-collapse:collapse;table-layout:fixed}th,td{border-bottom:1px solid #e5e7eb;padding:7px 8px;text-align:left;vertical-align:top;font-size:14px;word-break:normal;overflow-wrap:normal;hyphens:none}th:first-child,td:first-child{width:64px;text-align:right;white-space:nowrap}th:nth-child(2),td:nth-child(2){width:180px;white-space:nowrap}th:nth-child(4),td:nth-child(4){width:82px;white-space:nowrap}th:nth-child(5),td:nth-child(5){width:68px;white-space:nowrap}th:nth-child(3),td:nth-child(3){overflow-wrap:break-word;word-break:normal}tr.accepted td:nth-child(2){color:#166534;font-weight:700}tr.changed td:nth-child(2){color:#854d0e;font-weight:700}tr.pending td:nth-child(2){color:#991b1b}a{color:#0f3b7a}</style></head><body><main>
<h1>API 551 Stage 4 - Figure catalog</h1>
""" + f'<div class="meta">Accepted: {stats["accepted"]}/69. Changed: {stats["changed"]}. Portable local review export; all links are relative to the repository root.</div>\n' + """<table><thead><tr><th>Figure</th><th>Status</th><th>Export object</th><th>Service</th><th>Source</th></tr></thead><tbody>
""" + "\n".join(rows) + """
</tbody></table></main></body></html>
"""


def update_handoff(root: Path, stats: dict[str, Any]) -> None:
    handoff_path = root / "docs" / "project" / "API551_STAGE4_HANDOFF_CURRENT.json"
    handoff = read_json(handoff_path)
    handoff["updated"] = date.today().isoformat()
    handoff["figures_total"] = stats["total"]
    handoff["figures_accepted"] = stats["accepted"]
    handoff["figures_changed"] = stats["changed"]
    handoff["figures_not_accepted"] = stats["not_accepted"]
    handoff["accepted_figures"] = stats["accepted_figures"]
    write_json(handoff_path, handoff)


def update_bootstrap_markers(root: Path, stats: dict[str, Any]) -> None:
    path = root / "docs" / "project" / "API551_NEW_CHAT_START_RU.md"
    text = read_text(path)
    text = re.sub(r"accepted: \d+/69", f"accepted: {stats['accepted']}/69", text)
    text = re.sub(r"not_accepted: \d+/69", f"not_accepted: {stats['not_accepted']}/69", text)
    text = re.sub(r"changed/review: \d+", f"changed/review: {stats['changed']}", text)
    text = re.sub(r"Текущий статус после принятия Figure .*?:", "Текущий статус Stage 4:", text)
    if "accept-figure" not in text:
        text += """

## accept-figure

Для принятого пользователем Figure-кандидата использовать repo-local команду:

```powershell
.\tools\api551\api551.ps1 accept-figure -Figure NNN -PackageZip <path-to-review-zip>
```

Команда устанавливает пакет, переводит Figure в `accepted`, обновляет `catalog.json`, `index.html`, handoff/bootstrap status и hard-coded acceptance state в workflow. Команда не выполняет commit, push или merge.
"""
    path.write_text(text, encoding="utf-8")


def update_structure_check(root: Path, stats: dict[str, Any]) -> None:
    path = root / ".github" / "workflows" / "structure-check.yml"
    text = read_text(path)
    accepted_set = ", ".join(map(str, stats["accepted_figures"]))
    text = re.sub(r"accepted_expected = \{[^}]*\}", f"accepted_expected = {{{accepted_set}}}", text, count=1, flags=re.S)
    text = re.sub(r"if len\(not_accepted\) != \d+:", f"if len(not_accepted) != {stats['not_accepted']}:", text, count=1)
    text = re.sub(
        r"expected_stats = \{\"total\": 69, \"accepted\": \d+, \"changed\": \d+, \"not_accepted\": \d+\}",
        f"expected_stats = {{\"total\": 69, \"accepted\": {stats['accepted']}, \"changed\": {stats['changed']}, \"not_accepted\": {stats['not_accepted']}}}",
        text,
        count=1,
    )
    write(path, text)


def ensure_caption_file(root: Path, fig_id: str, caption: str) -> None:
    path = root / "workspace" / "figures" / fig_id / f"figure_{fig_id}.caption_ru.txt"
    if not path.is_file():
        path.write_text(caption.rstrip() + "\n", encoding="utf-8")


def accept_figure(args: argparse.Namespace) -> None:
    root = repo_root()
    fig_id = figure_id(args.figure)
    package_check(args)
    install_package(args)

    catalog_path = root / "catalog.json"
    catalog = read_json(catalog_path)
    fig = find_catalog_figure_in(catalog, fig_id)
    caption = fig.get("caption_ru") or fig.get("caption_original") or f"Figure {int(fig_id)}"
    fig_dir = root / "workspace" / "figures" / fig_id
    ensure_caption_file(root, fig_id, str(caption))

    json_path = fig_dir / f"figure_{fig_id}.object.json"
    obj = read_json(json_path)
    today = date.today().isoformat()
    obj["status"] = "accepted"
    obj["approval_status"] = f"accepted_by_user_{today}"
    obj["stage4_status"] = "accepted"
    obj["ready_for_final_export"] = True
    obj["source_package"] = Path(args.package_zip).stem.replace("REVIEW", "ACCEPTED")
    write_json(json_path, obj)

    rel_base = f"workspace/figures/{fig_id}"
    fig.update({
        "status": "accepted",
        "folder": rel_base,
        "source_package": Path(args.package_zip).stem.replace("REVIEW", "ACCEPTED"),
        "html": f"{rel_base}/figure_{fig_id}.object.html",
        "json": f"{rel_base}/figure_{fig_id}.object.json",
        "png": f"{rel_base}/figure_{fig_id}.png",
        "source_crop": f"{rel_base}/figure_{fig_id}.source_crop.png",
        "out_html": f"{rel_base}/figure_{fig_id}.out.html",
    })
    if not fig.get("source_pdf_link") and fig.get("pdf_page"):
        fig["source_pdf_link"] = f"source/API%20551%202016%20(R2024).pdf#page={fig['pdf_page']}"

    stats = update_catalog_stats(catalog)
    write_json(catalog_path, catalog)
    (root / "index.html").write_text(render_index_html(catalog), encoding="utf-8")
    update_handoff(root, stats)
    update_bootstrap_markers(root, stats)
    update_structure_check(root, stats)

    docs_sync_check(root, quiet=True)
    figure_check(argparse.Namespace(figure=fig_id, all_known=False, ci=True))
    figure_check(argparse.Namespace(figure=None, all_known=True, ci=True))
    print(f"accepted Figure {fig_id}: {stats['accepted']}/69 accepted, {stats['not_accepted']}/69 not_accepted")

def rules_for(args: argparse.Namespace) -> None:
    root = repo_root()
    fig_id = figure_id(args.figure)
    cfg = load_config(root)
    fig = find_catalog_figure(root, fig_id)
    rule_map_path = root / "tools" / "api551" / "rules" / "figure_rule_map.json"
    rule_map = read_json(rule_map_path) if rule_map_path.is_file() else {}
    notes = rule_map.get(fig_id, [])
    report_dir = root / "reports" / "source_gate"
    report_dir.mkdir(parents=True, exist_ok=True)
    report_path = report_dir / f"figure_{fig_id}_rules_report.md"
    work_order_path = report_dir / f"figure_{fig_id}_work_order.json"
    report = [
        f"# Figure {fig_id} rules report",
        "",
        f"Status in catalog: `{fig.get('status')}`",
        f"Caption: {fig.get('caption_ru') or fig.get('caption') or ''}",
        "",
        "## Mandatory active rule files",
        *[f"- `{path}`" for path in cfg["current_rule_files"]],
        "",
        "## Figure-specific notes",
    ]
    report.extend([f"- {note}" for note in notes] or ["- No dedicated note in tools/api551/rules/figure_rule_map.json; apply universal rules and source-gate."])
    report.extend([
        "",
        "## Mandatory workflow",
        "1. Use PDF-derived clean source crop as visual truth.",
        "2. Use approved label master CSV for unaccepted figures.",
        "3. Use accepted object as priority for accepted figures.",
        "4. Complete source-text cleanup before Russian rendering.",
        "5. Validate package with `package-check` before install/PR.",
    ])
    report_path.write_text("\n".join(report) + "\n", encoding="utf-8")
    work_order = {
        "figure": int(fig_id),
        "status": fig.get("status"),
        "rule_files": cfg["current_rule_files"],
        "figure_notes": notes,
        "source_gate_required": True,
        "package_check_required": True,
    }
    work_order_path.write_text(json.dumps(work_order, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"rules report: {report_path.relative_to(root).as_posix()}")
    print(f"work order: {work_order_path.relative_to(root).as_posix()}")


def open_review(args: argparse.Namespace) -> None:
    root = repo_root()
    fig_id = figure_id(args.figure)
    fig = find_catalog_figure(root, fig_id)
    key = "html" if args.service else "out_html"
    path = rel_path(root, fig[key])
    if not path.is_file():
        fail(f"review file not found: {path}")
    if sys.platform.startswith("win"):
        os.startfile(str(path))  # type: ignore[attr-defined]
    elif sys.platform == "darwin":
        subprocess.run(["open", str(path)], check=True)
    else:
        subprocess.run(["xdg-open", str(path)], check=True)
    print(path)


def pr_check(args: argparse.Namespace) -> None:
    gh = shutil.which("gh")
    if not gh:
        fail("GitHub CLI `gh` not found. Use GitHub PR page or install gh.")
    root = repo_root()
    repo = load_config(root)["repo"]
    cmd = [gh, "pr", "view", str(args.pr), "--repo", repo, "--json", "url,state,isDraft,mergeable,headRefName,headRefOid,baseRefName,changedFiles,commits"]
    print(subprocess.check_output(cmd, cwd=root, text=True))
    checks = subprocess.run([gh, "pr", "checks", str(args.pr), "--repo", repo], cwd=root, text=True)
    if checks.returncode not in (0, 1):
        raise SystemExit(checks.returncode)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="api551", description="API551 Stage 4 repo-local toolkit")
    sub = parser.add_subparsers(dest="action", required=True)
    p = sub.add_parser("source-gate"); p.add_argument("--ci", action="store_true"); p.set_defaults(func=source_gate)
    p = sub.add_parser("status"); p.add_argument("--ci", action="store_true"); p.add_argument("--json", action="store_true"); p.set_defaults(func=status)
    p = sub.add_parser("docs-sync-check"); p.add_argument("--ci", action="store_true"); p.set_defaults(func=lambda args: docs_sync_check(repo_root()))
    p = sub.add_parser("figure-check"); p.add_argument("-Figure", "--figure", default=None); p.add_argument("--all-known", action="store_true"); p.add_argument("--ci", action="store_true"); p.set_defaults(func=figure_check)
    p = sub.add_parser("package-check"); p.add_argument("-PackageZip", "--package-zip", required=True); p.add_argument("-Figure", "--figure", default=None); p.set_defaults(func=package_check)
    p = sub.add_parser("install-package"); p.add_argument("-PackageZip", "--package-zip", required=True); p.add_argument("-Figure", "--figure", default=None); p.set_defaults(func=install_package)
    p = sub.add_parser("accept-figure"); p.add_argument("-PackageZip", "--package-zip", required=True); p.add_argument("-Figure", "--figure", required=True); p.set_defaults(func=accept_figure)
    p = sub.add_parser("rules-for"); p.add_argument("-Figure", "--figure", required=True); p.set_defaults(func=rules_for)
    p = sub.add_parser("open-review"); p.add_argument("-Figure", "--figure", required=True); p.add_argument("--service", action="store_true"); p.set_defaults(func=open_review)
    p = sub.add_parser("pr-check"); p.add_argument("-Pr", "--pr", required=True); p.set_defaults(func=pr_check)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        args.func(args)
        return 0
    except Api551Error as exc:
        print(f"[STOP] {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
