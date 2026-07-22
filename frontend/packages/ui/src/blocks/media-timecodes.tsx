import { ArrowUpRight } from "lucide-react";
import { useRef } from "react";
import { mediaUrlAt, timecodeToSeconds } from "../lib/video";
import type { MediaLink } from "../types";

/**
 * Notable moments of an embedded media, grouped under optional headings. Clicking a timecode seeks
 * the embedded player above (same `<section>`) via the Vimeo/YouTube postMessage API and plays;
 * the external-link icon keeps a plain link to the moment on the platform (new tab). Renders
 * nothing without timecodes. Content-agnostic. Mount as an island (`client:visible`).
 */
export function MediaTimecodes({ media }: { media: MediaLink }) {
  const rootRef = useRef<HTMLDivElement>(null);
  const groups = media.timecodes ?? [];
  if (groups.length === 0) return null;

  function seekTo(tc: string) {
    const seconds = timecodeToSeconds(tc);
    const iframe = rootRef.current?.closest("section")?.querySelector("iframe");
    if (!iframe?.contentWindow) return;
    const player = iframe.contentWindow;
    if (media.kind === "vimeo") {
      player.postMessage(JSON.stringify({ method: "setCurrentTime", value: seconds }), "*");
      player.postMessage(JSON.stringify({ method: "play" }), "*");
    } else if (media.kind === "youtube") {
      player.postMessage(
        JSON.stringify({ event: "command", func: "seekTo", args: [seconds, true] }),
        "*",
      );
      player.postMessage(JSON.stringify({ event: "command", func: "playVideo", args: [] }), "*");
    }
    iframe.scrollIntoView({ behavior: "smooth", block: "nearest" });
  }

  return (
    <div ref={rootRef} className="mt-4 space-y-4">
      {groups.map((g) => (
        <section key={g.group ?? g.items[0]?.at}>
          {g.group ? (
            <h3 className="text-xs uppercase tracking-wider text-muted">{g.group}</h3>
          ) : null}
          <ul className="mt-2 space-y-1.5">
            {g.items.map((item) => (
              <li key={`${item.at}-${item.label}`} className="text-sm text-muted">
                <button
                  type="button"
                  onClick={() => seekTo(item.at)}
                  className="cursor-pointer tabular-nums text-accent underline-offset-4 transition-colors hover:underline"
                >
                  {item.at}
                </button>{" "}
                <a
                  href={mediaUrlAt(media, item.at)}
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label={`Open the video at ${item.at} in a new tab`}
                  className="inline-block align-text-bottom transition-colors hover:text-accent"
                >
                  <ArrowUpRight className="size-3.5" aria-hidden />
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
