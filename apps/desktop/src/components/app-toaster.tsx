import { Toaster } from "sonner";

export function AppToaster() {
  return (
    <Toaster
      theme="dark"
      position="bottom-right"
      toastOptions={{
        classNames: {
          toast:
            "font-mono border border-[var(--line)] bg-[var(--panel)] text-[var(--ink)]",
          description: "text-[var(--muted)]",
        },
      }}
    />
  );
}
