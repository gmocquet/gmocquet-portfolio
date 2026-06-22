import { describe, expect, it } from "vitest";
import { buildTagGroups, declaredOnly, type MatchEntry, rankEntries } from "./tags";

const skills = [
  { category: "Cloud & infra", items: ["AWS", "Kubernetes (EKS)"] },
  { category: "Data", items: ["Airflow"] },
];
const stacks = ["AWS", "Kubernetes", "Airflow", "Terraform", "aws"];

describe("buildTagGroups", () => {
  it("keeps curated groups, mapping items -> tags", () => {
    expect(buildTagGroups(skills, stacks).slice(0, 2)).toEqual([
      { category: "Cloud & infra", tags: ["AWS", "Kubernetes (EKS)"] },
      { category: "Data", tags: ["Airflow"] },
    ]);
  });

  it("collects stack tags not already curated, deduped case-insensitively", () => {
    const tech = buildTagGroups(skills, stacks).find((g) => g.category === "Tech stack");
    // "AWS"/"aws" and "Airflow" are curated → excluded; "Kubernetes" (≠ "Kubernetes (EKS)") kept.
    expect(tech?.tags).toEqual(["Kubernetes", "Terraform"]);
  });

  it("omits the tech-stack group when nothing remains", () => {
    expect(buildTagGroups(skills, ["AWS", "Airflow"])).toHaveLength(2);
  });
});

const entries: MatchEntry[] = [
  { kind: "experience", title: "A", tags: ["AWS", "Airflow"] },
  { kind: "experience", title: "B", tags: ["AWS", "Airflow", "Terraform"] },
  { kind: "project", title: "C", tags: ["Redis"] },
];

describe("rankEntries", () => {
  it("returns nothing when no tag is selected", () => {
    expect(rankEntries(entries, new Set())).toEqual([]);
  });

  it("drops non-matching entries and ranks by match count, stable on input order", () => {
    const ranked = rankEntries(entries, new Set(["aws", "airflow", "terraform"]));
    // B matches 3, A matches 2, C (Redis) is dropped.
    expect(ranked.map((e) => e.title)).toEqual(["B", "A"]);
    expect(ranked[0].matched).toEqual(["AWS", "Airflow", "Terraform"]);
  });

  it("preserves input order when match counts tie", () => {
    const ranked = rankEntries(entries, new Set(["aws", "airflow"]));
    expect(ranked.map((e) => e.title)).toEqual(["A", "B"]);
  });
});

describe("declaredOnly", () => {
  it("returns selected tags that no entry demonstrates", () => {
    expect(declaredOnly(entries, ["AWS", "Engineering management"])).toEqual([
      "Engineering management",
    ]);
  });
});
