import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { ProjectList } from "@/components/project-list";
import { buildPageMetadata } from "@/lib/seo";
import { isLocale } from "@/lib/site";
import { getDictionary, getProjectsFromDict } from "../dictionaries";

export async function generateMetadata({
  params,
}: PageProps<"/[locale]/projects">): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) return {};
  const dict = await getDictionary(locale);
  return buildPageMetadata({
    lang: locale,
    path: "/projects",
    title: dict.meta.pages.projects.title,
    description: dict.meta.pages.projects.description,
  });
}

export default async function ProjectsPage({
  params,
}: PageProps<"/[locale]/projects">) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const dict = await getDictionary(locale);
  const projects = getProjectsFromDict(dict);

  return (
    <div className="geek-shell px-4 pt-32 pb-20 sm:px-6 sm:pt-32 sm:pb-24">
      <div className="mx-auto max-w-5xl">
        <p className="animate-rise tracking-label font-mono text-xs text-(--accent) uppercase">
          {dict.projects.eyebrow}
        </p>
        <h1 className="animate-rise font-display mt-3 max-w-2xl text-3xl font-semibold tracking-tight break-words text-(--ink) sm:text-4xl md:text-5xl">
          {dict.projects.title}
        </h1>
        <p
          className="animate-rise mt-5 max-w-xl font-mono text-sm break-words text-(--muted) sm:text-base"
          style={{ animationDelay: "80ms" }}
        >
          {dict.projects.blurb}
        </p>
        <div className="mt-6">
          <ProjectList projects={projects} />
        </div>
      </div>
    </div>
  );
}
