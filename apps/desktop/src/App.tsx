import { RouterProvider } from "@tanstack/react-router";
import { LocaleProvider } from "@/lib/locale";
import { router } from "@/router";

export function App() {
  return (
    <LocaleProvider>
      <RouterProvider router={router} />
    </LocaleProvider>
  );
}
