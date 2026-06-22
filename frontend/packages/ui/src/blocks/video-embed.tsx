import { toEmbedUrl } from "../lib/video";
import type { MediaLink } from "../types";

/**
 * Inline, responsive 16:9 video player for `youtube`/`vimeo` media. Content-agnostic.
 * Renders nothing when the link is not an embeddable video (callers keep it as a plain link).
 */
export function VideoEmbed({ media }: { media: MediaLink }) {
  const src = toEmbedUrl(media);
  if (!src) return null;
  return (
    <figure className="overflow-hidden rounded-lg border border-border">
      <div className="aspect-video">
        <iframe
          src={src}
          title={media.label}
          loading="lazy"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
          allowFullScreen
          referrerPolicy="strict-origin-when-cross-origin"
          className="size-full border-0"
        />
      </div>
      <figcaption className="border-t border-border px-4 py-2 text-sm text-muted">
        {media.label}
      </figcaption>
    </figure>
  );
}
