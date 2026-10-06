/**
 * Bind the edit→duplicate remount at the production dialog hosts.
 *
 * `personaDialogRemountKey` is not enough: removing `key` from AgentsView or
 * UserProfilePersonaDialogs would leave helper-only tests green while a
 * still-mounted edit form can keep `id` and rename the original on Duplicate.
 */
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

import React, { act } from "react";
import { createRoot } from "react-dom/client";

import { AgentDialog } from "./AgentDialog.tsx";
import {
  duplicatePersonaDialogState,
  editPersonaDialogState,
} from "./personaDialogState.ts";
import { UserProfilePersonaDialogs } from "../../profile/ui/UserProfilePersonaDialogs.tsx";

const PERSONA = {
  id: "persona-1",
  displayName: "Solo",
  avatarUrl: "avatar://solo",
  description: "Reviews desktop changes.",
  systemPrompt: "Be direct.",
  acpCommand: "buzz-acp",
  runtime: "provider-a",
  model: "model-a",
  provider: null,
  isBuiltIn: false,
  isActive: true,
  createdAt: "2025-01-01T00:00:00Z",
  updatedAt: "2025-01-02T00:00:00Z",
};

function hostProps(personaDialogState, onSubmit) {
  return {
    cardMintTarget: null,
    createError: null,
    instanceCount: 0,
    isPending: false,
    linkedAgentPubkey: null,
    personaDialogState,
    personaToDelete: null,
    personaToExportSnapshot: null,
    resolvedPersona: undefined,
    runtimes: [],
    runtimesLoading: false,
    updateError: null,
    onCloseCardMint() {},
    onCloseDelete() {},
    onCloseDialog() {},
    onCloseExportSnapshot() {},
    onConfirmDelete() {},
    onExportSnapshot() {},
    onSubmit,
  };
}

function findAgentDialog(node) {
  if (!node || typeof node !== "object") return null;
  if (node.type === AgentDialog) return node;
  const { children } = node.props ?? {};
  if (Array.isArray(children)) {
    for (const child of children) {
      const found = findAgentDialog(child);
      if (found) return found;
    }
    return null;
  }
  return findAgentDialog(children);
}

/**
 * First-mount capture of `initialValues`. This is the failure mode the
 * production `key` exists to prevent: an edit form that stays mounted when
 * Duplicate opens will submit the original `id`.
 */
function CapturingDialog(props) {
  const [captured] = React.useState(props.initialValues);
  return React.createElement("button", {
    "data-testid": "persona-dialog-submit",
    onClick: () => {
      void props.onSubmit(captured);
    },
    type: "button",
  });
}

function capturingHost(dialogElement) {
  return React.createElement(
    "div",
    null,
    React.createElement(CapturingDialog, {
      ...dialogElement.props,
      key: dialogElement.key,
    }),
  );
}

function assertHostPassesRemountKey(sourcePath, label) {
  const source = fs.readFileSync(sourcePath, "utf8");
  assert.ok(
    /<AgentDialog\s+key=\{personaDialogRemountKey\(/.test(source),
    `${label} must pass personaDialogRemountKey as AgentDialog's key`,
  );
}

test("AgentsView and UserProfilePersonaDialogs remount AgentDialog via the production key", () => {
  const here = path.dirname(fileURLToPath(import.meta.url));
  assertHostPassesRemountKey(path.join(here, "AgentsView.tsx"), "AgentsView");
  assertHostPassesRemountKey(
    path.join(here, "../../profile/ui/UserProfilePersonaDialogs.tsx"),
    "UserProfilePersonaDialogs",
  );
});

test("edit-to-duplicate on the persistent host submits a create payload without id", async () => {
  const submitted = [];
  const onSubmit = async (input) => {
    submitted.push(input);
  };

  const editDialog = findAgentDialog(
    UserProfilePersonaDialogs(
      hostProps(editPersonaDialogState(PERSONA), onSubmit),
    ),
  );
  const duplicateDialog = findAgentDialog(
    UserProfilePersonaDialogs(
      hostProps(duplicatePersonaDialogState(PERSONA), onSubmit),
    ),
  );

  assert.ok(editDialog, "persistent host must render AgentDialog");
  assert.ok(duplicateDialog, "persistent host must render AgentDialog");
  assert.equal(editDialog.key, "edit:persona-1");
  assert.equal(duplicateDialog.key, "create");
  assert.notEqual(
    editDialog.key,
    duplicateDialog.key,
    "Edit and Duplicate must not share a remount key",
  );

  const container = document.createElement("div");
  document.body.append(container);
  const root = createRoot(container);
  try {
    await act(async () => {
      root.render(capturingHost(editDialog));
    });
    await act(async () => {
      root.render(capturingHost(duplicateDialog));
    });
    await act(async () => {
      container.querySelector("[data-testid='persona-dialog-submit']").click();
    });
  } finally {
    await act(async () => root.unmount());
    container.remove();
  }

  assert.equal(submitted.length, 1);
  assert.equal(
    "id" in submitted[0],
    false,
    "Duplicate must not submit the original persona id",
  );
  assert.equal(submitted[0].displayName, "Solo copy");
});
