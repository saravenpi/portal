# Portal YAML Syntax

This file documents the accepted YAML syntaxes for `portal`.

## Reserved Root Keys

These keys are reserved at the root level:

- `title`
- `name`
- `description`
- `categories`
- `sections`
- `projects`
- `portals`
- `groups`
- `links`

`links` is reserved, but root-level `links:` is not supported anymore.

## Simplest Syntax

Root-level links are valid directly under `title`:

```yaml
title: My Portal

GitHub: https://github.com
Docs: https://docs.example.com
Bun: https://bun.sh
```

## Root-Level Links With Metadata

Each root-level entry can also be a full link object:

```yaml
title: My Portal

GitHub:
  url: https://github.com
  description: Source hosting
  tags: [code, git]

Dashboard:
  href: https://dashboard.example.com
  desc: Internal admin
  private: true
```

Accepted link metadata keys:

- `url`
- `href`
- `link`
- `to`
- `description`
- `desc`
- `details`
- `note`
- `tags`
- `tag`
- `private`

## Category Block Syntax

Top-level category blocks are also valid:

```yaml
title: My Portal

Development:
  GitHub: https://github.com
  Docs: https://docs.example.com
  Bun:
    url: https://bun.sh
    tags: [runtime]
```

## Category List Syntax

Categories can contain a list of links:

```yaml
title: My Portal

Development:
  - GitHub: https://github.com
  - Docs -> https://docs.example.com
  - name: Bun
    url: https://bun.sh
    tags: runtime, tooling
```

## Explicit Categories Container

You can also use an explicit `categories:` container:

```yaml
title: My Portal

categories:
  - category: Development
    links:
      - GitHub: https://github.com
      - Docs -> https://docs.example.com
      - name: Bun
        url: https://bun.sh

  - name: Design
    items:
      Figma: https://figma.com
      Mobbin:
        href: https://mobbin.com
        desc: UI inspiration
```

## Map-Style Categories Container

`categories:` can also be a map:

```yaml
title: My Portal

categories:
  Development:
    GitHub: https://github.com
    Docs: https://docs.example.com

  Design:
    Figma: https://figma.com
    Mobbin:
      url: https://mobbin.com
      description: UI inspiration
```

## List-Only Category

A category can be just a list of URLs:

```yaml
title: My Portal

Best:
  - https://example.com
  - https://bun.sh
  - https://github.com
```

## Mixed Root Links And Categories

You can mix root-level links and categories in the same file:

```yaml
title: My Portal

GitHub: https://github.com
Docs: https://docs.example.com

Infra:
  Railway: https://railway.app
  Fly:
    url: https://fly.io
    tags: [deploy]
```

## Accepted Link Entry Forms

These are all valid link forms inside root entries, category blocks, or link lists:

```yaml
GitHub: https://github.com

GitHub:
  url: https://github.com

GitHub:
  href: https://github.com
  desc: Source hosting

- Docs -> https://docs.example.com
- name: Bun
  url: https://bun.sh
- https://example.com
```

## Invalid Syntax

This is invalid now because root-level `links:` is no longer supported:

```yaml
title: My Portal

links:
  - Docs -> https://docs.example.com
```

Use this instead:

```yaml
title: My Portal

Docs: https://docs.example.com
```
