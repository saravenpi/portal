import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';

interface Link {
  name: string;
  url: string;
  private?: boolean;
  tags?: string[];
  description?: string;
}

interface Project {
  project: string;
  description?: string;
  icon?: string;
  links: Link[];
}

interface Config {
  title?: string;
  projects: Project[];
}

/**
 * Displays the help message for the portal CLI tool and exits the process.
 */
const showHelp = () => {
  console.log(`
Usage: portal [path/to/your/portal.yml] [options]

portal is a command-line tool that generates a beautiful HTML index page
from a simple YAML configuration file.

Arguments:
  [path/to/your/portal.yml]  Optional. Path to the YAML configuration file.
                              Defaults to 'portal.yml' in the current directory.

Options:
  -h, --help                  Display this help message.

Examples:
  portal
  portal my_custom_config.yml
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
  return path.resolve(process.cwd(), 'portal.yml');
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
    const loadedYaml = yaml.load(fileContents) as { title?: string; projects: { [key: string]: any } };

    const projects: Project[] = Object.entries(loadedYaml.projects).map(([projectName, projectData]) => {
      const links: Link[] = Object.entries(projectData.links).map(([linkName, linkData]) => {
        if (typeof linkData === 'string') {
          return { name: linkName, url: linkData };
        } else {
          const typedLinkData = linkData as Link;
          return { name: linkName, url: typedLinkData.url, private: typedLinkData.private, tags: typedLinkData.tags, description: typedLinkData.description };
        }
      });

      return {
        project: projectName,
        description: projectData.description,
        icon: projectData.icon,
        links: links,
      };
    });

    return { title: loadedYaml.title, projects };
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
  const projectsHtmlPromises = config.projects
    .map(async (project) => {
      const linksHtmlPromises = project.links
        .map(async (link) => {
          const faviconUrl = getFaviconUrl(link.url);
          return `<a href="${link.url}" class="link-card">
                    <div class="link-card-content">
                      <div class="link-card-main">
                        <div class="link-card-title-group">
                          ${faviconUrl ? `<img src="${faviconUrl}" alt="" width="16" height="16">` : ''}
                          <span>${link.name}</span>
                        </div>
                        ${link.private ? '<span class="private-icon"> 🔒</span>' : ''}
                      </div>
                      ${link.description ? `<div class="link-description">${link.description}</div>` : ''}
                      ${link.tags && link.tags.length > 0 ? `<div class="link-tag-container">${link.tags.map(tag => `<span class="link-tag">${tag}</span>`).join('')}</div>` : ''}
                    </div>
                  </a>`;
        });
      const linksHtml = (await Promise.all(linksHtmlPromises)).join('');

      return `
        <div class="project-card">
            <div class="project-header">
                <h3>${project.project}</h3>
                ${project.icon ? `<h3>${project.icon.startsWith('http') ? `<img src="${project.icon}" alt="" class="project-icon">` : `<span class="project-icon">${project.icon}</span>`}</h3>` : ''}
            </div>
            ${project.description ? `<p>${project.description}</p>` : ''}
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
    <title>${config.title || '🚪 Portal'}</title>
    <style>
        body {
            font-family: sans-serif;
            margin: 20px;
            background-color: #0A0A0A;
            color: #D4D4D4;
        }
        .container {
            max-width: 960px;
            margin: 20px auto;
            background-color: #262626;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.5);
        }

        @media (max-width: 768px) {
            body {
                margin: 10px;
            }
            .container {
                margin: 10px auto;
                padding: 10px;
            }
            .links-container {
                flex-direction: column;
            }
        }

        @media (max-width: 480px) {
            body {
                margin: 5px;
            }
            .container {
                margin: 5px auto;
                padding: 5px;
            }
        }
        h1, h3 {
            color: #F5F5F5;
            margin-top: 0;
        }
        .project-description {
            color: #A3A3A3;
            font-size: 0.9em;
            margin-top: 5px;
            margin-bottom: 15px;
        }
        .project-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        .project-header h3 {
            margin: 0;
        }
        .project-icon {
            width: 32px;
            height: 32px;
            border: 1px solid #525252;
            border-radius: 4px;
            padding: 2px;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 1.2em;
        }
        .project-card h3 {
            display: flex;
            align-items: center;
            margin-top: 0;
            justify-content: space-between;
        }
        .project-card {
            background-color: #262626;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.5);
            padding: 15px 20px;
            margin-bottom: 20px;
            border: 2px solid #404040;
            position: relative;
        }
        .links-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 15px;
            align-items: stretch;
        }
        .link-card {
            background-color: #404040;
            border: 1px solid #525252;
            border-radius: 6px;
            padding: 10px 15px;
            display: flex;
            align-self: stretch;
            box-shadow: 0 2px 4px rgba(0,0,0,0.3);
            transition: transform 0.2s ease-in-out;
            color: #F5F5F5;
            text-decoration: none;
        }
        .link-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.6);
        }
        .link-card-content {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            width: 100%;
            flex-grow: 1;
        }
        .link-description {
            margin-bottom: 8px;
        }
        .link-card-main {
            display: flex;
            align-items: center;
            width: 100%;
            justify-content: space-between;
        }
        .link-card img {
            margin-right: 10px;
            width: 16px;
            height: 16px;
        }
        .link-card-title-group {
            display: flex;
            align-items: center;
            gap: 1px;
        }
        .private-icon {
            margin-left: 5px;
            font-size: 0.8em;
            color: #FFD700;
            border: 1px solid #FFD700;
            padding: 2px 4px;
            border-radius: 4px;
            display: inline-block;
        }
        .link-description {
            font-size: 0.8em;
            color: #A3A3A3;
            margin-top: 5px;
        }
        .link-tag-container {
            margin-top: 5px;
            width: 100%;
            display: flex;
            justify-content: flex-start;
            gap: 5px;
        }
        .link-tag {
            background-color: #7C2D12;
            color: #FDBA74;
            border: 1px solid #FDBA74;
            padding: 2px 8px;
            border-radius: 9999px;
            font-size: 0.7em;
            margin-left: 0;
        }
        .link-tag {
            background-color: #7C2D12;
            color: #FDBA74;
            border: 1px solid #FDBA74;
            padding: 2px 8px;
            border-radius: 9999px;
            font-size: 0.7em;
            margin-left: 0;
        }
        .filters {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        .filters input[type="text"],
        .filters select {
            padding: 8px;
            border-radius: 5px;
            border: 1px solid #404040;
            background-color: #262626;
            color: #D4D4D4;
            flex: 1;
            min-width: 150px;
        }
        .filters input[type="text"]::placeholder {
            color: #A3A3A3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚪 Portal</h1>
        <div class="filters">
            <input type="text" id="search-bar" placeholder="Search links...">
            <select id="tag-filter">
                <option value="">All Tags</option>
                ${[...new Set(config.projects.flatMap(p => p.links).map(l => l.tags).filter(Boolean))].map(tag => `<option value="${tag}">${tag}</option>`).join('')}
            </select>
        </div>
        <div id="projects">
            ${projectsHtml}
        </div>
    </div>
    <script>
        const searchBar = document.getElementById('search-bar');
        const tagFilter = document.getElementById('tag-filter');
        const projectCards = document.querySelectorAll('.project-card');

        function filterLinks() {
            const searchTerm = searchBar.value.toLowerCase();
            const selectedTag = tagFilter.value;

            projectCards.forEach(projectCard => {
                let projectHasVisibleLinks = false;
                const linksContainer = projectCard.querySelector('.links-container');
                const linkCards = linksContainer ? linksContainer.querySelectorAll('.link-card') : [];

                linkCards.forEach(linkCard => {
                    const linkName = linkCard.querySelector('.link-card-main').textContent.toLowerCase();
                    const linkTags = Array.from(linkCard.querySelectorAll('.link-tag')).map(el => el.textContent);

                    const matchesSearch = linkName.includes(searchTerm);
                    const matchesTag = selectedTag === '' || linkTags.includes(selectedTag);

                    if (matchesSearch && matchesTag) {
                        linkCard.style.display = 'flex';
                        projectHasVisibleLinks = true;
                    } else {
                        linkCard.style.display = 'none';
                    }
                });

                if (projectHasVisibleLinks) {
                    projectCard.style.display = 'block';
                } else {
                    projectCard.style.display = 'none';
                }
            });
        }

        searchBar.addEventListener('input', filterLinks);
        tagFilter.addEventListener('change', filterLinks);
    </script>
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
    if (yamlPath.endsWith('portal.yml')) {
      const defaultConfig: Config = {
        projects: [
          {
            project: 'Example Project',
            links: [
              {
                name: 'Example Link',
                url: 'https://example.com',
              },
            ],
          },
        ],
      };
      fs.writeFileSync(yamlPath, yaml.dump(defaultConfig), 'utf8');
    } else {
      console.error(`Error: YAML file not found at ${yamlPath}`);
      process.exit(1);
    }
  }

  const config = loadYaml(yamlPath);
  const htmlContent = await generateHtml(config);
  const outputPath = path.resolve(path.dirname(yamlPath), 'index.html');
  fs.writeFileSync(outputPath, htmlContent, 'utf8');
  console.log(`Successfully created ${outputPath}`);
};

main();
