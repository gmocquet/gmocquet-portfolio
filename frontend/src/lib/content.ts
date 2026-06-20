import type { CollectionEntry } from "astro:content";
import type { ExperienceData, ProjectData } from "@gmocquet/ui";

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export function formatMonth(ym: string): string {
  const [y, m] = ym.split("-");
  return `${MONTHS[Number(m) - 1]} ${y}`;
}

export function formatPeriod(start: string, end: string | null): string {
  return `${formatMonth(start)} — ${end ? formatMonth(end) : "Present"}`;
}

/** Map a content `experiences` entry to the library's presentation props. */
export function toExperienceData(d: CollectionEntry<"experiences">["data"]): ExperienceData {
  return {
    company: d.company,
    role: d.role,
    location: d.location,
    period: formatPeriod(d.start, d.end),
    summary: d.summary,
    highlights: d.highlights,
    stack: d.stack,
    media: d.media,
  };
}

/** Map a content `projects` entry to the library's presentation props. */
export function toProjectData(entry: CollectionEntry<"projects">): ProjectData {
  return { id: entry.id, ...entry.data };
}

/** Years between the earliest experience and today. */
export function yearsInEngineering(experiences: CollectionEntry<"experiences">[]): number {
  const startYears = experiences.map((e) => Number(e.data.start.slice(0, 4)));
  return new Date().getFullYear() - Math.min(...startYears);
}
