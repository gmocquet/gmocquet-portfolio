/** A single headline figure. Content-agnostic. */
export function Stat({ value, label }: { value: string; label: string }) {
  return (
    <div>
      <p className="font-display text-4xl text-fg tabular-nums">{value}</p>
      <p className="mt-1 text-sm text-muted">{label}</p>
    </div>
  );
}
