# API551 Package QA Current

Status: CURRENT validation record for completed Stage 4 Figure packages. Use only for audit or an explicitly reopened Figure.

## 1. Default command

```powershell
.\tools\api551\api551.ps1 package-check -PackageZip C:\Irvis-UPG\GIT\package.zip -Figure 003
```

## 2. Package shape

A Figure package must contain one root folder:

```text
NNN/
```

Required files for an included Figure:

```text
NNN/figure_NNN.object.html
NNN/figure_NNN.object.json
NNN/figure_NNN.out.html
NNN/figure_NNN.png
NNN/figure_NNN.source_crop.png
```

Additional intermediate/source panel PNGs may exist when required by the Figure object strategy.

## 3. Blocking package errors

Reject the package if:

- ZIP integrity fails;
- PDF is included;
- required files are missing;
- PNG files in the ZIP are Git LFS pointers instead of real PNGs;
- HTML contains broken `<img src>` references;
- object/out JSON/HTML contains local user paths such as `C:/Users/`;
- accepted object contains `review_only_not_accepted`;
- `out.html` contains service markers;
- package status contradicts current catalog/handoff state;
- package introduces unapproved stray files as production inputs.

## 4. Installation boundary

`install-package` may unpack to `workspace/figures/<NNN>`. It must not commit, push, merge, delete branches, or change `main`.

## 5. Visual review boundary

Use GitHub for versioned truth. The current hydrated snapshot is `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT`; it is not a Git worktree and must not be used for commit/push.

## accept-figure command

For a Figure candidate already approved by the user, use the repo-local acceptance command instead of one-off scripts:

```powershell
.\tools\api551\api551.ps1 accept-figure -Figure NNN -PackageZip <path-to-review-zip>
```

The command performs package-check, installs `workspace/figures/NNN`, marks the Figure as accepted, updates `catalog.json`, `index.html`, `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`, bootstrap status markers, and the hard-coded accepted state in `.github/workflows/structure-check.yml`. It does not commit, push, merge, or delete branches.

