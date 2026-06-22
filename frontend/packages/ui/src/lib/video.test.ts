import { describe, expect, it } from "vitest";
import type { MediaLink } from "../types";
import { toEmbedUrl } from "./video";

const link = (url: string, kind: MediaLink["kind"]): MediaLink => ({ label: "x", url, kind });

describe("toEmbedUrl", () => {
  it("maps a canonical Vimeo URL to a privacy-friendly player URL", () => {
    expect(toEmbedUrl(link("https://vimeo.com/930397924", "vimeo"))).toBe(
      "https://player.vimeo.com/video/930397924?dnt=1",
    );
  });

  it("preserves a Vimeo private hash", () => {
    expect(toEmbedUrl(link("https://vimeo.com/930397924/abc123", "vimeo"))).toBe(
      "https://player.vimeo.com/video/930397924?h=abc123&dnt=1",
    );
  });

  it("maps a Vimeo player URL", () => {
    expect(toEmbedUrl(link("https://player.vimeo.com/video/930397924", "vimeo"))).toBe(
      "https://player.vimeo.com/video/930397924?dnt=1",
    );
  });

  it("maps YouTube watch / short / embed URLs to youtube-nocookie", () => {
    const expected = "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ";
    expect(toEmbedUrl(link("https://www.youtube.com/watch?v=dQw4w9WgXcQ", "youtube"))).toBe(
      expected,
    );
    expect(toEmbedUrl(link("https://youtu.be/dQw4w9WgXcQ", "youtube"))).toBe(expected);
    expect(toEmbedUrl(link("https://www.youtube.com/embed/dQw4w9WgXcQ", "youtube"))).toBe(expected);
  });

  it("returns null for non-video kinds", () => {
    expect(toEmbedUrl(link("/assets/paper.pdf", "pdf"))).toBeNull();
    expect(toEmbedUrl(link("https://example.com", "external"))).toBeNull();
  });

  it("returns null for unparseable or id-less video URLs", () => {
    expect(toEmbedUrl(link("not-a-url", "vimeo"))).toBeNull();
    expect(toEmbedUrl(link("https://vimeo.com/", "vimeo"))).toBeNull();
    expect(toEmbedUrl(link("https://www.youtube.com/watch", "youtube"))).toBeNull();
  });
});
