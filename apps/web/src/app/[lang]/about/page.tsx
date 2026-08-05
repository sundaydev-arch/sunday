import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { isLocale, site } from "@/lib/site";
import { getDictionary } from "../dictionaries";

export async function generateMetadata({
  params,
}: PageProps<"/[lang]/about">): Promise<Metadata> {
  const { lang } = await params;
  if (!isLocale(lang)) return {};
  const dict = await getDictionary(lang);
  return { title: dict.nav.about };
}

export default async function AboutPage({
  params,
}: PageProps<"/[lang]/about">) {
  const { lang } = await params;
  if (!isLocale(lang)) notFound();
  const dict = await getDictionary(lang);

  return (
    <div className="geek-shell px-4 pt-32 pb-20 sm:px-6 sm:pt-32 sm:pb-24">
      <div className="mx-auto max-w-3xl">
        <p className="animate-rise font-mono text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
          {dict.about.eyebrow}
        </p>
        <h1 className="animate-rise font-display mt-3 text-3xl font-semibold tracking-tight break-words text-[var(--ink)] sm:text-4xl md:text-5xl">
          {dict.about.title}
        </h1>
        <div
          className="animate-rise mt-8 space-y-6 font-mono text-sm leading-relaxed text-[var(--muted)] sm:mt-10 sm:text-base"
          style={{ animationDelay: "100ms" }}
        >
          <p>
            <span className="text-[var(--accent)]">const me = </span>
            &quot;{site.name}&quot;;
          </p>
          <p className="break-words">{dict.about.intro}</p>
        </div>

        <section
          className="animate-rise mt-12 border-t border-[var(--line)] pt-8 sm:mt-14 sm:pt-10"
          style={{ animationDelay: "160ms" }}
        >
          <h2 className="font-mono text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
            {dict.about.strengthsLabel}
          </h2>
          <ul className="mt-6 space-y-5">
            {dict.about.strengths.map((item) => (
              <li
                key={item.label}
                className="font-mono text-sm break-words sm:text-base"
              >
                <span className="font-medium text-[var(--ink)]">
                  {item.label}
                </span>
                <span className="text-[var(--muted)]"> — {item.value}</span>
              </li>
            ))}
          </ul>
        </section>

        <dl
          className="animate-rise mt-12 grid gap-8 border-t border-[var(--line)] pt-8 font-mono sm:mt-14 sm:grid-cols-2 sm:pt-10"
          style={{ animationDelay: "220ms" }}
        >
          <div>
            <dt className="text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
              {dict.about.focusLabel}
            </dt>
            <dd className="mt-2 text-sm break-words text-[var(--ink)]">
              {dict.about.focus}
            </dd>
          </div>
          <div className="min-w-0 sm:col-span-2">
            <dt className="text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
              frontend[]
            </dt>
            <dd className="mt-2 text-sm leading-relaxed break-words text-[var(--ink)]">
              {dict.about.skills.frontend}
            </dd>
          </div>
          <div className="min-w-0 sm:col-span-2">
            <dt className="text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
              backend[]
            </dt>
            <dd className="mt-2 text-sm leading-relaxed break-words text-[var(--ink)]">
              {dict.about.skills.backend}
            </dd>
          </div>
          <div className="min-w-0 sm:col-span-2">
            <dt className="text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
              data_ops[]
            </dt>
            <dd className="mt-2 text-sm leading-relaxed break-words text-[var(--ink)]">
              {dict.about.skills.data}
            </dd>
          </div>
        </dl>
      </div>
    </div>
  );
}
