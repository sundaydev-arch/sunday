import type { Project } from "@/lib/site";

export function ProjectList({ projects }: { projects: Project[] }) {
  return (
    <ul className="divide-y divide-(--line) border-t border-(--line)">
      {projects.map((project, index) => (
        <li
          key={project.id}
          className="group animate-rise py-6 transition hover:bg-(--accent-dim) sm:py-8"
          style={{ animationDelay: `${index * 70}ms` }}
        >
          <div className="flex min-w-0 flex-col gap-4 md:flex-row md:items-start md:justify-between">
            <div className="max-w-2xl min-w-0 flex-1">
              <div className="mb-2 flex flex-col gap-1 sm:flex-row sm:flex-wrap sm:items-baseline sm:gap-x-3">
                <h2 className="font-display text-xl font-medium tracking-tight break-words text-(--ink) sm:text-2xl md:text-3xl">
                  <span className="mr-2 text-(--accent)">›</span>
                  {project.title}
                </h2>
                <span className="shrink-0 font-mono text-xs text-(--muted)">
                  {project.year}
                </span>
              </div>

              <p className="font-mono text-sm break-words text-(--accent)">
                {project.role}
              </p>

              <p className="mt-3 font-mono text-sm leading-relaxed break-words text-(--muted)">
                {project.summary}
              </p>

              <ul className="mt-4 space-y-2">
                {project.highlights.map((item) => (
                  <li
                    key={item}
                    className="flex gap-2 font-mono text-sm leading-relaxed break-words text-(--ink)/85"
                  >
                    <span className="shrink-0 text-(--accent)">-</span>
                    <span className="min-w-0">{item}</span>
                  </li>
                ))}
              </ul>
            </div>

            <ul className="flex flex-wrap gap-2 md:max-w-44 md:justify-end">
              {project.tags.map((tag) => (
                <li
                  key={tag}
                  className="border border-(--line) px-2 py-1 font-mono text-2xs tracking-wider text-(--muted) uppercase"
                >
                  {tag}
                </li>
              ))}
            </ul>
          </div>
        </li>
      ))}
    </ul>
  );
}
