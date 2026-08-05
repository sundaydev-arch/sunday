import type { Metadata } from "next";
import { IBM_Plex_Mono, Space_Grotesk } from "next/font/google";
import { notFound } from "next/navigation";
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
  return locales.map((lang) => ({ lang }));
}

export async function generateMetadata({
  params,
}: LayoutProps<"/[lang]">): Promise<Metadata> {
  const { lang } = await params;
  if (!isLocale(lang)) return {};
  const dict = await getDictionary(lang);
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
}: LayoutProps<"/[lang]">) {
  const { lang } = await params;
  if (!isLocale(lang)) notFound();

  const dict = await getDictionary(lang);
  const jsonLd = buildSiteJsonLd(lang, dict.meta.description);

  return (
    <html
      lang={lang}
      data-scroll-behavior="smooth"
      className={`${display.variable} ${mono.variable} h-full antialiased`}
    >
      <body className="flex min-h-full flex-col font-mono text-[var(--ink)]">
        <JsonLd data={jsonLd} />
        <PostHogProvider>
          <AppToaster />
          <PillNav
            lang={lang}
            labels={{
              home: dict.nav.home,
              about: dict.nav.about,
              projects: dict.nav.projects,
              contact: dict.nav.contact,
            }}
          />
          <main className="flex flex-1 flex-col">{children}</main>
          <SiteFooter
            lang={lang}
            exitLabel={dict.footer.exit}
            stackLabel={dict.footer.stack}
          />
        </PostHogProvider>
      </body>
    </html>
  );
}
