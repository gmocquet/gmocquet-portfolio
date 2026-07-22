import { useState } from "react";
import { Document, Page, pdfjs } from "react-pdf";
import "react-pdf/dist/Page/AnnotationLayer.css";
import "react-pdf/dist/Page/TextLayer.css";

pdfjs.GlobalWorkerOptions.workerSrc = new URL(
  "pdfjs-dist/build/pdf.worker.min.mjs",
  import.meta.url,
).toString();

interface PdfViewerProps {
  url: string;
  /** Rendered page width in CSS pixels (the scroll frame's inner width). */
  width?: number;
  onLoad?: (numPages: number) => void;
}

/**
 * Internal PDF.js document renderer, code-split behind `React.lazy` by `PdfEmbed` — react-pdf
 * touches browser APIs at import time, so this module must never load server-side (keep it out of
 * the library barrel).
 */
export default function PdfViewer({ url, width, onLoad }: PdfViewerProps) {
  const [numPages, setNumPages] = useState<number>();
  return (
    <Document
      file={url}
      onLoadSuccess={(doc) => {
        setNumPages(doc.numPages);
        onLoad?.(doc.numPages);
      }}
      loading={<div className="h-[75vh] animate-pulse bg-surface" />}
      error={
        <p className="px-4 py-8 text-center text-sm text-muted">
          The document could not be displayed —{" "}
          <a href={url} className="text-accent" target="_blank" rel="noopener noreferrer">
            open the PDF
          </a>{" "}
          instead.
        </p>
      }
    >
      {width
        ? Array.from({ length: numPages ?? 0 }, (_, i) => i + 1).map((pageNumber) => (
            <Page key={pageNumber} pageNumber={pageNumber} width={width} />
          ))
        : null}
    </Document>
  );
}
