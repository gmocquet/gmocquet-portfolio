import type { ExperienceData } from "../types";
import { Badge } from "../ui/badge";
import { MediaLinks } from "./media-links";

/** Renders one experience. Content-agnostic: all data comes from props. */
export function ExperienceItem({ experience: e }: { experience: ExperienceData }) {
  return (
    <article className="reveal grid gap-3 border-t border-border pt-8 md:grid-cols-[11rem_1fr] md:gap-8">
      <div className="text-sm text-muted">
        <p>{e.period}</p>
        {e.location ? <p className="mt-1">{e.location}</p> : null}
      </div>
      <div>
        <h3 className="font-display text-xl text-fg">{e.company}</h3>
        <p className="mt-0.5 text-sm text-accent">{e.role}</p>
        <p className="mt-3 max-w-prose text-muted">{e.summary}</p>

        {e.highlights.length > 0 ? (
          <div className="mt-5 space-y-4">
            {e.highlights.map((g) => (
              <div key={g.group ?? g.items[0]}>
                {g.group ? (
                  <p className="text-xs font-medium uppercase tracking-wider text-muted">
                    {g.group}
                  </p>
                ) : null}
                <ul className="mt-2 space-y-1.5">
                  {g.items.map((item) => (
                    <li
                      key={item}
                      className="text-sm leading-relaxed text-fg/85 before:mr-2 before:text-accent before:content-['▸']"
                    >
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        ) : null}

        {e.stack.length > 0 ? (
          <ul className="mt-5 flex flex-wrap gap-1.5">
            {e.stack.map((s) => (
              <li key={s}>
                <Badge>{s}</Badge>
              </li>
            ))}
          </ul>
        ) : null}

        {e.media.length > 0 ? (
          <div className="mt-4">
            <MediaLinks media={e.media} />
          </div>
        ) : null}
      </div>
    </article>
  );
}
