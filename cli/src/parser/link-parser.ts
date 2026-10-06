import {
  LINK_NAME_KEYS,
  LINK_URL_KEYS,
} from '../constants.ts';
import {
  deriveNameFromUrl,
  getFirstString,
  isRecord,
  pushIssue,
} from '../helpers.ts';
import type { InputRecord, Link, ParseIssue } from '../types.ts';
import {
  isLikelyLinkRecord,
  isMetadataOnlyKey,
  parseLinkShorthand,
  toLink,
} from './link-utils.ts';

export const parseLinkEntry = (
  entry: unknown,
  fallbackName: string | undefined,
  issues: ParseIssue[],
  issuePath: string
): Link[] => {
  if (typeof entry === 'string') {
    const parsed = parseLinkShorthand(entry, fallbackName, issues, issuePath);
    return parsed ? [parsed] : [];
  }

  if (entry === null || entry === undefined) {
    pushIssue(issues, issuePath, 'Link entry is empty. Expected a URL or link object.');
    return [];
  }

  if (Array.isArray(entry)) {
    pushIssue(issues, issuePath, 'Link entry cannot be a list. Put lists inside a category.');
    return [];
  }

  if (!isRecord(entry)) {
    pushIssue(issues, issuePath, `Unsupported link entry type '${typeof entry}'. Expected a string or object.`);
    return [];
  }

  const explicitName = getFirstString(entry, LINK_NAME_KEYS) || fallbackName;
  const explicitUrl = getFirstString(entry, LINK_URL_KEYS);
  const entryKeys = Object.keys(entry);

  if (explicitName && explicitUrl) {
    return [toLink(explicitName, explicitUrl, entry)];
  }

  if (!explicitName && explicitUrl) {
    return [toLink(deriveNameFromUrl(explicitUrl), explicitUrl, entry)];
  }

  if (entryKeys.length > 0 && entryKeys.every((key) => isMetadataOnlyKey(key))) {
    pushIssue(
      issues,
      issuePath,
      `Link '${fallbackName || issuePath}' is missing a URL. Use one of ${LINK_URL_KEYS.join(', ')}.`
    );
    return [];
  }

  if (entryKeys.length === 1) {
    const [key, value] = Object.entries(entry)[0] || [];
    return parseLinkEntry(value, key, issues, `${issuePath}.${key}`);
  }

  const links: Link[] = [];

  for (const [key, value] of Object.entries(entry)) {
    if (isMetadataOnlyKey(key)) {
      continue;
    }

    links.push(...parseLinkEntry(value, key, issues, `${issuePath}.${key}`));
  }

  if (links.length === 0) {
    pushIssue(
      issues,
      issuePath,
      `Could not understand this link object. Expected one of ${LINK_URL_KEYS.join(', ')} or a single '<name>: <url>' entry.`
    );
  }

  return links;
};

export const parseLinksCollection = (value: unknown, issues: ParseIssue[], issuePath: string): Link[] => {
  if (Array.isArray(value)) {
    return value.flatMap((entry, index) => parseLinkEntry(entry, undefined, issues, `${issuePath}[${index}]`));
  }

  if (isRecord(value)) {
    return Object.entries(value).flatMap(([key, entry]) =>
      parseLinkEntry(entry, key, issues, `${issuePath}.${key}`)
    );
  }

  if (typeof value === 'string') {
    return parseLinkEntry(value, undefined, issues, issuePath);
  }

  pushIssue(
    issues,
    issuePath,
    `Expected a list of links, a map of links, or a link string. Got '${typeof value}' instead.`
  );
  return [];
};

export const isRootLinkEntry = (value: unknown): boolean =>
  typeof value === 'string' || (isRecord(value) && isLikelyLinkRecord(value));
