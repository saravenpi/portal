import type { InputRecord, ParseIssue } from './types.ts';

export const isRecord = (value: unknown): value is InputRecord =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

export const getFirstString = (record: InputRecord, keys: string[]): string | undefined => {
  for (const key of keys) {
    const value = record[key];
    if (typeof value === 'string' && value.trim()) {
      return value.trim();
    }
  }
};

export const pushIssue = (issues: ParseIssue[], path: string, message: string) => {
  issues.push({ path, message });
};

export const normalizeUrl = (value: string): string => {
  const trimmed = value.trim();
  if (/^[a-z][a-z0-9+.-]*:/i.test(trimmed)) {
    return trimmed;
  }
  if (trimmed.startsWith('www.')) {
    return `https://${trimmed}`;
  }
  return trimmed;
};

export const looksLikeUrl = (value: string): boolean => {
  const trimmed = value.trim();
  return /^[a-z][a-z0-9+.-]*:/i.test(trimmed) || trimmed.startsWith('www.');
};

export const deriveNameFromUrl = (value: string): string => {
  const normalized = normalizeUrl(value);
  try {
    const url = new URL(normalized);
    const hostname = url.hostname.replace(/^www\./, '');
    const pathName = url.pathname.replace(/\/$/, '');
    if (pathName && pathName !== '/') {
      return `${hostname}${pathName}`;
    }
    return hostname || normalized;
  } catch {
    return normalized;
  }
};

export const normalizeTags = (value: unknown): string[] | undefined => {
  if (Array.isArray(value)) {
    const tags = value
      .map((tag) => String(tag).trim())
      .filter(Boolean);
    return tags.length > 0 ? tags : undefined;
  }

  if (typeof value === 'string') {
    const tags = value
      .split(',')
      .map((tag) => tag.trim())
      .filter(Boolean);
    return tags.length > 0 ? tags : undefined;
  }
};

export const escapeHtml = (value: string): string =>
  value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
