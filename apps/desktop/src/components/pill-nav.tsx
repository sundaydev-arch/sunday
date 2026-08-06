import { Link, useRouterState } from "@tanstack/react-router";
import { useLocale } from "@/lib/locale";
import { locales, site, type Locale } from "@/lib/site";

export function PillNav() {
  const { locale, dict, setLocale } = useLocale();
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  const items = [
    { to: "/", label: dict.nav.home, match: "/" },
    { to: "/about", label: dict.nav.about, match: "/about" },
    { to: "/projects", label: dict.nav.projects, match: "/projects" },
    { to: "/contact", label: dict.nav.contact, match: "/contact" },
  ] as const;

  return (
    <header className="pointer-events-none fixed inset-x-0 top-0 z-50 px-3 pt-3 sm:px-4 sm:pt-6">
      <nav
        aria-label="Primary"
        className="animate-nav-in pointer-events-auto mx-auto flex w-full max-w-5xl flex-col gap-2 sm:flex-row sm:flex-wrap sm:items-center sm:justify-center sm:gap-3"
      >
        <div className="flex items-center justify-between gap-3 sm:contents">
          <Link
            to="/"
            className="shrink-0 font-mono text-sm font-medium tracking-tight text-(--accent) transition hover:text-(--ink) sm:text-base"
          >
            <span className="text-(--muted)">~/</span>
            {site.handle}
          </Link>

          <div className="flex shrink-0 items-center gap-1 rounded-full border border-(--line) bg-(--nav-track)/90 px-1.5 py-1 font-mono text-xs backdrop-blur-md sm:order-last">
            {locales.map((code) => (
              <button
                key={code}
                type="button"
                onClick={() => setLocale(code as Locale)}
                className={[
                  "rounded-full px-2 py-1 uppercase transition",
                  code === locale
                    ? "bg-(--accent-dim) text-(--accent)"
                    : "text-(--muted) hover:text-(--ink)",
                ].join(" ")}
                lang={code}
              >
                {code}
              </button>
            ))}
          </div>
        </div>

        <div className="w-full min-w-0 sm:w-auto sm:max-w-none">
          <div className="nav-scroll flex items-center rounded-full border border-(--line) bg-(--nav-track)/90 p-1 backdrop-blur-md">
            {items.map((item) => {
              const active =
                item.match === "/"
                  ? pathname === "/"
                  : pathname.startsWith(item.match);

              return (
                <Link
                  key={item.to}
                  to={item.to}
                  className={[
                    "shrink-0 rounded-full px-3 py-2 text-xs font-medium transition-colors duration-200 sm:px-4 sm:text-sm",
                    active
                      ? "bg-(--accent) text-(--accent-ink)"
                      : "text-(--muted) hover:text-(--ink)",
                  ].join(" ")}
                >
                  {item.label}
                </Link>
              );
            })}
          </div>
        </div>
      </nav>
    </header>
  );
}
