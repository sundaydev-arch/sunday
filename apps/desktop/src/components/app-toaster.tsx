import { Toaster } from "sonner";

export function AppToaster() {
  return (
    <Toaster
      theme="dark"
      position="bottom-right"
      toastOptions={{
        classNames: {
          toast: "font-mono border border-(--line) bg-(--panel) text-(--ink)",
          description: "text-(--muted)",
        },
      }}
    />
  );
}
