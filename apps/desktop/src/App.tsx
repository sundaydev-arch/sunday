import { RouterProvider } from "@tanstack/react-router";
import { AppErrorBoundary } from "@/components/app-error-boundary";
import { LocaleProvider } from "@/lib/locale";
import { router } from "@/router";

export function App() {
  return (
    <AppErrorBoundary>
      <LocaleProvider>
        <RouterProvider router={router} />
      </LocaleProvider>
    </AppErrorBoundary>
  );
}
