import { useRouterState } from "@tanstack/react-router";
import { getCalUrl } from "@/lib/cal";
import { openExternal } from "@/lib/open-url";
import { site } from "@/lib/site";

const actions = [
  {
    id: "github",
    label: "Open GitHub",
    short: "gh",
    href: () => site.social.github,
  },
  {
    id: "website",
    label: "Open website",
    short: "web",
    href: () => site.social.website,
  },
  {
    id: "schedule",
    label: "Open schedule",
    short: "cal",
    href: () => getCalUrl(),
  },
] as const;

/** Overlay title bar — drag region + quick external actions (desktop only). */
export function TitleBar() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const pathLabel = pathname === "/" ? "~" : `~${pathname}`;

  return (
    <div
      data-tauri-drag-region
      className="fixed inset-x-0 top-0 z-[60] flex h-11 items-center gap-2 border-b border-(--line)/70 bg-(--shell-top)/92 pr-2 pl-[78px] backdrop-blur-md"
    >
      <p
        data-tauri-drag-region
        className="min-w-0 flex-1 truncate font-mono text-xs tracking-tight text-(--muted)"
        title={pathLabel}
      >
        <span className="text-(--accent)">{site.handle}</span>
        <span className="text-(--muted)/70"> · </span>
        {pathLabel}
      </p>

      <div className="flex shrink-0 items-center gap-1">
        {actions.map((action) => (
          <button
            key={action.id}
            type="button"
            title={action.label}
            aria-label={action.label}
            className="rounded-md px-2 py-1 font-mono text-[11px] tracking-wide text-(--muted) uppercase transition hover:bg-(--accent-dim) hover:text-(--accent)"
            onClick={() => void openExternal(action.href())}
          >
            {action.short}
          </button>
        ))}
      </div>
    </div>
  );
}
