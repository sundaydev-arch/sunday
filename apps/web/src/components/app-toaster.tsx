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
            "font-mono !rounded-none !border !border-[var(--line)] !bg-[var(--panel)] !text-[var(--ink)] !shadow-none",
          title: "!text-[var(--ink)]",
          description: "!text-[var(--muted)]",
          success: "!border-[var(--accent)]",
          error: "!border-[#ff6b6b]",
          closeButton:
            "!border-[var(--line)] !bg-[var(--field)] !text-[var(--muted)]",
        },
      }}
    />
  );
}
