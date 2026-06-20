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
