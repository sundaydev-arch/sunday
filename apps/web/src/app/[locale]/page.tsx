import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { getDictionary, getProjectsFromDict } from "./dictionaries";
import { buildPageMetadata } from "@/lib/seo";
import { isLocale, site } from "@/lib/site";

export async function generateMetadata({
  params,
}: PageProps<"/[locale]">): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) return {};
  const dict = await getDictionary(locale);
  return buildPageMetadata({
    lang: locale,
    path: "/",
    title: dict.meta.pages.home.title,
    description: dict.meta.pages.home.description,
    absoluteTitle: true,
  });
}

export default async function HomePage({ params }: PageProps<"/[locale]">) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();

  const dict = await getDictionary(locale);
  const projects = getProjectsFromDict(dict)
    .filter((p) => p.featured)
    .slice(0, 3);

  return (
    <>
      <section className="geek-shell relative min-h-[100svh] overflow-x-clip px-4 pt-32 pb-14 sm:px-6 sm:pt-32 sm:pb-16">
        <div aria-hidden className="scan-line" />

        <div className="relative mx-auto flex min-h-[calc(100svh-8.5rem)] max-w-5xl flex-col justify-end gap-6 pb-6 sm:min-h-[calc(100svh-9rem)] sm:gap-8 sm:pb-8">
          <p
            className="animate-rise font-mono text-xs break-all text-[var(--muted)] sm:text-sm sm:break-normal"
            style={{ animationDelay: "40ms" }}
          >
            <span className="text-[var(--accent)]">guest@{site.handle}</span>
            <span className="text-[var(--muted)]">:</span>
            <span className="text-[var(--ink)]">~</span>
            <span className="text-[var(--muted)]">$ {dict.home.whoami}</span>
          </p>

          <p className="animate-rise cursor-blink font-display text-4xl font-semibold tracking-tight text-[var(--ink)] sm:text-7xl md:text-8xl">
            {site.name}
          </p>

          <div
            className="animate-rise max-w-xl"
            style={{ animationDelay: "120ms" }}
          >
            <h1 className="font-mono text-sm leading-relaxed break-words text-[var(--accent)] sm:text-base md:text-lg">
              {"// "}
              {dict.home.title}
            </h1>
            <p className="mt-4 max-w-lg font-mono text-sm leading-relaxed break-words text-[var(--muted)] sm:text-base">
              {dict.home.blurb}
            </p>
          </div>

          <div
            className="animate-rise flex flex-wrap gap-3"
            style={{ animationDelay: "220ms" }}
          >
            <Link
              href={`/${locale}/projects`}
              className="rounded-full bg-[var(--accent)] px-5 py-3 font-mono text-sm font-medium text-[var(--accent-ink)] transition hover:bg-[var(--accent-deep)] hover:text-white sm:px-6"
            >
              {dict.home.ctaProjects}
            </Link>
            <Link
              href={`/${locale}/contact`}
              className="rounded-full border border-[var(--line)] bg-[var(--accent-dim)] px-5 py-3 font-mono text-sm font-medium text-[var(--ink)] transition hover:border-[var(--accent)] hover:text-[var(--accent)] sm:px-6"
            >
              {dict.home.ctaContact}
            </Link>
          </div>
        </div>
      </section>

      <section className="border-t border-[var(--line)] px-4 py-16 sm:px-6 sm:py-20 md:py-28">
        <div className="mx-auto max-w-5xl">
          <p className="font-mono text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
            {dict.home.selectedLabel}
          </p>
          <h2 className="font-display mt-3 text-2xl font-semibold tracking-tight break-words text-[var(--ink)] sm:text-3xl md:text-4xl">
            {dict.home.selectedTitle}
          </h2>
          <ul className="mt-10 space-y-0 sm:mt-12">
            {projects.map((project) => (
              <li
                key={project.id}
                className="border-t border-[var(--line)] py-6 transition hover:bg-[var(--accent-dim)] sm:py-8"
              >
                <div className="flex min-w-0 flex-col gap-2 sm:flex-row sm:items-baseline sm:justify-between">
                  <h3 className="font-display min-w-0 text-xl font-medium break-words text-[var(--ink)] sm:text-2xl">
                    <span className="mr-2 text-[var(--accent)]">›</span>
                    {project.title}
                  </h3>
                  <span className="shrink-0 font-mono text-xs text-[var(--muted)]">
                    {project.year}
                  </span>
                </div>
                <p className="mt-2 font-mono text-sm break-words text-[var(--accent)]">
                  {project.role}
                </p>
                <p className="mt-3 max-w-2xl font-mono text-sm leading-relaxed break-words text-[var(--muted)]">
                  {project.summary}
                </p>
              </li>
            ))}
          </ul>
          <Link
            href={`/${locale}/projects`}
            className="mt-8 inline-flex font-mono text-sm text-[var(--accent)] transition hover:text-[var(--ink)] sm:mt-10"
          >
            {dict.home.selectedCta}
          </Link>
        </div>
      </section>
    </>
  );
}
