import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ContactForm } from "@/components/contact-form";
import { buildPageMetadata } from "@/lib/seo";
import { isLocale, site } from "@/lib/site";
import { getDictionary } from "../dictionaries";

export async function generateMetadata({
  params,
}: PageProps<"/[locale]/contact">): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) return {};
  const dict = await getDictionary(locale);
  return buildPageMetadata({
    lang: locale,
    path: "/contact",
    title: dict.meta.pages.contact.title,
    description: dict.meta.pages.contact.description,
  });
}

export default async function ContactPage({
  params,
}: PageProps<"/[locale]/contact">) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const dict = await getDictionary(locale);

  return (
    <div className="geek-shell px-4 pt-32 pb-20 sm:px-6 sm:pt-32 sm:pb-24">
      <div className="mx-auto grid max-w-5xl gap-10 lg:grid-cols-[1fr_1.1fr] lg:gap-14">
        <div className="min-w-0">
          <p className="animate-rise font-mono text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
            {dict.contact.eyebrow}
          </p>
          <h1 className="animate-rise font-display mt-3 text-3xl font-semibold tracking-tight break-words text-[var(--ink)] sm:text-4xl md:text-5xl">
            {dict.contact.title}
          </h1>
          <p
            className="animate-rise mt-5 max-w-md font-mono text-sm leading-relaxed break-words text-[var(--muted)] sm:text-base"
            style={{ animationDelay: "80ms" }}
          >
            {dict.contact.blurb}
          </p>
          <div
            className="animate-rise mt-8 space-y-3 font-mono text-sm text-[var(--muted)]"
            style={{ animationDelay: "140ms" }}
          >
            <p className="break-all sm:break-normal">
              {dict.contact.github}:{" "}
              <Link
                href={site.social.github}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[var(--accent)] underline decoration-[var(--line)] underline-offset-4 transition hover:decoration-[var(--accent)]"
              >
                sundaydev-arch
              </Link>
            </p>
            <p className="break-all sm:break-normal">
              {dict.contact.website}:{" "}
              <Link
                href={site.social.website}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[var(--accent)] underline decoration-[var(--line)] underline-offset-4 transition hover:decoration-[var(--accent)]"
              >
                sundaydev.vercel.app
              </Link>
            </p>
          </div>
        </div>
        <div
          className="animate-rise min-w-0 border border-[var(--line)] bg-[var(--panel)] p-4 sm:p-6 md:p-8"
          style={{ animationDelay: "120ms" }}
        >
          <p className="mb-6 font-mono text-xs text-[var(--muted)]">
            <span className="text-[var(--accent)]">POST</span> /api/contact
          </p>
          <ContactForm
            labels={{
              ...dict.contact.fields,
              validation: dict.contact.validation,
            }}
            turnstileSiteKey={process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY}
          />
        </div>
      </div>
    </div>
  );
}
