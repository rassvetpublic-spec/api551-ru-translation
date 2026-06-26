# GITHUB_SKILL_HANDOFF.md

Использовать для GitHub-задач:

1. Source-gate:
   - repo;
   - default branch;
   - права;
   - текущие файлы;
   - CI/workflows;
   - source-of-truth.

2. Безопасная правка:
   - ветка от default branch;
   - минимальный patch;
   - проверка branch;
   - PR;
   - merge только после checks.

3. Если файл большой и fetch усечён:
   - не делать update_file полным содержимым;
   - использовать локальный patch или временный workflow в отдельной branch;
   - проверить, что временный workflow удалён.

4. Отчёт:
   - repo;
   - branch;
   - PR;
   - изменённые файлы;
   - что проверено;
   - что осталось.

---
