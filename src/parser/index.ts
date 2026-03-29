import * as fs from 'fs';
import * as yaml from 'js-yaml';
import {
  CATEGORY_CONTAINER_KEYS,
  ROOT_LINKS_CATEGORY,
} from '../constants.ts';
import { isRecord, pushIssue } from '../helpers.ts';
import type { Category, Config, InputRecord, Link, ParseIssue } from '../types.ts';
import { parseCategoriesContainer, parseCategory } from './category-parser.ts';
import { isRootLinkEntry, parseLinkEntry } from './link-parser.ts';

const formatIssues = (filePath: string, issues: ParseIssue[]): string => {
  const formattedIssues = issues.map((issue) => `  - ${issue.path}: ${issue.message}`).join('\n');
  return `Invalid portal file '${filePath}':\n${formattedIssues}`;
};

export const loadYaml = (filePath: string): Config => {
  const fileContents = fs.readFileSync(filePath, 'utf8');
  const loadedYaml = yaml.load(fileContents) as unknown;

  if (!isRecord(loadedYaml)) {
    throw new Error('Root YAML value must be a map.');
  }

  const root = loadedYaml as InputRecord;
  const issues: ParseIssue[] = [];
  const categories: Category[] = [];
  const rootLinks: Link[] = [];
  let rootLinksCategory: Category | null = null;

  if ('links' in root) {
    pushIssue(
      issues,
      'links',
      'Root-level \'links\' is no longer supported. Move those entries to the root as \'<name>: <url>\' entries or put them inside a category.'
    );
  }

  for (const [key, value] of Object.entries(root)) {
    if (key === 'title' || key === 'name' || key === 'description' || key === 'links') {
      continue;
    }

    if (CATEGORY_CONTAINER_KEYS.includes(key)) {
      categories.push(...parseCategoriesContainer(value, issues, key));
      continue;
    }

    if (isRootLinkEntry(value)) {
      if (!rootLinksCategory) {
        rootLinksCategory = {
          category: ROOT_LINKS_CATEGORY,
          links: rootLinks,
        };
        categories.push(rootLinksCategory);
      }

      rootLinks.push(...parseLinkEntry(value, key, issues, key));
      continue;
    }

    const category = parseCategory(key, value, issues, key, false);
    if (category) {
      categories.push(category);
    }
  }

  if (categories.length === 0 && issues.length === 0) {
    pushIssue(issues, 'root', 'No links or categories were found. Add root-level links or category sections.');
  }

  if (issues.length > 0) {
    throw new Error(formatIssues(filePath, issues));
  }

  return {
    title: typeof root.title === 'string' ? root.title : undefined,
    categories,
  };
};
