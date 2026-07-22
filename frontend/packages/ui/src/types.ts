// Prop contracts for the library's content-agnostic components. The app maps its content collections
// to these shapes; the library never imports the app's content schema.

export type MediaKind =
  | "youtube"
  | "vimeo"
  | "slideshare"
  | "pdf"
  | "article"
  | "repo"
  | "external";

export interface MediaLink {
  label: string;
  url: string;
  kind: MediaKind;
  /** Intro paragraph rendered above the media when it is embedded inline. */
  description?: string;
  /** Opt a `pdf` media into inline embedding (videos embed automatically by kind). */
  embed?: boolean;
  /** Link to the complete document when the embedded one is only an excerpt. */
  fullVersion?: { label: string; url: string };
  /** Start the embedded video at this timecode ("MM:SS" or "H:MM:SS"). */
  start?: string;
  /** Notable moments listed below the embed, grouped under optional headings. */
  timecodes?: { group?: string; items: { at: string; label: string }[] }[];
}

export interface HighlightGroup {
  group?: string;
  items: string[];
}

export interface ExperienceData {
  company: string;
  role: string;
  location?: string;
  period: string;
  summary: string;
  highlights: HighlightGroup[];
  stack: string[];
  media: MediaLink[];
}

export interface ProjectData {
  id: string;
  title: string;
  company?: string;
  period?: string;
  role?: string;
  summary: string;
  outcomes: string[];
  stack: string[];
  media: MediaLink[];
}
