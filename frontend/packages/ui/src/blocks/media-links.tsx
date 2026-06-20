import { ArrowUpRight } from "lucide-react";
import type { MediaLink } from "../types";
import { mediaIcons } from "./registry";

/** Renders a list of media/reference links (icon by kind). Content-agnostic. */
export function MediaLinks({ media }: { media: MediaLink[] }) {
  if (media.length === 0) return null;
  return (
    <ul className="flex flex-wrap gap-x-5 gap-y-2">
      {media.map((m) => {
        const Icon = mediaIcons[m.kind];
        return (
          <li key={m.url}>
            <a
              href={m.url}
              target="_blank"
              rel="noopener noreferrer"
              className="group inline-flex items-center gap-1.5 text-sm text-muted transition-colors hover:text-accent"
            >
              <Icon className="size-4" aria-hidden />
              <span>{m.label}</span>
              <ArrowUpRight
                className="size-3.5 -translate-x-1 opacity-0 transition-all group-hover:translate-x-0 group-hover:opacity-100"
                aria-hidden
              />
            </a>
          </li>
        );
      })}
    </ul>
  );
}
