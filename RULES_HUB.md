# RULES_HUB

Repo: rassvetpublic-spec/api551-ru-translation
Project: API 551 RU Translation

Hub repository:

rassvetpublic-spec/rassvet-rules-hub

<!-- RASSVET_RULES_HUB_LINK_BLOCK_START -->

## Используемые источники

1. Project Instructions текущего проекта.
2. ACTIVE/CURRENT файлы текущего проекта.
3. `rassvet-rules-hub/RULES_INDEX.md`.
4. `rassvet-rules-hub/core/SOURCE_OF_TRUTH.md`.
5. `rassvet-rules-hub/core/GLOBAL_RULES.md`.
6. `rassvet-rules-hub/core/FILE_WORKFLOW.md` для файловых задач.
7. `rassvet-rules-hub/github/GITHUB_WORKFLOW.md` для GitHub-задач.
8. `rassvet-rules-hub/prompts/PROMPT_LAB_RULES.md` для задач «улучши промпт».
9. `rassvet-rules-hub/prompts/HANDOFF_REPORT_TEMPLATE.md` для отчётов.
10. `rassvet-rules-hub/prompts/PROJECT_RULES_UPDATE_CHECKLIST.md` для подключения проекта к rules-hub.
11. `rassvet-rules-hub/skills/SKILLS_REGISTRY.md` для подключённых навыков.
12. `rassvet-rules-hub/skills/SKILL_COLLECTION_RULES.md` для сбора и регистрации новых навыков.
13. `rassvet-rules-hub/skills/SKILL_ADDER_WORKFLOW.md` для сценария `добавь навык:` из любого проекта.
14. `rassvet-rules-hub/skills/SKILL_COLLECTOR_FROM_CHAT_AND_PROJECT.md` для сценария `Собери навыки`.
15. `rassvet-rules-hub/skills/MENTAL_EXPERIMENT_ANALYSIS_SKILL.md` для сценария `мысленный эксперимент`.
16. `rassvet-rules-hub/skills/PROJECT_RULES_HUB_CONNECTION_SKILL.md` для сценариев `подключи rules hub`, `проверь подключение rules hub`.

## Trigger `добавь навык:`

Если пользователь в текущем проекте пишет `добавь навык:`, проверить, является ли это локальным правилом проекта или общим reusable skill для `rassvet-rules-hub`.

Если это общий skill, применять:

`rassvet-rules-hub/skills/SKILL_ADDER_WORKFLOW.md`

Изменения в `rassvet-rules-hub` делать через отдельную ветку и PR. Merge — только по явной команде пользователя.

## Trigger `Собери навыки`

Если пользователь пишет `Собери навыки`, применять:

`rassvet-rules-hub/skills/SKILL_COLLECTOR_FROM_CHAT_AND_PROJECT.md`

## Trigger `мысленный эксперимент`

Если пользователь пишет `мысленный эксперимент`, применять:

`rassvet-rules-hub/skills/MENTAL_EXPERIMENT_ANALYSIS_SKILL.md`

## Trigger `подключи rules hub`

Если пользователь пишет `подключи rules hub`, `проверь подключение rules hub`, `почини подключение rules hub`, `обнови подключение rules hub` или `переподключи rules hub`, применять:

`rassvet-rules-hub/skills/PROJECT_RULES_HUB_CONNECTION_SKILL.md`

Если корректного блока подключения в Project Instructions нет, этот же skill должен сгенерировать bootstrap-блок для вставки в Project Instructions.

## Приоритет

Project Instructions проекта → ACTIVE/CURRENT проекта → active rules-hub files → текущий чат → память/старые чаты → archive только как справка.

## Если есть проблема с источниками

Указать источник, роль, проблему, риск и безопасный следующий шаг.

<!-- RASSVET_RULES_HUB_LINK_BLOCK_END -->

## Local priority

Local Project Instructions, ACTIVE/CURRENT files, and API551 CURRENT policy/rules remain project-specific sources for this repo.

## Local workflow addenda

- `docs/rules/GITHUB_PROJECT_PIPELINE_CURRENT_2026-06-26.md` - local GitHub workflow addendum for connector use, local `.ps1` fallback, PR/merge checks, branch cleanup, and reporting. If a more specific CURRENT project workflow file conflicts with this addendum, the more specific file controls.
- `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md` - mandatory workflow rule for user-accepted Figure objects, merge into `candidates`, promotion into `main`, and cleanup of temporary branches.
