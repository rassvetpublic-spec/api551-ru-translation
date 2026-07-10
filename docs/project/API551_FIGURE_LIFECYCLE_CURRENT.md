# API551 Figure Lifecycle Current

Status: CURRENT lifecycle for Stage 4 Figure objects.

## 1. States

```text
not_accepted -> review/changed package -> explicit user acceptance -> accepted
```

Accepted state is not automatic. A Figure remains review/changed/not_accepted until the user explicitly accepts a specific version.

## 2. Production sequence

```text
source-gate -> rules-for -> clean source crop -> source-text cleanup -> clean intermediate QA -> Russian rendering -> object build -> package-check -> review -> user decision
```

## 3. Rework rule

Every rework/correction/revision pass must start from the clean PDF-derived source crop or another clean project source. Do not use old translated PNGs, old review PNGs, overlay results, or contaminated mixed sources as production source.

Old translated/review assets may be used only as visual reference.

## 4. Accepted Figure rule

After acceptance:

- the accepted Stage 4 object becomes priority for that Figure;
- label count, translations, placement, reconstruction decisions, and status are frozen;
- status must stay synchronized in `catalog.json`, `index.html`, object JSON, object HTML, and handoff JSON;
- changes require explicit reopening by the user.

## 5. Acceptance PR contents

A Figure acceptance PR must include all synchronized state updates:

```text
workspace/figures/<NNN>/figure_<NNN>.object.json
workspace/figures/<NNN>/figure_<NNN>.object.html
workspace/figures/<NNN>/figure_<NNN>.out.html
workspace/figures/<NNN>/figure_<NNN>.png
workspace/figures/<NNN>/figure_<NNN>.source_crop.png
catalog.json
index.html
docs/project/API551_STAGE4_HANDOFF_CURRENT.json
.github/workflows/structure-check.yml, if accepted stats are hard-coded there
```

If entrypoint, source-gate, tooling, or workflow changed, also update:

```text
README.md
docs/API551_PROJECT_QUICK_START_CURRENT.md
docs/project/API551_NEW_CHAT_START_RU.md
```

## accept-figure command

For a Figure candidate already approved by the user, use the repo-local acceptance command instead of one-off scripts:

```powershell
.	oolspi551pi551.ps1 accept-figure -Figure NNN -PackageZip <path-to-review-zip>
```

The command performs package-check, installs `workspace/figures/NNN`, marks the Figure as accepted, updates `catalog.json`, `index.html`, `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`, bootstrap status markers, and the hard-coded accepted state in `.github/workflows/structure-check.yml`. It does not commit, push, merge, or delete branches.

