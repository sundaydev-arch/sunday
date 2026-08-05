import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { ProjectList } from "@/components/project-list";
import { isLocale } from "@/lib/site";
import { getDictionary, getProjectsFromDict } from "../dictionaries";

export async function generateMetadata({
  params,
}: PageProps<"/[lang]/projects">): Promise<Metadata> {
  const { lang } = await params;
  if (!isLocale(lang)) return {};
  const dict = await getDictionary(lang);
  return { title: dict.nav.projects };
}

export default async function ProjectsPage({
  params,
}: PageProps<"/[lang]/projects">) {
  const { lang } = await params;
  if (!isLocale(lang)) notFound();
  const dict = await getDictionary(lang);
  const projects = getProjectsFromDict(dict);

  return (
    <div className="geek-shell px-4 pt-32 pb-20 sm:px-6 sm:pt-32 sm:pb-24">
      <div className="mx-auto max-w-5xl">
        <p className="animate-rise font-mono text-xs tracking-[0.2em] text-[var(--accent)] uppercase">
          {dict.projects.eyebrow}
        </p>
        <h1 className="animate-rise font-display mt-3 max-w-2xl text-3xl font-semibold tracking-tight break-words text-[var(--ink)] sm:text-4xl md:text-5xl">
          {dict.projects.title}
        </h1>
        <p
          className="animate-rise mt-5 max-w-xl font-mono text-sm break-words text-[var(--muted)] sm:text-base"
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
