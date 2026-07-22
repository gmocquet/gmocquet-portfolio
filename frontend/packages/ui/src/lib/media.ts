import type { MediaLink } from "../types";
import { toEmbedUrl } from "./video";

/**
 * Split media links into inline-embeddable `sections` (embeddable videos, plus `pdf` media that
 * opted in via `embed`) and plain reference `links`. Sections keep the authored order.
 */
export function partitionMedia(media: MediaLink[]): { sections: MediaLink[]; links: MediaLink[] } {
  const sections = media.filter(
    (m) => toEmbedUrl(m) !== null || (m.kind === "pdf" && m.embed === true),
  );
  return { sections, links: media.filter((m) => !sections.includes(m)) };
}
