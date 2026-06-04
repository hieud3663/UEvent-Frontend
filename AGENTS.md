<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **UEvent-Frontend** (2093 symbols, 4250 relationships, 158 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/UEvent-Frontend/context` | Codebase overview, check index freshness |
| `gitnexus://repo/UEvent-Frontend/clusters` | All functional areas |
| `gitnexus://repo/UEvent-Frontend/processes` | All execution flows |
| `gitnexus://repo/UEvent-Frontend/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->

## Mobile Shared Widget Rules

- Before editing any file under `mobile/lib/features`, run this Flutter refactor gate:
  1. Check whether the UI role already exists in `mobile/lib/core/widgets`.
  2. Use the core/shared widget directly when it fits the behavior.
  3. Put screens/pages in `views/`; put reusable feature UI in `widgets/`.
  4. Do not keep a page-local wrapper around a core widget unless the final response explains why the core widget cannot be used directly.
  5. Before the final response, report whether shared widgets were reused and whether any local wrapper was intentionally kept.
- Before implementing or modifying any Flutter page, screen, feature widget, or dialog under `mobile/lib/features`, audit the existing controls in that file for direct uses of `ElevatedButton`, `OutlinedButton`, `TextButton`, `IconButton`, `GestureDetector`, `InkWell`, and locally declared private button widgets such as `_PrimaryActionButton`, `_SecondaryActionButton`, or `_CircleIconButton`.
- Prefer shared widgets from `mobile/lib/core/widgets` for app-standard controls: `PrimaryButton`, `SecondaryButton`, `GlassTopBar`, `GlassBottomNavBar`, `GlassSearchBar`, `GlassFilterChip`, `SegmentedToggle`, `GlassCheckboxTile`, `GlassRadioCard`, `GlassDropdownField`, `GlassActionTile`, `GlassInputField`, `GlassContainer`, and `SectionHeader`.
- Prefer Flutter's built-in controls and APIs for standard behavior before adding custom state or controller logic. Examples: use `TextInputFormatter`, `Form`/validators, `ValueListenableBuilder`, `ListView`, `Animated*` widgets, and platform plugins' documented setup when they already solve the problem.
- Do not over-engineer simple Flutter interactions. If a basic Flutter API can express the behavior clearly, use it instead of manual controller mutation, custom timers, duplicated validation pipelines, or page-local abstractions.
- If a page needs a control style that is not covered by the shared core widgets, extend or add a reusable widget in `mobile/lib/core/widgets` first, keeping the current visual design unchanged, then replace the page-local implementation with that shared widget.
- Do not add new page-local custom buttons or tappable controls when an equivalent shared widget exists. Page-local `GestureDetector`/`InkWell` controls are acceptable only for layout-specific interactions that are not reusable app controls.
- When touching an existing page that already has page-local custom buttons or duplicated control styling, include migration to the closest shared widget in the same change unless it would materially expand the task scope; if deferred, call it out explicitly.
- After refactoring shared widget usage, run `rg` on the touched files to confirm no avoidable page-local button/control implementations remain, then run the relevant Flutter analyze command.

## Final Response Gate For Flutter Feature Changes

- Before sending the final response after editing any file under `mobile/lib/features`, include a short `Gate check` section.
- The `Gate check` section must report:
  1. Core widgets: list the shared/core widgets reused, or state `none`.
  2. Local wrappers: list any local wrapper kept around a core widget, or state `none`.
  3. Feature structure: confirm pages are in `views/` and reusable feature UI is in `widgets/`.
  4. Control audit: confirm `rg` was run for avoidable local controls such as `ElevatedButton`, `TextButton`, `GestureDetector`, and local custom buttons.
  5. Verification: list `flutter analyze` and relevant tests, or explicitly state why they were not run.
- Do not send the final response for Flutter feature changes without this `Gate check` section.
- If any item cannot be satisfied, the final response must say why.
