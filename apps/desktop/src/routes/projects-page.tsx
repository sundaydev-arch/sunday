import { ProjectList } from "@/components/project-list";
import { getProjectsFromDict } from "@/lib/dictionary";
import { useLocale } from "@/lib/locale";

export function ProjectsPage() {
  const { dict } = useLocale();
  const projects = getProjectsFromDict(dict);

  return (
    <div className="geek-shell px-4 pt-32 pb-20 sm:px-6 sm:pt-32 sm:pb-24">
      <div className="mx-auto max-w-5xl">
        <p className="animate-rise font-mono text-xs tracking-label text-(--accent) uppercase">
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
