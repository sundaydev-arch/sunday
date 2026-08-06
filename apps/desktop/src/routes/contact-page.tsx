import { CalEmbed } from "@/components/cal-embed";
import { ContactForm } from "@/components/contact-form";
import { getCalLink, getCalUrl } from "@/lib/cal";
import { useLocale } from "@/lib/locale";
import { openExternal } from "@/lib/open-url";
import { site } from "@/lib/site";

export function ContactPage() {
  const { dict } = useLocale();
  const calLink = getCalLink();
  const calUrl = getCalUrl();

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
              <button
                type="button"
                onClick={() => void openExternal(site.social.github)}
                className="text-[var(--accent)] underline decoration-[var(--line)] underline-offset-4 transition hover:decoration-[var(--accent)]"
              >
                sundaydev-arch
              </button>
            </p>
            <p className="break-all sm:break-normal">
              {dict.contact.website}:{" "}
              <button
                type="button"
                onClick={() => void openExternal(site.social.website)}
                className="text-[var(--accent)] underline decoration-[var(--line)] underline-offset-4 transition hover:decoration-[var(--accent)]"
              >
                sundaydev.vercel.app
              </button>
            </p>
            <p className="break-all sm:break-normal">
              {dict.contact.schedule}:{" "}
              <button
                type="button"
                onClick={() => void openExternal(calUrl)}
                className="text-[var(--accent)] underline decoration-[var(--line)] underline-offset-4 transition hover:decoration-[var(--accent)]"
              >
                cal.com/{calLink ?? "nathan-zhao"}
              </button>
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
          />
        </div>
      </div>

      {calLink ? (
        <section
          className="animate-rise mx-auto mt-14 max-w-5xl sm:mt-16"
          style={{ animationDelay: "180ms" }}
          aria-labelledby="cal-heading"
        >
          <p className="font-mono text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
            {dict.contact.calEyebrow}
          </p>
          <h2
            id="cal-heading"
            className="font-display mt-3 text-2xl font-semibold tracking-tight text-[var(--ink)] sm:text-3xl"
          >
            {dict.contact.calTitle}
          </h2>
          <p className="mt-3 max-w-xl font-mono text-sm leading-relaxed text-[var(--muted)]">
            {dict.contact.calBlurb}
          </p>
          <div className="mt-8 border border-[var(--line)] bg-[var(--panel)]">
            <CalEmbed calLink={calLink} />
          </div>
        </section>
      ) : null}
    </div>
  );
}
