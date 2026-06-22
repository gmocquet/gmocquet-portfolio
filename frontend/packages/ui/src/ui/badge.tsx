import type { ReactNode } from "react";
import { cn } from "../lib/utils";

/** A small, content-agnostic tag (e.g. a tech-stack item). */
export function Badge({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border border-border px-2.5 py-0.5 text-xs text-muted",
        className,
      )}
    >
      {children}
    </span>
  );
}
