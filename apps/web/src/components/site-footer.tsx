import Link from "next/link";
import { getCalUrl } from "@/lib/cal";
import { site, type Locale } from "@/lib/site";

export function SiteFooter({
  lang,
  exitLabel,
  stackLabel,
}: {
  lang: Locale;
  exitLabel: string;
  stackLabel: string;
}) {
  const calUrl = getCalUrl() ?? site.social.cal;

  return (
    <footer className="border-t border-[var(--line)] px-4 py-8 sm:px-6 sm:py-10">
      <div className="mx-auto flex max-w-5xl flex-col gap-4 font-mono text-xs sm:flex-row sm:items-center sm:justify-between sm:gap-6 sm:text-sm">
        <p className="min-w-0 break-words text-[var(--accent)]">
          <span className="text-[var(--muted)]">{exitLabel}</span>0
          <span className="text-[var(--muted)]"> · </span>
          {site.name}
        </p>
        <p className="text-[var(--muted)]">
          © {new Date().getFullYear()} · {stackLabel}
        </p>
        <div className="flex flex-wrap gap-4 text-[var(--muted)] sm:gap-5">
          <Link
            href={site.social.github}
            className="transition-colors hover:text-[var(--accent)]"
            target="_blank"
            rel="noopener noreferrer"
          >
            github
          </Link>
          <Link
            href={site.social.website}
            className="transition-colors hover:text-[var(--accent)]"
            target="_blank"
            rel="noopener noreferrer"
          >
            website
          </Link>
          <Link
            href={calUrl}
            className="transition-colors hover:text-[var(--accent)]"
            target="_blank"
            rel="noopener noreferrer"
          >
            schedule
          </Link>
          <Link
            href={`/${lang}/contact`}
            className="transition-colors hover:text-[var(--accent)]"
          >
            contact
          </Link>
        </div>
      </div>
    </footer>
  );
}
