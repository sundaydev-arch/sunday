import type { Metadata } from "next";
import { IBM_Plex_Mono, Space_Grotesk } from "next/font/google";
import { notFound } from "next/navigation";
import { NextIntlClientProvider } from "next-intl";
import { getMessages, setRequestLocale } from "next-intl/server";
import { JsonLd } from "@/components/json-ld";
import { AppToaster } from "@/components/app-toaster";
import { PillNav } from "@/components/pill-nav";
import { PostHogProvider } from "@/components/posthog-provider";
import { SiteFooter } from "@/components/site-footer";
import { buildSiteJsonLd } from "@/lib/seo";
import { isLocale, locales, site } from "@/lib/site";
import { getDictionary } from "./dictionaries";
import "../globals.css";

const display = Space_Grotesk({
  variable: "--font-display",
  subsets: ["latin"],
  weight: ["500", "600", "700"],
});

const mono = IBM_Plex_Mono({
  variable: "--font-mono",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

export function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

export async function generateMetadata({
  params,
}: LayoutProps<"/[locale]">): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) return {};
  const dict = await getDictionary(locale);
  return {
    metadataBase: new URL(site.url),
    title: {
      default: dict.meta.title,
      template: `%s · ${site.name}`,
    },
    description: dict.meta.description,
    applicationName: site.name,
    authors: [{ name: site.name, url: site.url }],
    creator: site.name,
    publisher: site.name,
    keywords: [
      site.name,
      site.jobTitle,
      "TypeScript",
      "Next.js",
      "NestJS",
      "FastAPI",
      "Go",
      "fullstack",
      "portfolio",
    ],
    category: "technology",
    referrer: "origin-when-cross-origin",
    formatDetection: {
      email: false,
      address: false,
      telephone: false,
    },
  };
}

export default async function RootLayout({
  children,
  params,
}: LayoutProps<"/[locale]">) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();

  setRequestLocale(locale);
  const dict = await getDictionary(locale);
  const messages = await getMessages();
  const jsonLd = buildSiteJsonLd(locale, dict.meta.description);

  return (
    <html
      lang={locale}
      data-scroll-behavior="smooth"
      className={`${display.variable} ${mono.variable} h-full antialiased`}
    >
      <body className="flex min-h-full flex-col font-mono text-(--ink)">
        <JsonLd data={jsonLd} />
        <NextIntlClientProvider locale={locale} messages={messages}>
          <PostHogProvider>
            <AppToaster />
            <PillNav
              lang={locale}
              labels={{
                home: dict.nav.home,
                about: dict.nav.about,
                projects: dict.nav.projects,
                contact: dict.nav.contact,
              }}
            />
            <main className="flex flex-1 flex-col">{children}</main>
            <SiteFooter
              lang={locale}
              exitLabel={dict.footer.exit}
              stackLabel={dict.footer.stack}
            />
          </PostHogProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
