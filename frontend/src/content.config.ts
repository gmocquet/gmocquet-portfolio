import { defineCollection } from "astro:content";
import { z } from "astro:schema";
import { glob } from "astro/loaders";
import { orderedYaml } from "./loaders/ordered-yaml";

// Either an absolute http(s) URL or a root-relative path (e.g. a PDF under public/assets).
const mediaUrl = z.string().refine((s) => /^(https?:\/\/|\/)/.test(s), {
  message: "must be an http(s) URL or a root-relative path",
});

// A "MM:SS" / "H:MM:SS" video timecode.
const timecode = z.string().regex(/^(\d{1,2}:)?[0-5]?\d:[0-5]\d$/, {
  message: 'must be a "MM:SS" or "H:MM:SS" timecode',
});

// A media/reference link attached to an experience or a project.
const mediaLink = z.object({
  label: z.string(),
  url: mediaUrl,
  kind: z
    .enum(["youtube", "vimeo", "slideshare", "pdf", "article", "repo", "external"])
    .default("external"),
  // Intro paragraph rendered above the media when it is embedded inline on a detail page.
  description: z.string().optional(),
  // Opt a `pdf` media into inline embedding (videos embed automatically by kind).
  embed: z.boolean().default(false),
  // Link to the complete document when the embedded one is only an excerpt.
  fullVersion: z.object({ label: z.string(), url: mediaUrl }).optional(),
  // Canonical source page of the media (e.g. broadcaster page), linked from the embed caption.
  source: mediaUrl.optional(),
  // Start the embedded video at this timecode.
  start: timecode.optional(),
  // Notable moments listed below the embed, grouped under optional headings.
  timecodes: z
    .array(
      z.object({
        group: z.string().optional(),
        items: z.array(z.object({ at: timecode, label: z.string() })),
      }),
    )
    .default([]),
});

// Singleton "about me" data (one file: content/profile/profile.yaml).
const profile = defineCollection({
  loader: glob({ pattern: "*.yaml", base: "./content/profile" }),
  schema: z.object({
    name: z.string(),
    headline: z.string(),
    title: z.string(),
    location: z.string(),
    summary: z.array(z.string()), // paragraphs
    contacts: z.object({
      linkedin: z.string().url().optional(),
      github: z.string().url().optional(),
    }),
    topSkills: z.array(z.string()).default([]),
    skills: z.array(z.object({ category: z.string(), items: z.array(z.string()) })).default([]),
    languages: z.array(z.object({ name: z.string(), level: z.string() })).default([]),
    certifications: z
      .array(z.object({ name: z.string(), issuer: z.string().optional() }))
      .default([]),
    education: z
      .array(
        z.object({
          school: z.string(),
          degree: z.string(),
          field: z.string().optional(),
          year: z.number().optional(),
        }),
      )
      .default([]),
  }),
});

// Single ordered list (content/experiences.yaml). Array order = display order (most recent first);
// the loader injects `order` from each item's position — never authored by hand.
const experiences = defineCollection({
  loader: orderedYaml("content/experiences.yaml"),
  schema: z.object({
    order: z.number(),
    company: z.string(),
    role: z.string(),
    location: z.string().optional(),
    start: z.string(), // "YYYY-MM"
    end: z.string().nullable().default(null), // null = present
    summary: z.string(),
    highlights: z
      .array(z.object({ group: z.string().optional(), items: z.array(z.string()) }))
      .default([]),
    stack: z.array(z.string()).default([]),
    media: z.array(mediaLink).default([]),
  }),
});

// Single ordered list (content/projects.yaml). Array order = display order (loader injects `order`).
const projects = defineCollection({
  loader: orderedYaml("content/projects.yaml"),
  schema: z.object({
    order: z.number(),
    title: z.string(),
    company: z.string().optional(),
    period: z.string().optional(),
    role: z.string().optional(),
    summary: z.string(),
    outcomes: z.array(z.string()).default([]),
    stack: z.array(z.string()).default([]),
    media: z.array(mediaLink).default([]),
    // Titled page sections, rendered in array order; body paragraphs, illustration and media are
    // all optional.
    sections: z
      .array(
        z.object({
          title: z.string(),
          body: z.array(z.string()).default([]), // paragraphs
          image: z.object({ src: mediaUrl, alt: z.string() }).optional(),
          // Canonical source of the section content, linked right after the body/illustration.
          source: mediaUrl.optional(),
          media: z.array(mediaLink).default([]),
        }),
      )
      .default([]),
    featured: z.boolean().default(false),
  }),
});

export const collections = { profile, experiences, projects };
