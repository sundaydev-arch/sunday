import { Link } from "@tanstack/react-router";
import { getCalUrl } from "@/lib/cal";
import { useLocale } from "@/lib/locale";
import { openExternal } from "@/lib/open-url";
import { site } from "@/lib/site";

export function SiteFooter() {
  const { dict } = useLocale();
  const calUrl = getCalUrl();

  return (
    <footer className="border-t border-(--line) px-4 py-8 sm:px-6 sm:py-10">
      <div className="mx-auto flex max-w-5xl flex-col gap-4 font-mono text-xs sm:flex-row sm:items-center sm:justify-between sm:gap-6 sm:text-sm">
        <p className="min-w-0 break-words text-(--accent)">
          <span className="text-(--muted)">{dict.footer.exit}</span>0
          <span className="text-(--muted)"> · </span>
          {site.name}
        </p>
        <p className="text-(--muted)">
          © {new Date().getFullYear()} · {dict.footer.stack}
        </p>
        <div className="flex flex-wrap gap-4 text-(--muted) sm:gap-5">
          <button
            type="button"
            className="transition-colors hover:text-(--accent)"
            onClick={() => void openExternal(site.social.github)}
          >
            github
          </button>
          <button
            type="button"
            className="transition-colors hover:text-(--accent)"
            onClick={() => void openExternal(site.social.website)}
          >
            website
          </button>
          <button
            type="button"
            className="transition-colors hover:text-(--accent)"
            onClick={() => void openExternal(calUrl)}
          >
            schedule
          </button>
          <Link
            to="/contact"
            className="transition-colors hover:text-(--accent)"
          >
            contact
          </Link>
        </div>
      </div>
    </footer>
  );
}
