import {
  LINK_DESCRIPTION_KEYS,
  LINK_NAME_KEYS,
  LINK_URL_KEYS,
} from '../constants.ts';
import {
  deriveNameFromUrl,
  getFirstString,
  normalizeTags,
  normalizeUrl,
  pushIssue,
  looksLikeUrl,
} from '../helpers.ts';
import type { InputRecord, Link, ParseIssue } from '../types.ts';

export const isMetadataOnlyKey = (key: string): boolean =>
  LINK_NAME_KEYS.includes(key) ||
  LINK_URL_KEYS.includes(key) ||
  LINK_DESCRIPTION_KEYS.includes(key) ||
  key === 'private' ||
  key === 'tags' ||
  key === 'tag';

const hasUrlKey = (record: InputRecord): boolean => LINK_URL_KEYS.some((key) => key in record);

export const isLikelyLinkRecord = (record: InputRecord): boolean => {
  if (hasUrlKey(record)) {
    return true;
  }

  const keys = Object.keys(record);
  if (keys.length === 0) {
    return false;
  }

  if (keys.every((key) => isMetadataOnlyKey(key))) {
    return true;
  }

  if (keys.length === 1) {
    return isMetadataOnlyKey(keys[0] || '');
  }

  return false;
};

export const parseLinkShorthand = (
  value: string,
  fallbackName: string | undefined,
  issues: ParseIssue[],
  issuePath: string
): Link | null => {
  const trimmed = value.trim();
  if (!trimmed) {
    pushIssue(issues, issuePath, 'Expected a URL or link shorthand, but found an empty string.');
    return null;
  }

  if (looksLikeUrl(trimmed)) {
    return {
      name: fallbackName || deriveNameFromUrl(trimmed),
      url: normalizeUrl(trimmed),
    };
  }

  const patterns = [
    /^(.*?)\s*(?:->|=>|\|)\s*(\S+)$/,
    /^(.*?)\s*:\s*(\S+)$/,
    /^(.*?)\s+(\S+)$/,
  ];

  for (const pattern of patterns) {
    const match = trimmed.match(pattern);
    if (!match) {
      continue;
    }

    const [, rawName, rawUrl] = match;
    if (!looksLikeUrl(rawUrl)) {
      continue;
    }

    return {
      name: rawName.trim() || fallbackName || deriveNameFromUrl(rawUrl),
      url: normalizeUrl(rawUrl),
    };
  }

  if (fallbackName) {
    pushIssue(
      issues,
      issuePath,
      `Expected a URL for '${fallbackName}', but got '${trimmed}'. Use a full URL or '<name> -> <url>'.`
    );
    return null;
  }

  pushIssue(issues, issuePath, `Expected a URL or '<name> -> <url>' entry, but got '${trimmed}'.`);
  return null;
};

export const toLink = (name: string, url: string, record?: InputRecord): Link => ({
  name: name.trim(),
  url: normalizeUrl(url),
  private: typeof record?.private === 'boolean' ? record.private : undefined,
  tags: normalizeTags(record?.tags ?? record?.tag),
  description: getFirstString(record || {}, LINK_DESCRIPTION_KEYS),
});
