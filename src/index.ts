import * as fs from 'fs';
import * as yaml from 'js-yaml';
import { parseArgs } from './cli.ts';
import { loadYaml } from './parser/index.ts';
import { generateHtml } from './render.ts';

const createDefaultConfig = () => ({
  title: 'Portal',
  Development: [
    { Docs: 'https://docs.example.com' },
    { Dashboard: 'https://dashboard.example.com' },
    {
      Repo: {
        url: 'https://github.com/example/repo',
        tags: ['code'],
      },
    },
  ],
});

const ensureInputFile = (yamlPath: string) => {
  if (fs.existsSync(yamlPath)) {
    return;
  }

  if (yamlPath.endsWith('portal.yml') || yamlPath.endsWith('portal.yaml')) {
    fs.writeFileSync(yamlPath, yaml.dump(createDefaultConfig()), 'utf8');
    return;
  }

  throw new Error(`Error: YAML file not found at ${yamlPath}`);
};

const main = async () => {
  try {
    const { yamlPath, outputPath } = parseArgs();
    ensureInputFile(yamlPath);

    const config = loadYaml(yamlPath);
    const htmlContent = await generateHtml(config);
    fs.writeFileSync(outputPath, htmlContent, 'utf8');
    console.log(`Successfully created ${outputPath}`);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(message);
    process.exit(1);
  }
};

main();
