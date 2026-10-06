export const portalComponentStyles = `
        .link-card {
            background-color: var(--surface);
            border: 1px solid var(--border-soft);
            border-radius: 14px;
            padding: 16px;
            text-decoration: none;
            color: var(--text);
            display: block;
            box-shadow: 0 16px 40px var(--shadow);
            transition: background-color 0.2s, color 0.2s, border-color 0.2s, transform 0.2s;
        }

        .link-card:hover {
            background-color: var(--surface-hover);
            border-color: var(--accent);
            color: var(--text-strong);
            transform: translateY(-2px);
        }

        .link-card-content {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .link-card-main {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }

        .link-card-title-group {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.15rem;
            font-weight: 600;
        }

        .link-card img {
            width: 18px;
            height: 18px;
            filter: var(--favicon-filter);
        }

        .link-card:hover img {
            filter: none;
        }

        .private-icon {
            font-size: 0.85rem;
            border: 1px solid currentColor;
            border-radius: 999px;
            padding: 3px 8px;
            white-space: nowrap;
        }

        .link-description {
            font-size: 1rem;
            color: var(--text-muted);
        }

        .link-card:hover .link-description {
            color: var(--description-hover);
        }

        .link-tag-container {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .link-tag {
            font-size: 0.85rem;
            border: 1px solid var(--border-soft);
            color: var(--text-muted);
            border-radius: 999px;
            padding: 4px 10px;
        }

        .link-card:hover .link-tag {
            border-color: var(--tag-hover-border);
            color: var(--tag-hover-text);
        }

        .filters {
            display: flex;
            gap: 12px;
            margin-bottom: 28px;
            flex-wrap: wrap;
        }

        .filters input[type="text"],
        .filters select {
            padding: 12px 14px;
            border: 1px solid var(--border-soft);
            border-radius: 12px;
            background-color: var(--surface);
            color: var(--text);
            flex: 1;
            min-width: 220px;
            font-size: 1rem;
            font-family: 'Portal Sans', 'Satoshi', 'Avenir Next', 'Segoe UI', 'Helvetica Neue', sans-serif;
        }

        .filters select {
            -webkit-appearance: none;
            appearance: none;
            box-shadow: none;
        }

        .filters input[type="text"]:focus,
        .filters select:focus {
            outline: none;
            border-color: var(--accent);
            background-color: var(--surface-strong);
        }

        .filters input[type="text"]::placeholder {
            color: var(--placeholder);
        }
`;
