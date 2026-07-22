import { ArrowUpRight } from "lucide-react";
import { lazy, Suspense, useEffect, useRef, useState } from "react";
import type { MediaLink } from "../types";

// react-pdf touches browser APIs at import time; lazy-loading it keeps this module (and the
// library barrel) importable server-side while the viewer chunk only ever loads in the browser.
const PdfViewer = lazy(() => import("./pdf-viewer"));

/**
 * Inline PDF reader (PDF.js) for `pdf` media that opted in via `embed`. Pages render at container
 * width inside a fixed-height scrollable frame; the caption keeps a plain link to the file as a
 * permanent fallback. Content-agnostic. Mount it as a client-only island (`client:only="react"`).
 */
export function PdfEmbed({ media }: { media: MediaLink }) {
  const frameRef = useRef<HTMLDivElement>(null);
  const [width, setWidth] = useState<number>();
  const [numPages, setNumPages] = useState<number>();

  useEffect(() => {
    const frame = frameRef.current;
    if (!frame) return;
    const observer = new ResizeObserver(([entry]) => setWidth(entry.contentRect.width));
    observer.observe(frame);
    return () => observer.disconnect();
  }, []);

  if (media.kind !== "pdf") return null;
  return (
    <figure className="overflow-hidden rounded-lg border border-border">
      <div ref={frameRef} className="h-[75vh] overflow-y-auto bg-surface">
        <Suspense fallback={<div className="h-[75vh] animate-pulse bg-surface" />}>
          <PdfViewer url={media.url} width={width} onLoad={setNumPages} />
        </Suspense>
      </div>
      <figcaption className="flex items-center justify-between gap-4 border-t border-border px-4 py-2 text-sm text-muted">
        <span>
          {media.label}
          {numPages ? ` · ${numPages} pages` : ""}
        </span>
        <a
          href={media.url}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex shrink-0 items-center gap-1 transition-colors hover:text-accent"
        >
          Open
          <ArrowUpRight className="size-3.5" aria-hidden />
        </a>
      </figcaption>
    </figure>
  );
}
