import { ArrowUpRight, Code, FileText, Film, Newspaper, Play, Presentation } from "lucide-react";
import type { ComponentType } from "react";
import type { MediaKind } from "../types";

type IconComponent = ComponentType<{ className?: string; "aria-hidden"?: boolean }>;

// Registry: media kind -> icon. Add a kind in MediaKind and map it here to support a new media type.
export const mediaIcons: Record<MediaKind, IconComponent> = {
  youtube: Play,
  vimeo: Film,
  slideshare: Presentation,
  pdf: FileText,
  article: Newspaper,
  repo: Code,
  external: ArrowUpRight,
};
