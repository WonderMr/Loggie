# Loggie

Loggie is a 1C:Enterprise 8.3 configuration extension (`ЛоггированиеИзмененийДанных`, object prefix `ЛогИ_`) that records detailed data changes in the 1C event log (журнал регистрации): for every write of a constant, catalog item, document, chart of calculation types item, or information/accumulation register record set it logs the before and after values of changed attributes and tabular-section rows. It is for 1C administrators and developers who need to find out quickly who changed what. The project is actively maintained (last commit 2026-10-12).

## Layout

- `src/cfe/ЛоггированиеИзмененийДанных/` - extension source as a Designer dump to XML/BSL files (hierarchical format, `ConfigDumpInfo.xml` version 2.20). This is the source of truth.
  - `Configuration.xml` - extension properties: `NamePrefix` `ЛогИ_`, `ConfigurationExtensionPurpose` `Customization`, `ConfigurationExtensionCompatibilityMode` `Version8_3_11`, `<Version>`.
  - `CommonModules/ЛогИ_ОбщийМодуль/Ext/Module.bsl` - all server logic: BeforeWrite handlers, attribute and tabular-section diff (index-based row matching), event-log writing, the `ЭтоСлужебныйОбъект` exclusion list.
  - `CommonModules/ЛогИ_ОбщийМодульКлиент/Ext/Module.bsl` - `ОткрытьЖурналРегистрацииПоОбъекту`: opens the event log filtered by the current object.
  - `CommonModules/ПодключаемыеКомандыПереопределяемый/Ext/Module.bsl` - adopted БСП module; `&После` hooks add the "История изменений (журнал регистрации)" command to object forms.
  - `EventSubscriptions/*.xml` - six `BeforeWrite` subscriptions (documents, catalogs, constants, charts of calculation types, information and accumulation register record sets), each bound to a handler in `ЛогИ_ОбщийМодуль`.
  - `Languages/Русский.xml` - adopted language object.
- `ЛоггированиеИзмененийДанных.cfe` - built extension file for end users, rebuilt from `src/cfe` and committed.
- `README.md` - user documentation (Russian, with an English summary on top).

## Setup / Build / Run / Test

The repository has no build scripts, CI or automated tests. You need the 1C:Enterprise 8.3 platform with Designer (Конфигуратор) and a test infobase.

- Install (from README): download `ЛоггированиеИзмененийДанных.cfe`, add it to the infobase in Designer, and turn off safe mode for the extension.
- Use: nothing to configure. Filter the event log by the event `Лог. Изменение Данных` (register record sets are logged as `Лог. Изменение Регистров`), or run "История изменений (журнал регистрации)" from an object form.
- Rebuild the `.cfe` after changing `src/cfe`. Git history (commit `f21efef`) records a build with batch-mode Designer 8.5.1.1343 and a round-trip check: load the `.cfe` into an empty infobase, dump it to files, and compare the modules with `src`. The exact commands are not in the repo; with standard Designer batch flags it is roughly (unverified):

  ```bat
  1cv8 DESIGNER /F<infobase> /LoadConfigFromFiles src\cfe\ЛоггированиеИзмененийДанных -Extension ЛоггированиеИзмененийДанных
  1cv8 DESIGNER /F<infobase> /DumpCfg ЛоггированиеИзмененийДанных.cfe -Extension ЛоггированиеИзмененийДанных
  ```

- Test manually: in a test infobase change a document or catalog item (including tabular-section rows), then check the event log records.

## Conventions

- Code is 1C:Enterprise built-in language (BSL) with Russian keywords and identifiers. Assignments are column-aligned (`Имя    =   Значение;`) and `Если`/`Тогда` sit on separate lines; follow the surrounding style.
- New extension objects get the `ЛогИ_` prefix; adopted objects keep base-configuration names.
- On every code change bump `<Version>` in `Configuration.xml` (format `YYYY.MM.DD.HHMM`, for example `2026.10.12.1413`) and rebuild `ЛоггированиеИзмененийДанных.cfe`.
- Event names are a contract users filter by: `Лог. Изменение Данных` and `Лог. Изменение Регистров`. The client command filters by `Лог. Изменение Данных`.
- Default branch `main`; changes arrive as pull requests from topic branches.
- Commit messages are in Russian, imperative, with an explanatory body (for example `Ускорить логирование изменений табличных частей за счет индексирования`). README is in Russian.

## Gotchas and boundaries

- `ЛоггированиеИзмененийДанных.cfe` is binary; never edit it by hand. Keep it in sync with `src/cfe`.
- `ConfigDumpInfo.xml` and the object `uuid` values come from Designer; do not invent or change UUIDs by hand.
- The base configuration must be built on 1C:БСП (Standard Subsystems Library): the code uses `ПараметрыСеанса.ТекущийПользователь`, `ЖурналРегистрацииКлиент.ОткрытьЖурналРегистрации` and adopts `ПодключаемыеКомандыПереопределяемый`.
- Writes without a current user (`ЕстьПользователь()` returns false) are not logged. Objects listed in `ЭтоСлужебныйОбъект` (БСП service registers such as `РегистрСведений.ВерсииОбъектов`, time measurements, server notifications, extension version parameters, ЭСФ caches) are skipped; add new noisy service objects there.
- `ЛогИ_ОбщийМодуль` is compiled for Server, External connection and Ordinary client, without "Server call". Commit `0bfec0b` set these flags because thick-client and COM updaters crashed otherwise; keep them.
- Handlers run inside every write transaction. Errors are caught and written to the event log with level Error in an independent transaction (`ОбработатьОшибку`); logging must never set `Отказ` or re-raise.
- Tabular-section diff is performance-sensitive: rows are matched through an index (`ИндексСтрокТЧ`, `НайтиПозициюОдинаковойСтроки`, `НайтиПозициюПохожейСтроки`); avoid nested full scans.
- `ЛогИ_РегистрРасчетаНаборЗаписейПередЗаписью` exists in the module, but no subscription in `EventSubscriptions/` uses it.
- No `.cursor/rules` or Copilot instructions exist in this repo.
