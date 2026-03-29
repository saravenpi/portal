import {
  CATEGORY_DESCRIPTION_KEYS,
  CATEGORY_NAME_KEYS,
  LINK_COLLECTION_KEYS,
} from '../constants.ts';
import { getFirstString, isRecord, pushIssue } from '../helpers.ts';
import type { Category, Link, ParseIssue } from '../types.ts';
import { parseLinkEntry, parseLinksCollection } from './link-parser.ts';

export const parseCategory = (
  name: string,
  value: unknown,
  issues: ParseIssue[],
  issuePath: string,
  allowSingleLink = true
): Category | null => {
  if (value === null || value === undefined) {
    pushIssue(issues, issuePath, `Category '${name}' is empty.`);
    return null;
  }

  let description: string | undefined;
  let links: Link[] = [];

  if (Array.isArray(value)) {
    links = parseLinksCollection(value, issues, issuePath);
  } else if (isRecord(value)) {
    description = getFirstString(value, CATEGORY_DESCRIPTION_KEYS);

    for (const key of LINK_COLLECTION_KEYS) {
      if (key in value) {
        links.push(...parseLinksCollection(value[key], issues, `${issuePath}.${key}`));
      }
    }

    const directEntries = Object.entries(value).filter(([key]) => {
      if (CATEGORY_NAME_KEYS.includes(key) || CATEGORY_DESCRIPTION_KEYS.includes(key)) {
        return false;
      }

      if (LINK_COLLECTION_KEYS.includes(key)) {
        return false;
      }

      return true;
    });

    links.push(
      ...directEntries.flatMap(([key, entry]) => parseLinkEntry(entry, key, issues, `${issuePath}.${key}`))
    );
  } else if (typeof value === 'string') {
    if (!allowSingleLink) {
      pushIssue(
        issues,
        issuePath,
        `Top-level category '${name}' must be a map or list of links. For a single link, move it to the root as '<name>: <url>'.`
      );
      return null;
    }

    links = parseLinkEntry(value, name, issues, issuePath);
  } else {
    pushIssue(
      issues,
      issuePath,
      `Category '${name}' has unsupported type '${typeof value}'. Expected a map, list, or URL string.`
    );
    return null;
  }

  if (links.length === 0) {
    pushIssue(issues, issuePath, `Category '${name}' does not contain any valid links.`);
    return null;
  }

  return { category: name, description, links };
};

const parseCategoryEntry = (
  entry: unknown,
  fallbackName: string | undefined,
  issues: ParseIssue[],
  issuePath: string
): Category[] => {
  if (!isRecord(entry)) {
    pushIssue(issues, issuePath, 'Category entry must be an object.');
    return [];
  }

  const explicitName = getFirstString(entry, CATEGORY_NAME_KEYS) || fallbackName;
  if (explicitName) {
    const category = parseCategory(explicitName, entry, issues, issuePath, false);
    return category ? [category] : [];
  }

  if (Object.keys(entry).length === 1) {
    const [key, value] = Object.entries(entry)[0] || [];
    const category = parseCategory(key || '', value, issues, `${issuePath}.${key}`, false);
    return category ? [category] : [];
  }

  pushIssue(
    issues,
    issuePath,
    `Could not determine the category name. Use one of ${CATEGORY_NAME_KEYS.join(', ')}.`
  );
  return [];
};

export const parseCategoriesContainer = (
  value: unknown,
  issues: ParseIssue[],
  issuePath: string
): Category[] => {
  if (Array.isArray(value)) {
    return value.flatMap((entry, index) => parseCategoryEntry(entry, undefined, issues, `${issuePath}[${index}]`));
  }

  if (isRecord(value)) {
    return Object.entries(value).flatMap(([key, entry]) => {
      const category = parseCategory(key, entry, issues, `${issuePath}.${key}`, false);
      return category ? [category] : [];
    });
  }

  pushIssue(
    issues,
    issuePath,
    `Expected a categories container to be a list or map. Got '${typeof value}' instead.`
  );
  return [];
};
