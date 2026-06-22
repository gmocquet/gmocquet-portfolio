import { Badge } from "../ui/badge";

/** Renders a labelled group of skills. Content-agnostic. */
export function SkillGroup({ category, items }: { category: string; items: string[] }) {
  return (
    <div className="reveal">
      <h3 className="text-sm font-medium text-fg">{category}</h3>
      <ul className="mt-3 flex flex-wrap gap-1.5">
        {items.map((s) => (
          <li key={s}>
            <Badge>{s}</Badge>
          </li>
        ))}
      </ul>
    </div>
  );
}
