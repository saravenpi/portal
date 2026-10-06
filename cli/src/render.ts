import { escapeHtml } from './helpers.ts';
import { portalStyles } from './styles.ts';
import type { Config, Link } from './types.ts';

const getFaviconUrl = (url: string): string => {
  try {
    const urlObj = new URL(url);
    return `https://www.google.com/s2/favicons?domain=${urlObj.hostname}`;
  } catch {
    return '';
  }
};

const renderLink = (link: Link): string => {
  const faviconUrl = getFaviconUrl(link.url);
  const safeUrl = escapeHtml(link.url);
  const safeName = escapeHtml(link.name);
  const safeDescription = link.description ? escapeHtml(link.description) : '';
  const tagsHtml = (link.tags || [])
    .map((tag) => `<span class="link-tag">${escapeHtml(tag)}</span>`)
    .join('');

  return `<a href="${safeUrl}" class="link-card" target="_blank" rel="noopener noreferrer">
                    <div class="link-card-content">
                      <div class="link-card-main">
                        <div class="link-card-title-group">
                          ${faviconUrl ? `<img src="${escapeHtml(faviconUrl)}" alt="" width="18" height="18">` : ''}
                          <span>${safeName}</span>
                        </div>
                        ${link.private ? '<span class="private-icon">LOCKED</span>' : ''}
                      </div>
                      ${safeDescription ? `<div class="link-description">${safeDescription}</div>` : ''}
                      ${tagsHtml ? `<div class="link-tag-container">${tagsHtml}</div>` : ''}
                    </div>
                  </a>`;
};

const renderCategory = (category: Config['categories'][number]): string => {
  const description = category.description ? `<p>${escapeHtml(category.description)}</p>` : '';
  const linksHtml = category.links.map(renderLink).join('');

  return `
        <div class="category-card">
            <h3>${escapeHtml(category.category)}</h3>
            ${description}
            <div class="links-container">
                ${linksHtml}
            </div>
        </div>`;
};

export const generateHtml = async (config: Config): Promise<string> => {
  const categoriesHtml = config.categories.map(renderCategory).join('');
  const uniqueTags = [...new Set(config.categories.flatMap((category) => category.links.flatMap((link) => link.tags || [])))];
  const tagOptions = uniqueTags
    .map((tag) => `<option value="${escapeHtml(tag)}">${escapeHtml(tag)}</option>`)
    .join('');

  return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escapeHtml(config.title || 'Portal')}</title>
    <style>
${portalStyles}
    </style>
</head>
<body>
    <div class="container">
        <h1>${escapeHtml(config.title || 'Portal')}</h1>
        <div class="filters">
            <input type="text" id="search-bar" placeholder="Search links...">
            <select id="tag-filter">
                <option value="">All Tags</option>
                ${tagOptions}
            </select>
        </div>
        <div id="categories">
            ${categoriesHtml}
        </div>
    </div>
    <script>
        const searchBar = document.getElementById('search-bar');
        const tagFilter = document.getElementById('tag-filter');
        const categoryCards = document.querySelectorAll('.category-card');

        function filterLinks() {
            const searchTerm = searchBar.value.toLowerCase();
            const selectedTag = tagFilter.value;

            categoryCards.forEach(categoryCard => {
                let categoryHasVisibleLinks = false;
                const linksContainer = categoryCard.querySelector('.links-container');
                const linkCards = linksContainer ? linksContainer.querySelectorAll('.link-card') : [];

                linkCards.forEach(linkCard => {
                    const linkName = linkCard.querySelector('.link-card-main').textContent.toLowerCase();
                    const linkTags = Array.from(linkCard.querySelectorAll('.link-tag')).map(el => el.textContent);

                    const matchesSearch = linkName.includes(searchTerm);
                    const matchesTag = selectedTag === '' || linkTags.includes(selectedTag);

                    if (matchesSearch && matchesTag) {
                        linkCard.style.display = 'block';
                        categoryHasVisibleLinks = true;
                    } else {
                        linkCard.style.display = 'none';
                    }
                });

                if (categoryHasVisibleLinks) {
                    categoryCard.style.display = 'block';
                } else {
                    categoryCard.style.display = 'none';
                }
            });
        }

        searchBar.addEventListener('input', filterLinks);
        tagFilter.addEventListener('change', filterLinks);
    </script>
</body>
</html>`;
};
