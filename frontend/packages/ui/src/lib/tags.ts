// Pure helpers for the tag/skill matcher. Content-agnostic: the app maps its content to these shapes.

/** A selectable group of tags — a curated skill category, or the merged tech stack. */
export interface TagGroup {
  category: string;
  tags: string[];
}

/** An experience or project that can demonstrate tags (via its stack). */
export interface MatchEntry {
  kind: "experience" | "project";
  title: string;
  subtitle?: string;
  href?: string;
  tags: string[];
}

/** A ranked evidence entry: the source entry plus which selected tags it matched. */
export interface RankedEntry extends MatchEntry {
  matched: string[];
}

/** Case-insensitive key used for matching and de-duplication. */
export function normalizeKey(label: string): string {
  return label.trim().toLowerCase();
}

/**
 * Build the selectable tag catalog: the curated skill groups as authored, plus a final group
 * gathering every stack tag whose key is not already present in a curated group (exact dedup).
 * Near-variants (curated "Kubernetes (EKS)" vs stack "Kubernetes") legitimately stay distinct.
 */
export function buildTagGroups(
  skills: ReadonlyArray<{ category: string; items: string[] }>,
  stacks: ReadonlyArray<string>,
  techStackLabel = "Tech stack",
): TagGroup[] {
  const curatedKeys = new Set<string>();
  const groups: TagGroup[] = skills.map((s) => {
    for (const item of s.items) curatedKeys.add(normalizeKey(item));
    return { category: s.category, tags: [...s.items] };
  });

  const seen = new Set<string>();
  const techStack: string[] = [];
  for (const tag of stacks) {
    const key = normalizeKey(tag);
    if (curatedKeys.has(key) || seen.has(key)) continue;
    seen.add(key);
    techStack.push(tag);
  }
  if (techStack.length > 0) groups.push({ category: techStackLabel, tags: techStack });
  return groups;
}

/**
 * Rank entries by how many of the selected tags they demonstrate (desc), stable on input order
 * (the app passes experiences most-recent-first). Entries matching no selected tag are dropped.
 */
export function rankEntries(
  entries: ReadonlyArray<MatchEntry>,
  selectedKeys: ReadonlySet<string>,
): RankedEntry[] {
  if (selectedKeys.size === 0) return [];
  return entries
    .map((e) => ({ ...e, matched: e.tags.filter((t) => selectedKeys.has(normalizeKey(t))) }))
    .filter((e) => e.matched.length > 0)
    .sort((a, b) => b.matched.length - a.matched.length);
}

/** Selected tags that no entry demonstrates (e.g. curated leadership skills). Returns original labels. */
export function declaredOnly(
  entries: ReadonlyArray<MatchEntry>,
  selected: ReadonlyArray<string>,
): string[] {
  const evidenced = new Set<string>();
  for (const e of entries) for (const t of e.tags) evidenced.add(normalizeKey(t));
  return selected.filter((s) => !evidenced.has(normalizeKey(s)));
}
