import * as fs from 'fs';
import * as path from 'path';
import type { CliArgs } from './types.ts';

const resolveDefaultYamlPath = (): string => {
  const cwd = process.cwd();
  const directCandidates = ['portal.yml', 'portal.yaml'];

  for (const candidate of directCandidates) {
    const candidatePath = path.resolve(cwd, candidate);
    if (fs.existsSync(candidatePath)) {
      return candidatePath;
    }
  }

  const portalCandidates = fs
    .readdirSync(cwd)
    .filter((file) => /^.+\.portal\.ya?ml$/i.test(file))
    .sort();

  if (portalCandidates.length === 1) {
    return path.resolve(cwd, portalCandidates[0]);
  }

  return path.resolve(cwd, 'portal.yml');
};

export const showHelp = () => {
  console.log(`
Usage: portal [path/to/your/portal.yml] [options]

portal is a command-line tool that generates a beautiful HTML index page
from a forgiving YAML configuration file.

Arguments:
  [path/to/your/portal.yml]  Optional. Path to the YAML configuration file.
                              Defaults to portal.yml, portal.yaml, or the only
                              *.portal.yml file in the current directory.

Options:
  -h, --help                  Display this help message.
  -o, --outfile <path>        Specify the output path for the generated HTML file.
                              Defaults to 'index.html' in the YAML file's directory.

Examples:
  portal
  portal my_custom_config.yml
  portal -o output.html
  portal my_custom_config.yml -o /tmp/my_portal.html
  portal -h

Accepted portal syntaxes:
  title: My Portal
  Docs: https://docs.example.com

  Development:
    Docs: https://docs.example.com

  Development:
    - Docs: https://docs.example.com
    - name: Dashboard
      url: https://dashboard.example.com

  categories:
    - category: Development
      links:
        - Docs -> https://docs.example.com
`);
};

export const parseArgs = (args: string[] = process.argv.slice(2)): CliArgs => {
  let yamlPath: string | undefined;
  let outputPath: string | undefined;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '-h':
      case '--help':
        showHelp();
        process.exit(0);
      case '-o':
      case '--outfile':
        if (i + 1 >= args.length) {
          throw new Error('Error: --outfile requires a path argument.');
        }
        outputPath = path.resolve(args[++i] || '');
        break;
      default:
        if (!yamlPath) {
          yamlPath = path.resolve(arg);
        } else {
          throw new Error(`Error: Unexpected argument: ${arg}`);
        }
    }
  }

  const finalYamlPath = yamlPath || resolveDefaultYamlPath();
  const finalOutputPath = outputPath || path.resolve(path.dirname(finalYamlPath), 'index.html');

  return { yamlPath: finalYamlPath, outputPath: finalOutputPath };
};
