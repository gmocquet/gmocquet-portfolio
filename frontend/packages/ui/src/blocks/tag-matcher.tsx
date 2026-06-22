import { useEffect, useMemo, useState } from "react";
import {
  declaredOnly,
  type MatchEntry,
  normalizeKey,
  rankEntries,
  type TagGroup,
} from "../lib/tags";
import { cn } from "../lib/utils";

export interface TagMatcherProps {
  /** Selectable tag catalog, grouped (curated skills + a merged tech-stack group). */
  groups: TagGroup[];
  /** Experiences and projects that can demonstrate tags (via their stack). */
  entries: MatchEntry[];
  /** A few popular tags surfaced as quick picks in the empty state. */
  quickPicks?: string[];
}

const chip =
  "inline-flex items-center rounded-full border px-3 py-1 text-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent";

/**
 * Interactive skill matcher (React island): the visitor selects skill tags and sees a coverage
 * verdict plus the experiences/projects that demonstrate them, ranked by relevance. Content-agnostic.
 */
export function TagMatcher({ groups, entries, quickPicks = [] }: TagMatcherProps) {
  const [selected, setSelected] = useState<string[]>([]);
  const [query, setQuery] = useState("");

  // Canonical label by key, across the whole catalog (URL hydration + dedup).
  const labelByKey = useMemo(() => {
    const map = new Map<string, string>();
    for (const g of groups) for (const t of g.tags) map.set(normalizeKey(t), t);
    return map;
  }, [groups]);

  // Hydrate the selection from ?tags= on mount (client only).
  useEffect(() => {
    const raw = new URLSearchParams(window.location.search).get("tags");
    if (!raw) return;
    const initial = raw
      .split(",")
      .map((s) => labelByKey.get(normalizeKey(decodeURIComponent(s))))
      .filter((s): s is string => Boolean(s));
    if (initial.length) setSelected([...new Set(initial)]);
  }, [labelByKey]);

  // Reflect the selection in the URL (shareable), without growing the history stack.
  useEffect(() => {
    const url = new URL(window.location.href);
    if (selected.length) url.searchParams.set("tags", selected.join(","));
    else url.searchParams.delete("tags");
    window.history.replaceState(null, "", url);
  }, [selected]);

  const selectedKeys = useMemo(() => new Set(selected.map(normalizeKey)), [selected]);
  const ranked = useMemo(() => rankEntries(entries, selectedKeys), [entries, selectedKeys]);
  const declared = useMemo(() => declaredOnly(entries, selected), [entries, selected]);
  const expCount = ranked.filter((e) => e.kind === "experience").length;
  const projCount = ranked.length - expCount;

  const toggle = (tag: string) =>
    setSelected((cur) =>
      cur.some((t) => normalizeKey(t) === normalizeKey(tag))
        ? cur.filter((t) => normalizeKey(t) !== normalizeKey(tag))
        : [...cur, tag],
    );

  const q = query.trim().toLowerCase();
  const visibleGroups = useMemo(
    () =>
      groups
        .map((g) => ({
          ...g,
          tags: q ? g.tags.filter((t) => t.toLowerCase().includes(q)) : g.tags,
        }))
        .filter((g) => g.tags.length > 0),
    [groups, q],
  );
  const noMatch = q.length > 0 && visibleGroups.length === 0;

  return (
    <div>
      <input
        type="search"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Filter skills — e.g. Kubernetes, Airflow, leadership…"
        aria-label="Filter skills"
        className="w-full rounded-md border border-border bg-surface px-4 py-2.5 text-fg placeholder:text-muted focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent"
      />

      {noMatch ? (
        <p className="mt-4 text-muted">
          “<span className="text-fg">{query.trim()}</span>” is not in my profile.
        </p>
      ) : (
        <div className="mt-6 space-y-6">
          {visibleGroups.map((g) => (
            <div key={g.category}>
              <h3 className="text-xs uppercase tracking-widest text-muted">{g.category}</h3>
              <div className="mt-3 flex flex-wrap gap-2">
                {g.tags.map((tag) => {
                  const on = selectedKeys.has(normalizeKey(tag));
                  return (
                    <button
                      key={tag}
                      type="button"
                      aria-pressed={on}
                      onClick={() => toggle(tag)}
                      className={cn(
                        chip,
                        on
                          ? "border-accent bg-accent/10 text-fg"
                          : "border-border text-muted hover:border-accent/50 hover:text-fg",
                      )}
                    >
                      {tag}
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      )}

      {selected.length === 0 ? (
        quickPicks.length > 0 && (
          <div className="mt-10 border-t border-border pt-8">
            <p className="text-muted">Select skills to see where I’ve applied them. Popular:</p>
            <div className="mt-3 flex flex-wrap gap-2">
              {quickPicks.map((tag) => (
                <button
                  key={tag}
                  type="button"
                  onClick={() => toggle(tag)}
                  className={cn(
                    chip,
                    "border-border text-muted hover:border-accent/50 hover:text-fg",
                  )}
                >
                  {tag}
                </button>
              ))}
            </div>
          </div>
        )
      ) : (
        <div className="mt-10 border-t border-border pt-8">
          <div className="flex flex-wrap items-baseline justify-between gap-3">
            <p className="text-fg">
              <span className="font-medium">{selected.length}</span> selected — all in my toolkit{" "}
              <span className="text-muted">
                · {expCount} experience{expCount === 1 ? "" : "s"}, {projCount} project
                {projCount === 1 ? "" : "s"} match
              </span>
            </p>
            <button
              type="button"
              onClick={() => setSelected([])}
              className="text-sm text-muted underline-offset-4 hover:text-accent hover:underline"
            >
              Clear all
            </button>
          </div>

          {declared.length > 0 && (
            <p className="mt-3 text-sm text-muted">
              Also declared in my skill set (no single role tagged):{" "}
              <span className="text-fg">{declared.join(", ")}</span>
            </p>
          )}

          <ul className="mt-6 space-y-4">
            {ranked.map((e) => (
              <li
                key={e.href ?? e.title}
                className="rounded-lg border border-border p-5 transition-colors hover:border-accent/40"
              >
                <div className="flex items-baseline justify-between gap-3">
                  <div>
                    <span className="text-xs uppercase tracking-wider text-accent">{e.kind}</span>
                    <h4 className="mt-1 font-display text-lg text-fg">
                      {e.href ? (
                        <a href={e.href} className="hover:text-accent">
                          {e.title}
                        </a>
                      ) : (
                        e.title
                      )}
                    </h4>
                    {e.subtitle && <p className="text-sm text-muted">{e.subtitle}</p>}
                  </div>
                  <span className="shrink-0 text-sm text-muted">
                    {e.matched.length}/{selected.length}
                  </span>
                </div>
                <div className="mt-3 flex flex-wrap gap-1.5">
                  {e.tags.map((tag) => {
                    const on = selectedKeys.has(normalizeKey(tag));
                    return (
                      <span
                        key={tag}
                        className={cn(
                          "rounded-full border px-2.5 py-0.5 text-xs",
                          on ? "border-accent bg-accent/10 text-fg" : "border-border text-muted",
                        )}
                      >
                        {tag}
                      </span>
                    );
                  })}
                </div>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
