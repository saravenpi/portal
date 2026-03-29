import * as fs from 'fs';

const encodePathSegment = (value: string): string => value.replaceAll(' ', '%20');

const toFileUrl = (fontPath: string): string => `file://${encodePathSegment(fontPath)}`;

const fontExists = (fontPath: string): boolean => fs.existsSync(fontPath);

const homeDirectory = process.env.HOME || '/Users/fangafunk';

const withHome = (relativePath: string): string => `${homeDirectory}/${relativePath}`;

const pickFontSource = (fontPaths: string[], localNames: string[]): string => {
  const localSources = localNames.map((name) => `local('${name}')`);
  const filePath = fontPaths.find(fontExists);

  if (!filePath) {
    return localSources.join(', ');
  }

  return [...localSources, `url('${toFileUrl(filePath)}') format('opentype')`].join(', ');
};

const gambarinoSource = pickFontSource(
  [
    withHome('Library/Fonts/Gambarino-Regular.otf'),
    withHome('.fonts/Gambarino-Regular.otf'),
  ],
  ['Gambarino', 'Gambarino Regular']
);

const satoshiRegularSource = pickFontSource(
  [
    withHome('Library/Fonts/Satoshi-Regular.otf'),
    withHome('.fonts/Satoshi-Regular.otf'),
  ],
  ['Satoshi', 'Satoshi Regular']
);

const satoshiMediumSource = pickFontSource(
  [
    withHome('Library/Fonts/Satoshi-Medium.otf'),
    withHome('.fonts/Satoshi-Medium.otf'),
  ],
  ['Satoshi Medium', 'Satoshi']
);

export const portalFontFaces = `
        @font-face {
            font-family: 'Portal Serif';
            src: ${gambarinoSource};
            font-style: normal;
            font-weight: 400;
        }

        @font-face {
            font-family: 'Portal Sans';
            src: ${satoshiRegularSource};
            font-style: normal;
            font-weight: 400;
        }

        @font-face {
            font-family: 'Portal Sans';
            src: ${satoshiMediumSource};
            font-style: normal;
            font-weight: 600;
        }
`;
