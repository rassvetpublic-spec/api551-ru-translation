---
name: api551-full-control-operator
description: Use for API551 Codex package №005 workflows: bounded writes, preview index, GitHub relay, token saver, tooling persistence.
---

# API551 Full Control Operator

## Package numbering

Every Codex handoff package must have a number. Current active package: №005.

## Write boundary

Persistent writes are allowed only under:

- `C:\GIT\api551`
- `C:\GIT\inbox_chatgpt`

Initial reading from `D:\ЗАГРУЗКИ` is allowed only to retrieve a user-provided package ZIP.

## Preview

Review previews are stored under repo paths and shown through root `index.html`.

Use color coding:

- orange: review;
- red: blocker;
- green: accepted;
- gray: skipped.

## Tooling persistence

Any fixed or new tool must be preserved inside the repo:

- implementation: `tools/api551/`
- Russian docs: `docs/project/`
- entrypoint command: documented in the tool doc
- separate tooling PR

No important tool may remain only in chat, local temp, or external script folder.

## Reports

Publish compact text-only draft PRs. Never commit ZIP/PNG/PDF/HTML report artifacts to report branches.

## Chat

Use TOKEN_SAVER format only.
