# Spec: #8101 heal re-adds a slug repo after CLI remove-repo

Status: APPROVED (design review round 1)

## Problem

`projects remove-repo` drops the slug-identity repository from the signed
kind:30621 `a` tags. Desktop absorb still folds that owner+dtag repo onto the
project card, and `homeRepositoriesToBind` treats it as pending. Heal then
republishes `projects add-repo`, undoing the explicit remove.

## Decision

Keep absorb (the card can still show the standalone repo). Do not bind
owner+dtag slug-identity repositories that are absent from the signed `a`
set. Channel-authorized repos with a different dtag still heal. Re-adding
the slug repo stays an explicit `add-repo`.

## Non-goals

Changing CLI `remove-repo`, signed event shape, or absorb/display grouping.

## Tests

- Owner+dtag slug repo missing from signed addresses is not pending bind.
- Authorized home-channel repo with a different owner still pending-binds.
- Signed slug repo stays ignored (already on the `a` set).
