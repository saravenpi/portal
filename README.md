# portal

`portal` is a command-line tool that generates a beautiful HTML index page from a simple YAML configuration file. It's designed to help you organize and quickly access your projects and their associated links (e.g., documentation, repositories, live deployments).

## Features

*   **YAML-driven Configuration:** Easily define your projects and links in a human-readable `portal.yml` file.
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

To generate `index.html` using a `portal.yaml` file in your current directory:

```bash
portal
```

To specify a different YAML configuration file:

```bash
portal /path/to/your/custom_config.yaml
```

To display help information:

```bash
portal -h
# or
portal --help
```

If `portal.yaml` is not found in the current directory and no path is provided, `portal` will create a default `portal.yaml` for you to get started.

## Configuration (`portal.yaml`)

The `portal.yml` file defines the structure of your index page. It can include a global `title` for the HTML page and an array of projects. Each project contains a name, an optional description, an optional icon, and a list of links. Each link can also have an optional description and multiple tags.

Here's an example `portal.yml`:

```yaml
title: My Awesome Portal # Optional: Sets the title of the HTML page
projects:
  - project: My Awesome Project
    description: A short description of my awesome project.
    icon: "🚀" # Can be an emoji or a URL to an image (e.g., https://example.com/icon.png)
    links:
      - name: GitHub Repository
        url: https://github.com/your-org/your-repo
        description: The official GitHub repository for this project.
      - name: Live Demo
        url: https://your-project.example.com
  - project: Another Project
    links:
      - name: Documentation
        url: https://docs.another-project.com
```

## Example Configuration (`example.yml`)

A non-sensitive example configuration file, `example.yml`, is provided for demonstration purposes. You can use it as a starting point or reference for creating your own `portal.yml`.

To generate `index.html` using the example configuration:

```bash
portal example.yml
```

Here's the content of `example.yml`:

```yaml
title: Example Portal
projects:
  ExampleProject1:
    description: A sample internal development platform.
    icon: "💻"
    links:
      Docs: https://docs.example.com
      Dashboard: https://dashboard.example.com
      Repo: https://github.com/example/repo
      PrivateLink:
        url: https://private.example.com
        private: true
      Monitoring:
        url: https://monitor.example.com
        tags: [ops, monitoring]

  ExampleProject2:
    description: A sample side project for food delivery.
    icon: "🍔"
    links:
      Admin: https://admin.example.com
      Frontend: https://frontend.example.com
      Backend: https://backend.example.com
      MobileApp:
        url: https://mobile.example.com
        tags: [mobile, app]

  Utilities:
    description: Useful personal links.
    icon: "🛠️"
    links:
      SearchEngine: https://www.example-search.com
      CloudConsole: https://console.example-cloud.com
```

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
