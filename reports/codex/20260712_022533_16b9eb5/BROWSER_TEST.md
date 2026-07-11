# Visual inspection path

Direct view_image failed before file access in both the repository and the writable visualization root:

windows sandbox failed: helper_unknown_error: setup refresh had errors

The Windows screenshot connection failed at the same helper initialization stage. This identifies the previous error as a Codex Windows sandbox-helper setup failure, independent of PNG/PDF validity and path.

A working inspection path was restored for this run:

1. render locally with pypdfium2/Pillow;
2. validate format, dimensions, and SHA-256;
3. read bounded preview bytes with PowerShell;
4. pass the bytes in memory for image inspection.

This path visually opened the synthetic PNG probe, real PDF page 43, Figure 10 source crop, cleaned-only stage, final full layout, left/right detail views, and the fresh-extracted ZIP image. Result: PASS.
