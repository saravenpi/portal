import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';

interface Link {
  name: string;
  url: string;
}

interface Project {
  project: string;
  links: Link[];
}

type Config = Project[];

/**
 * Displays the help message for the portal CLI tool and exits the process.
 */
const showHelp = () => {
  console.log(`
Usage: portal [path/to/your/portal.yaml] [options]

portal is a command-line tool that generates a beautiful HTML index page
from a simple YAML configuration file.

Arguments:
  [path/to/your/portal.yaml]  Optional. Path to the YAML configuration file.
                              Defaults to 'portal.yaml' in the current directory.

Options:
  -h, --help                  Display this help message.

Examples:
  portal
  portal my_custom_config.yaml
  portal -h
`);
  process.exit(0);
};

/**
 * Determines the path to the YAML configuration file.
 * It checks for a command-line argument; otherwise, it defaults to 'portal.yaml' in the current working directory.
 * @returns {string} The absolute path to the YAML file.
 */
const getYamlPath = (): string => {
  const args = process.argv.slice(2);

  if (args.includes('-h') || args.includes('--help')) {
    showHelp();
  }

  if (args.length > 0 && args[0]) {
    return path.resolve(args[0]);
  }
  return path.resolve(process.cwd(), 'portal.yaml');
};

/**
 * Loads and parses a YAML file from the given path.
 * @param {string} filePath - The absolute path to the YAML file.
 * @returns {Config} The parsed YAML configuration.
 * @throws {Error} If the file cannot be read or parsed.
 */
const loadYaml = (filePath: string): Config => {
  try {
    const fileContents = fs.readFileSync(filePath, 'utf8');
    return yaml.load(fileContents) as Config;
  } catch (e) {
    console.error(`Error loading or parsing YAML file: ${e}`);
    process.exit(1);
  }
};

/**
 * Generates a favicon URL for a given website URL using Google's favicon service.
 * @param {string} url - The URL of the website.
 * @returns {string} The URL of the favicon, or an empty string if the input URL is invalid.
 */
const getFaviconUrl = (url: string): string => {
  try {
    const urlObj = new URL(url);
    return `https://www.google.com/s2/favicons?domain=${urlObj.hostname}`;
  } catch (e) {
    console.warn(`Invalid URL for favicon: ${url}`);
    return '';
  }
};

/**
 * Generates the HTML content for the portal page based on the provided configuration.
 * @param {Config} config - The configuration object containing projects and links.
 * @returns {Promise<string>} A promise that resolves to the generated HTML string.
 */
const generateHtml = async (config: Config): Promise<string> => {
  const projectsHtmlPromises = config
    .map(async (project) => {
      const linksHtmlPromises = project.links
        .map(async (link) => {
          const faviconUrl = getFaviconUrl(link.url);
          return `<a href="${link.url}">
                    <div class="link-card">
                      ${faviconUrl ? `<img src="${faviconUrl}" alt="" width="16" height="16">` : ''}
                      ${link.name}
                    </div>
                  </a>`;
        });
      const linksHtml = (await Promise.all(linksHtmlPromises)).join('');

      return `
        <div class="project-card">
            <h3>${project.project}</h3>
            <div class="links-container">
                ${linksHtml}
            </div>
        </div>`;
    });
  const projectsHtml = (await Promise.all(projectsHtmlPromises)).join('');

  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚪 Portal</title>
    <style>
        body {
            font-family: sans-serif;
            margin: 40px;
            background-color: #f0f0f0;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1, h3 {
            color: #333;
        }
        .project-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
            border: 2px solid #eee;
        }
        .links-container {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
        }
        .link-card {
            background-color: #f9f9f9;
            border: 1px solid #eee;
            border-radius: 6px;
            padding: 10px 15px;
            display: flex;
            align-items: center;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: transform 0.2s ease-in-out;
        }
        .link-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 3px 6px rgba(0,0,0,0.1);
        }
        .link-card a {
            text-decoration: none;
            color: #007bff;
            display: flex;
            align-items: center;
            font-weight: bold;
        }
        .link-card a:hover {
            text-decoration: underline;
        }
        .link-card img {
            margin-right: 10px;
            width: 16px;
            height: 16px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚪 Portal</h1>
        <div id="projects">
            ${projectsHtml}
        </div>
    </div>
</body>
</html>`;
};

/**
 * Main function to run the portal application.
 * It determines the YAML file path, creates a default one if it doesn't exist,
 * loads the configuration, generates HTML, and writes it to 'index.html'.
 */
const main = async () => {
  const yamlPath = getYamlPath();
  if (!fs.existsSync(yamlPath)) {
    if (yamlPath.endsWith('portal.yaml')) {
      const defaultConfig: Config = [
        {
          project: 'Example Project',
          links: [
            {
              name: 'Example Link',
              url: 'https://example.com',

            },
          ],
        },
      ];
      fs.writeFileSync(yamlPath, yaml.dump(defaultConfig), 'utf8');
      console.log('Created a default projects.yaml file.');
    } else {
      console.error(`Error: YAML file not found at ${yamlPath}`);
      process.exit(1);
    }
  }

  const config = loadYaml(yamlPath);
  const htmlContent = await generateHtml(config);
  const outputPath = path.resolve(path.dirname(yamlPath), 'index.html');
  fs.writeFileSync(outputPath, htmlContent, 'utf8');
  console.log(`Successfully generated index.html at ${outputPath}`);
};

main();
