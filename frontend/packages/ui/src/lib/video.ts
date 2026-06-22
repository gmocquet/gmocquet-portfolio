import type { MediaLink } from "../types";

/** Extract a YouTube video id from watch / share / embed URLs. */
function youTubeId(url: URL): string | null {
  if (url.hostname === "youtu.be") return url.pathname.slice(1) || null;
  if (url.pathname.startsWith("/embed/")) return url.pathname.split("/")[2] || null;
  return url.searchParams.get("v");
}

/** Build a privacy-friendly Vimeo player URL from canonical / player URLs (preserves a private hash). */
function vimeoEmbed(url: URL): string | null {
  const parts = url.pathname.split("/").filter(Boolean);
  const idIndex = parts[0] === "video" ? 1 : 0;
  const id = parts[idIndex];
  if (!id || !/^\d+$/.test(id)) return null;
  const hash = parts[idIndex + 1];
  return `https://player.vimeo.com/video/${id}?${hash ? `h=${hash}&` : ""}dnt=1`;
}

/**
 * Derive a privacy-friendly, embeddable player URL for a video media link.
 * Returns `null` for non-video kinds or unrecognizable URLs — callers fall back to a plain link.
 */
export function toEmbedUrl(media: MediaLink): string | null {
  let url: URL;
  try {
    url = new URL(media.url);
  } catch {
    return null;
  }
  if (media.kind === "youtube") {
    const id = youTubeId(url);
    return id ? `https://www.youtube-nocookie.com/embed/${id}` : null;
  }
  if (media.kind === "vimeo") {
    return vimeoEmbed(url);
  }
  return null;
}
