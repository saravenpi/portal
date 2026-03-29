# portal

`portal` is a command-line tool that generates a beautiful HTML index page from a forgiving YAML configuration file. It is built for the obvious use case: throw links into YAML without babysitting the schema.

## Features

*   **Forgiving Syntax:** Accepts flat maps, arrays, `categories:` / `projects:` containers, shorthand strings, and richer link objects.
*   **Automatic Favicons:** Fetches and displays favicons for your links, making navigation more intuitive.
*   **Clean & Responsive HTML Output:** Generates a single, self-contained `index.html` file with a clean and modern design.
*   **Easy Installation:** A convenient `install.sh` script to set up the tool globally on your system.

## Installation

Before you begin, ensure you have [Bun](https://bun.sh/docs/installation) installed on your system.

To install `portal` globally, run the following command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/saravenpi/portal/main/install.sh | bash
```

This script will:
1.  Check for and install Bun if it's not found.
2.  Clones the `portal` repository into a temporary directory.
3.  Install project dependencies using Bun.
4.  Build the `portal` executable.
5.  Move the `portal` executable to `/usr/local/bin`, making it accessible from anywhere.

## Usage

After installation, you can run `portal` from any directory.

To generate `index.html` using a portal file in your current directory:

```bash
portal
```

`portal` will look for `portal.yml`, `portal.yaml`, or the only `*.portal.yml` file in the current directory.

To specify a different YAML configuration file:

```bash
portal /path/to/your/custom_config.yaml
```

To specify an output file for the generated HTML (defaults to `index.html` in the YAML file's directory):

```bash
portal -o /path/to/your/output.html
# or
portal --outfile /path/to/your/output.html
```

You can combine these flags:

```bash
portal /path/to/your/custom_config.yaml -o /path/to/your/output.html
```

To display help information:

```bash
portal -h
# or
portal --help
```

If no default file is found in the current directory, `portal` creates a starter `portal.yml`.

## Configuration (`portal.yaml`)

The only required idea is simple: your file contains links, either directly at the root or inside categories. Everything else is optional.

The simplest syntax:

```yaml
title: My Portal

Docs: https://docs.example.com
Dashboard: https://dashboard.example.com
GitHub:
  url: https://github.com/example/repo
  description: Still just a link, just with metadata

Operations:
  Grafana:
    url: https://grafana.example.com
    tags: [ops, metrics]
    description: Dashboards and alerts
  Private VPN:
    url: https://vpn.example.com
    private: true
```

Alternative syntaxes are also valid:

```yaml
title: My Portal

categories:
  - category: Development
    description: Where the shipping happens
    links:
      - Docs -> https://docs.example.com
      - name: Repo
        url: https://github.com/example/repo
        tags: code, git
      - Dashboard: https://dashboard.example.com

  - name: Utilities
    items:
      Search: https://search.example.com
      Status:
        href: https://status.example.com
        desc: Everything is probably fine
```

Accepted link syntaxes:

```yaml
title: My Portal

Docs: https://docs.example.com
Repo:
  url: https://github.com/example/repo
  tags: [code]

Development:
  Docs: https://docs.example.com
  Repo:
    url: https://github.com/example/repo
    tags: [code]
  Search: www.google.com

categories:
  - category: Misc
    links:
      - https://example.com
      - Docs -> https://docs.example.com
      - name: Dashboard
        href: https://dashboard.example.com
        desc: Rich object syntax
```

## Example Configuration (`example.yml`)

A non-sensitive example configuration file, `example.yml`, is provided for demonstration purposes. You can use it as a starting point or reference for creating your own `portal.yml`.

To generate `index.html` using the example configuration:

```bash
portal example.yml
```

See [example.yml](/Users/fangafunk/Projects/Ether/portal/example.yml) for a working sample that mixes the simple and rich syntaxes.
For a fuller syntax reference, see [SYNTAX.md](/Users/fangafunk/Projects/Ether/portal/SYNTAX.md).

## Development

If you want to contribute or modify the `portal`:

1.  Clone the repository:
    ```bash
    git clone https://github.com/saravenpi/portal.git
    cd portal
    ```
2.  Install dependencies:
    ```bash
    bun install
    ```
3.  To build the project:
    ```bash
    bun run build
    ```
    This will create a `portal` executable in the project root.

4.  To run the development version:
    ```bash
    bun run src/index.ts [path/to/your/portal.yaml]
    ```

## Project Structure

```
.bun/
node_modules/
src/
└── index.ts
.gitignore
bun.lock
install.sh
package.json
README.md
tsconfig.json
```

## License

This project is licensed under the MIT License - see the LICENSE file for details. (Note: A LICENSE file is not included in the provided context, you may want to add one.)
