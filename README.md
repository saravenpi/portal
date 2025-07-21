# portal

`portal` is a command-line tool that generates a beautiful HTML index page from a simple YAML configuration file. It's designed to help you organize and quickly access your projects and their associated links (e.g., documentation, repositories, live deployments).

## Features

*   **YAML-driven Configuration:** Easily define your projects and links in a human-readable `portal.yaml` file.
*   **Automatic Favicons:** Fetches and displays favicons for your links, making navigation more intuitive.
*   **Clean & Responsive HTML Output:** Generates a single, self-contained `index.html` file with a clean and modern design.
*   **Easy Installation:** A convenient `install.sh` script to set up the tool globally on your system.

## Installation

Before you begin, ensure you have [Bun](https://bun.sh/docs/installation) installed on your system.

To install `portal` globally, run the following commands in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/saravenpi/portal/main/install.sh | bash
```

Alternatively, you can download and run the `install.sh` script:

```bash
./install.sh
```

This script will:
1.  Install project dependencies using Bun.
2.  Build the `portal` executable.
3.  Move the `portal` executable to `/usr/local/bin`, making it accessible from anywhere.

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

If `portal.yaml` is not found in the current directory and no path is provided, `portal` will create a default `portal.yaml` for you to get started.

## Configuration (`portal.yaml`)

The `portal.yaml` file defines the structure of your index page. It's an array of projects, where each project contains a name and a list of links.

Here's an example `portal.yaml`:

```yaml
- project: My Awesome Project
  links:
    - name: GitHub Repository
      url: https://github.com/your-org/your-repo
    - name: Live Demo
      url: https://your-project.example.com
- project: Another Project
  links:
    - name: Documentation
      url: https://docs.another-project.com
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
