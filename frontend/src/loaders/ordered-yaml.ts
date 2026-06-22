import { readFile } from "node:fs/promises";
import type { Loader } from "astro/loaders";
import { parse } from "yaml";

/**
 * Loads a single YAML file containing an array of entries (each with an `id`) and preserves the
 * file's array order by injecting an `order` field (the array index). `getCollection` otherwise
 * returns entries sorted by id, so consumers sort by `order` to get the authoring order.
 *
 * Authors never write `order` — it is derived from the item's position in the list. To reorder,
 * move an item up or down in the YAML file.
 */
export function orderedYaml(relativePath: string): Loader {
  return {
    name: "ordered-yaml",
    load: async ({ store, parseData, config, watcher, logger }) => {
      const url = new URL(relativePath, config.root);
      const raw = await readFile(url, "utf-8");
      const items = parse(raw) as Array<{ id: string } & Record<string, unknown>>;

      store.clear();
      for (const [index, item] of items.entries()) {
        const { id, ...rest } = item;
        if (!id) {
          logger.warn(`${relativePath}: an item is missing an "id" — skipped.`);
          continue;
        }
        const data = await parseData({ id, data: { ...rest, order: index } });
        store.set({ id, data });
      }

      watcher?.add(url.pathname);
    },
  };
}
