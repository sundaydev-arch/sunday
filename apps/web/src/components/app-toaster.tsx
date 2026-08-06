"use client";

import { Toaster } from "sonner";

/** Terminal-themed toasts — Sonner only, no shadcn Input/Button skins. */
export function AppToaster() {
  return (
    <Toaster
      position="bottom-right"
      theme="dark"
      closeButton
      toastOptions={{
        classNames: {
          toast:
            "font-mono !rounded-none !border !border-(--line) !bg-(--panel) !text-(--ink) !shadow-none",
          title: "!text-(--ink)",
          description: "!text-(--muted)",
          success: "!border-(--accent)",
          error: "!border-danger",
          closeButton: "!border-(--line) !bg-(--field) !text-(--muted)",
        },
      }}
    />
  );
}
