import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { CalEmbed } from "@/components/cal-embed";
import { ContactForm } from "@/components/contact-form";
import { getCalLink, getCalUrl } from "@/lib/cal";
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
  const calLink = getCalLink();
  const calUrl = getCalUrl() ?? site.social.cal;

  return (
    <div className="geek-shell px-4 pt-32 pb-20 sm:px-6 sm:pt-32 sm:pb-24">
      <div className="contact-split mx-auto max-w-5xl">
        <div className="min-w-0">
          <p className="animate-rise tracking-label font-mono text-xs text-(--accent) uppercase">
            {dict.contact.eyebrow}
          </p>
          <h1 className="animate-rise font-display mt-3 text-3xl font-semibold tracking-tight break-words text-(--ink) sm:text-4xl md:text-5xl">
            {dict.contact.title}
          </h1>
          <p
            className="animate-rise mt-5 max-w-md font-mono text-sm leading-relaxed break-words text-(--muted) sm:text-base"
            style={{ animationDelay: "80ms" }}
          >
            {dict.contact.blurb}
          </p>
          <div
            className="animate-rise mt-8 space-y-3 font-mono text-sm text-(--muted)"
            style={{ animationDelay: "140ms" }}
          >
            <p className="break-all sm:break-normal">
              {dict.contact.github}:{" "}
              <Link
                href={site.social.github}
                target="_blank"
                rel="noopener noreferrer"
                className="text-(--accent) underline decoration-(--line) underline-offset-4 transition hover:decoration-(--accent)"
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
                className="text-(--accent) underline decoration-(--line) underline-offset-4 transition hover:decoration-(--accent)"
              >
                sundaydev.vercel.app
              </Link>
            </p>
            <p className="break-all sm:break-normal">
              {dict.contact.schedule}:{" "}
              <Link
                href={calUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="text-(--accent) underline decoration-(--line) underline-offset-4 transition hover:decoration-(--accent)"
              >
                cal.com/{calLink ?? "nathan-zhao"}
              </Link>
            </p>
          </div>
        </div>
        <div
          className="animate-rise min-w-0 border border-(--line) bg-(--panel) p-4 sm:p-6 md:p-8"
          style={{ animationDelay: "120ms" }}
        >
          <p className="mb-6 font-mono text-xs text-(--muted)">
            <span className="text-(--accent)">POST</span> /api/contact
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

      {calLink ? (
        <section
          className="animate-rise mx-auto mt-14 max-w-5xl sm:mt-16"
          style={{ animationDelay: "180ms" }}
          aria-labelledby="cal-heading"
        >
          <p className="tracking-label font-mono text-xs text-(--accent) uppercase">
            {dict.contact.calEyebrow}
          </p>
          <h2
            id="cal-heading"
            className="font-display mt-3 text-2xl font-semibold tracking-tight text-(--ink) sm:text-3xl"
          >
            {dict.contact.calTitle}
          </h2>
          <p className="mt-3 max-w-xl font-mono text-sm leading-relaxed text-(--muted)">
            {dict.contact.calBlurb}
          </p>
          <div className="mt-8 border border-(--line) bg-(--panel)">
            <CalEmbed calLink={calLink} />
          </div>
        </section>
      ) : null}
    </div>
  );
}
