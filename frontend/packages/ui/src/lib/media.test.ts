import { describe, expect, it } from "vitest";
import type { MediaLink } from "../types";
import { partitionMedia } from "./media";

const video: MediaLink = {
  label: "talk",
  url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  kind: "youtube",
};
const embeddedPdf: MediaLink = {
  label: "paper",
  url: "/assets/paper.pdf",
  kind: "pdf",
  embed: true,
};
const linkedPdf: MediaLink = { label: "cv", url: "/assets/cv.pdf", kind: "pdf" };
const article: MediaLink = { label: "post", url: "https://example.com", kind: "article" };

describe("partitionMedia", () => {
  it("keeps embeddable videos and opted-in PDFs as sections, in authored order", () => {
    const { sections } = partitionMedia([embeddedPdf, video, article]);
    expect(sections).toEqual([embeddedPdf, video]);
  });

  it("keeps PDFs without embed and non-embeddable media as plain links", () => {
    const { links } = partitionMedia([embeddedPdf, linkedPdf, article]);
    expect(links).toEqual([linkedPdf, article]);
  });

  it("returns empty partitions for empty media", () => {
    expect(partitionMedia([])).toEqual({ sections: [], links: [] });
  });
});
