# Spec: #7916 duplicating an agent must not mutate the original

Status: APPROVED (design review round 1)

## Problem

Duplicate Agent then Create can make the original definition disappear. Submit
treats `"id" in input` as update. If the definition dialog stays mounted from
an edit (same `open` tree) and keeps that `id`, save writes `"X copy"` onto
the source persona instead of creating a new one.

## Decision

`duplicatePersonaDialogState` remains a create payload: it must never include
`id`. Callers remount the dialog with `personaDialogRemountKey` (`edit:<id>`
vs `create`) so edit form state cannot leak onto Duplicate. Create still uses
the existing `definition_start` path.

## Non-goals

Changing create-then-start, catalog publish, or instance stop/start.

## Tests

- `"id" in duplicatePersonaDialogState(...).initialValues` is false even when
  the source persona has an id (removing the omit fails this test).
- `personaDialogRemountKey` is `create` for duplicate and `edit:<id>` for edit.
