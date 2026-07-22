// Public API of @gmocquet/ui — the only surface the app may import from.

export { ExperienceItem } from "./blocks/experience-item";
export { MediaLinks } from "./blocks/media-links";
export { MediaTimecodes } from "./blocks/media-timecodes";
export { PdfEmbed } from "./blocks/pdf-embed";
export { ProjectCard } from "./blocks/project-card";
export { mediaIcons } from "./blocks/registry";
export { SkillGroup } from "./blocks/skill-group";
export { Stat } from "./blocks/stat";
export { TagMatcher, type TagMatcherProps } from "./blocks/tag-matcher";
export { VideoEmbed } from "./blocks/video-embed";
export { partitionMedia } from "./lib/media";
export { buildTagGroups, type MatchEntry, type TagGroup } from "./lib/tags";
export { cn } from "./lib/utils";
export { mediaUrlAt, timecodeToSeconds, toEmbedUrl } from "./lib/video";
export type {
  ExperienceData,
  HighlightGroup,
  MediaKind,
  MediaLink,
  ProjectData,
} from "./types";
export { Badge } from "./ui/badge";
export { Button, type ButtonProps } from "./ui/button";
export { ThemeToggle } from "./ui/theme-toggle";
