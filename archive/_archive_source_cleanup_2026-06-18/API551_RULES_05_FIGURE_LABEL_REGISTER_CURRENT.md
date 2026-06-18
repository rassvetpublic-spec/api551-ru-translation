# API 551 — правила реестра надписей на рисунках v4

Дата версии: 2026-06-16

## 1. Назначение

Реестр надписей управляет тем:

- какие английские надписи переводятся;
- какой перевод approved;
- что наносится на сам рисунок;
- что реконструируется как текст/таблица;
- что защищается и не меняется;
- что требует ручного контроля.

Главный approved master-реестр: `api551_approved_label_master_v1.csv`, если не заменён более новым approved-файлом.

## 2. Статусы

Обязательные статусы:

- `approved_on_image` — перевод наносится на сам рисунок;
- `approved_text_reconstruction` — перевод/блок реконструируется как текст или таблица;
- `do_not_change` — не менять;
- `protected` — защищённая зона;
- `manual_control` — требуется ручная проверка;
- `rejected` — отклонено;
- `superseded` — заменено более новой записью.

## 3. Что идёт на сам рисунок

На сам рисунок идёт только запись со статусом `approved_on_image`.

Условия:

- есть original label;
- есть approved Russian translation;
- есть bbox или способ получить bbox;
- зона не protected;
- зона не do-not-change;
- перевод технически помещается;
- стиль соответствует правилам надписей;
- замена не разрушает графику.

## 4. Что реконструируется текстом/таблицей

В текст/таблицу идёт запись со статусом `approved_text_reconstruction`.

Типовые случаи:

- длинные абзацы;
- NOTE-блоки;
- таблицы внутри рисунка;
- пояснительные панели;
- многострочные блоки, которые лучше читать как текст;
- блоки, которые нельзя безопасно заменить внутри PNG/PDF-asset.

Если текст перенесён в HTML/PDF-реконструкцию, его не заменять внутри PNG.

## 5. Что не переводится

Не включать в кандидаты:

- одиночные буквы;
- одиночные цифры;
- размеры;
- диаметры;
- углы;
- значения с единицами;
- `Section A-A` и аналогичные сечения;
- цифры на осях;
- кандидаты со шрифтом меньше 5 pt;
- `(Note X)`;
- `MIN`;
- `MAX`;
- `TYP`;
- `NPS`;
- `NPT`;
- химические формулы;
- зоны `protected_collision_zone`.

`Flange` и подобные термины не переводить, если они являются частью стандартного обозначения или protected-зоны. Если это обычная смысловая надпись, решение должно быть в approved-реестре.

## 6. Обязательные поля CSV

Минимальные поля CSV:

- `figure_id`
- `figure_title_original`
- `figure_title_ru`
- `source_pdf_page`
- `source_printed_page`
- `section`
- `asset_id`
- `asset_path`
- `label_id`
- `original_text`
- `ru_text`
- `label_role`
- `placement_decision`
- `status`
- `bbox_pdf_points`
- `bbox_crop_pixels`
- `bbox_source`
- `text_mask_id`
- `protected_mask_id`
- `protected_zone_ids`
- `do_not_change_reason`
- `manual_control_reason`
- `font_min_pt`
- `font_final_pt`
- `linewrap_rule`
- `qa_status`
- `qa_notes`
- `approved_by`
- `approved_date`

## 7. Обязательная структура JSON

JSON должен хранить:

- `document_id`
- `source_pdf`
- `register_version`
- `figures[]`

Каждый объект `figures[]` должен хранить:

- `figure_id`
- `title_original`
- `title_ru`
- `source_pdf_page`
- `source_printed_page`
- `section`
- `first_mention_locations[]`
- `asset`
- `components[]`
- `labels[]`
- `notes[]`
- `tables[]`
- `protected_zones[]`
- `status`

Каждый объект `labels[]` должен хранить:

- `label_id`
- `original_text`
- `ru_text`
- `role`
- `placement_decision`
- `status`
- `bbox_pdf_points`
- `bbox_crop_pixels`
- `bbox_source`
- `text_mask`
- `protected_mask`
- `font_rule`
- `linewrap_rule`
- `qa`
- `approval`

## 8. Placement decision

Поле `placement_decision` принимает значения:

- `on_image`
- `text_reconstruction`
- `table_reconstruction`
- `caption_only`
- `note_block`
- `protected_no_change`
- `manual_control`

## 9. QA

Перед approved-статусом проверить:

- bbox построен по буквам;
- protected graphics не затронута;
- cleaned-only удаляет исходный текст полностью;
- anti-alias outline удалён;
- перевод читаем;
- шрифт не меньше 8 pt;
- шрифты в одном рисунке не отличаются более чем на 2 pt без причины;
- итоговый рисунок не разрушает технический смысл;
- текстовые реконструкции не дублируются на рисунке.

## 10. Запреты

Запрещено:

- использовать старые bbox напрямую;
- менять запись без обновления статуса;
- наносить на рисунок записи `manual_control`;
- наносить на рисунок записи `approved_text_reconstruction`;
- удалять NOTE из рисунка без сохранения утверждённого NOTE-блока;
- смешивать служебный реестр с чистовым HTML/PDF.
