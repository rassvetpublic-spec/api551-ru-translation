# Uploaded Chat Sources Archive — 2026-06-26

Status: ARCHIVE / SOURCE-INBOX  
Project: API 551 RU Translation / Stage 4 Figure Objects  
Archive reason: files were present in chat/project sources and needed GitHub preservation without promoting them to active Source.

## Placement decision

These files are preserved under this archive folder only. They are **not** added to `source/`, `catalog.json`, `index.html`, or the active source manifest.

Reason: current repository policy keeps active Source minimized. The active source set is defined by `source/API551_SOURCE_MANIFEST_CURRENT.json` and checked by `.github/workflows/structure-check.yml`; adding these files to `source/` would change the active source-of-truth model and likely fail the structure check unless the policy/manifest/workflow are intentionally revised.

## Classification

| File | Size, bytes | SHA-256 | Role | Decision |
|---|---:|---|---|---|
| `API551_00_ACTIVE_SOURCE_INDEX.md` | 3113 | `e5c5557de727dfadf59407545a2af300b13eab72b6df2eed3878fa498a984ddb` | old/portable source index from chat sources | archive only; useful as provenance; not current authority |
| `API551_01_PROJECT_INSTRUCTIONS.md` | 2662 | `3c3b9686c8e49dbad325a70978b8710b4b30eff2a61873f21853d0edf4b6520a` | project instruction snapshot | archive only; useful as provenance; repo active policy remains current source |
| `API551_03_HANDOFF_FOR_NEW_CHAT.md` | 1808 | `3f566c9aeffcbfa6ee5c1b7d9552c26364144af6ddaefbfaf953d769c661756d` | new-chat handoff prompt | archive only; prompts/handoff reference, not source-of-truth |
| `GITHUB_SKILL_FOR_CHATGPT.zip` | 3808 | `59c873de20f4d4263511fe05e59a2eb456dc50aa87eb9262e26ec9404eda2183` | generic GitHub operation skill package | archive only; extracted readable members included below |

## Extracted ZIP members

Extracted from `GITHUB_SKILL_FOR_CHATGPT.zip` for readability:

- `GITHUB_SKILL_FOR_CHATGPT/GITHUB_SKILL_FOR_CHATGPT.md`
- `GITHUB_SKILL_FOR_CHATGPT/GITHUB_SKILL_HANDOFF.md`
- `GITHUB_SKILL_FOR_CHATGPT/GITHUB_SKILL_SHORT_CUSTOM_INSTRUCTIONS.txt`

## Non-promotion guard

Do not use this archive folder as generation input for Stage 4 Figure production. Treat it as provenance/reference only unless the user explicitly reopens the source model and updates the active policy/manifest/workflow together.
