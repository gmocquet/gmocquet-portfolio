import { ArrowUpRight } from "lucide-react";
import type { ProjectData } from "../types";
import { Badge } from "../ui/badge";
import { MediaLinks } from "./media-links";

/** Renders one project card. `href` (optional) links the title to a detail page. */
export function ProjectCard({ project: p, href }: { project: ProjectData; href?: string }) {
  const meta = [p.company, p.period].filter(Boolean).join(" · ");
  return (
    <article className="reveal group flex h-full flex-col rounded-lg border border-border bg-surface/40 p-6 transition-colors hover:border-accent/40">
      {meta ? <p className="text-xs uppercase tracking-wider text-muted">{meta}</p> : null}
      <h3 className="mt-2 font-display text-2xl text-fg">
        {href ? (
          <a
            href={href}
            className="inline-flex items-start gap-1 transition-colors hover:text-accent"
          >
            {p.title}
            <ArrowUpRight
              className="mt-1 size-4 text-muted transition-colors group-hover:text-accent"
              aria-hidden
            />
          </a>
        ) : (
          p.title
        )}
      </h3>
      <p className="mt-3 text-sm leading-relaxed text-muted">{p.summary}</p>

      {p.stack.length > 0 ? (
        <ul className="mt-5 flex flex-wrap gap-1.5">
          {p.stack.slice(0, 6).map((s) => (
            <li key={s}>
              <Badge>{s}</Badge>
            </li>
          ))}
        </ul>
      ) : null}

      {p.media.length > 0 ? (
        <div className="mt-auto pt-5">
          <MediaLinks media={p.media} />
        </div>
      ) : null}
    </article>
  );
}
