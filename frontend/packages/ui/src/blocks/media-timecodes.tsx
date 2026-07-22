import { mediaUrlAt } from "../lib/video";
import type { MediaLink } from "../types";

/**
 * Notable moments of an embedded media, grouped under optional headings. Each timecode links to
 * the media at that moment (new tab). Renders nothing without timecodes. Content-agnostic.
 */
export function MediaTimecodes({ media }: { media: MediaLink }) {
  const groups = media.timecodes ?? [];
  if (groups.length === 0) return null;
  return (
    <div className="mt-4 space-y-4">
      {groups.map((g) => (
        <section key={g.group ?? g.items[0]?.at}>
          {g.group ? (
            <h3 className="text-xs uppercase tracking-wider text-muted">{g.group}</h3>
          ) : null}
          <ul className="mt-2 space-y-1.5">
            {g.items.map((item) => (
              <li key={`${item.at}-${item.label}`} className="text-sm text-muted">
                <a
                  href={mediaUrlAt(media, item.at)}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="tabular-nums text-accent underline-offset-4 transition-colors hover:underline"
                >
                  {item.at}
                </a>
                <span aria-hidden> ⤑ </span>
                <span className="text-fg/85">{item.label}</span>
              </li>
            ))}
          </ul>
        </section>
      ))}
    </div>
  );
}
