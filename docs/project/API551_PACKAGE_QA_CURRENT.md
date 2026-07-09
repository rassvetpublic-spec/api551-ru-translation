# API551 Package QA Current

Status: CURRENT package validation workflow for Stage 4 Figure packages.

## 1. Default command

```powershell
.\tools\api551\api551.ps1 package-check -PackageZip C:\GIT\package.zip -Figure 003
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

Use the clean repo for versioned text and PR work. Use `C:\GIT\API551_HYDRATED_VIEW` for visual hydrated review when real PNG/PDF/ZIP assets are needed locally.
