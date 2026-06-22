// Public API of @gmocquet/ui — the only surface the app may import from.

export { ExperienceItem } from "./blocks/experience-item";
export { MediaLinks } from "./blocks/media-links";
export { ProjectCard } from "./blocks/project-card";
export { mediaIcons } from "./blocks/registry";
export { SkillGroup } from "./blocks/skill-group";
export { Stat } from "./blocks/stat";
export { VideoEmbed } from "./blocks/video-embed";
export { cn } from "./lib/utils";
export { toEmbedUrl } from "./lib/video";
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
