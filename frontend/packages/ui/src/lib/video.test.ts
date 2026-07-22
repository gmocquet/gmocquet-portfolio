import { describe, expect, it } from "vitest";
import type { MediaLink } from "../types";
import { mediaUrlAt, timecodeToSeconds, toEmbedUrl } from "./video";

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

  it("starts the player at the media `start` timecode", () => {
    expect(toEmbedUrl({ ...link("https://vimeo.com/930397924", "vimeo"), start: "17:14" })).toBe(
      "https://player.vimeo.com/video/930397924?dnt=1#t=1034s",
    );
    expect(
      toEmbedUrl({ ...link("https://youtu.be/dQw4w9WgXcQ", "youtube"), start: "1:00:05" }),
    ).toBe("https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?start=3605");
  });
});

describe("timecodeToSeconds", () => {
  it("parses MM:SS and H:MM:SS", () => {
    expect(timecodeToSeconds("09:45")).toBe(585);
    expect(timecodeToSeconds("17:10")).toBe(1030);
    expect(timecodeToSeconds("1:02:30")).toBe(3750);
  });
});

describe("mediaUrlAt", () => {
  it("links to the moment on Vimeo via a #t fragment", () => {
    expect(mediaUrlAt(link("https://vimeo.com/930397924", "vimeo"), "29:35")).toBe(
      "https://vimeo.com/930397924#t=1775s",
    );
  });

  it("links to the moment on YouTube via the t param", () => {
    expect(
      mediaUrlAt(link("https://www.youtube.com/watch?v=dQw4w9WgXcQ", "youtube"), "12:20"),
    ).toBe("https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=740s");
  });

  it("falls back to the plain URL for other kinds", () => {
    expect(mediaUrlAt(link("/assets/paper.pdf", "pdf"), "01:00")).toBe("/assets/paper.pdf");
  });
});
