export interface Link {
  name: string;
  url: string;
  private?: boolean;
  tags?: string[];
  description?: string;
}

export interface Category {
  category: string;
  description?: string;
  links: Link[];
}

export interface Config {
  title?: string;
  categories: Category[];
}

export type InputRecord = Record<string, unknown>;

export type ParseIssue = {
  path: string;
  message: string;
};

export type CliArgs = {
  yamlPath: string;
  outputPath: string;
};
