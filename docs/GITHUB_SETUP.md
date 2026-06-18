# GitHub setup

## Current blocker

The available GitHub connector can work with existing repositories but does not expose repository creation. Create an empty repository manually on GitHub, then provide its `owner/repo` name.

Recommended name: `api551-ru-translation`.
Recommended visibility: private, because the project contains working translation materials and API PDF/source artifacts.

## After repository exists

1. Confirm repository full name, for example `rassvetpublic-spec/api551-ru-translation`.
2. Initialize local Git root from this structure.
3. Add Google Drive `API 551/Source` active files into `source/`.
4. Add current `index.html`, `catalog.json`, `figures/` into `workspace/` or repository root according to final chosen layout.
5. Commit with message `Initialize API 551 translation project structure`.
