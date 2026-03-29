export const portalBaseStyles = `
        :root {
            color-scheme: dark;
            --bg: #09090C;
            --surface: #0f0f12;
            --surface-strong: #15161a;
            --surface-hover: #1a1c21;
            --text: #f5f6f8;
            --text-strong: #ffffff;
            --text-muted: #9ba3b1;
            --border-soft: #2b3039;
            --accent: #cc9d3b;
            --shadow: rgba(0, 0, 0, 0.55);
            --tag-hover-border: rgba(245, 246, 248, 0.32);
            --tag-hover-text: #f5e3bf;
            --description-hover: #d9dde8;
            --placeholder: #6e7381;
            --favicon-filter: saturate(0) brightness(1.2);
        }

        @media (prefers-color-scheme: light) {
            :root {
                color-scheme: light;
                --bg: #f2eee6;
                --surface: #fcfaf6;
                --surface-strong: #f4efe5;
                --surface-hover: #efe7d8;
                --text: #1f2733;
                --text-strong: #141a22;
                --text-muted: #6d7684;
                --border-soft: #d6cbb8;
                --accent: #9c6c2f;
                --shadow: rgba(54, 43, 25, 0.12);
                --tag-hover-border: rgba(31, 39, 51, 0.16);
                --tag-hover-text: #61431c;
                --description-hover: #384252;
                --placeholder: #8e8577;
                --favicon-filter: saturate(0) brightness(0.78);
            }
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            min-height: 100%;
        }

        body {
            min-height: 100vh;
            background-color: var(--bg);
            color: var(--text);
            padding: 32px 24px 56px;
            line-height: 1.7;
            font-family: 'Portal Sans', 'Satoshi', 'Avenir Next', 'Segoe UI', 'Helvetica Neue', sans-serif;
        }

        .container {
            max-width: 1240px;
            margin: 0 auto;
        }

        h1,
        h3 {
            font-family: 'Portal Serif', 'Gambarino', 'Iowan Old Style', 'Palatino Linotype', 'Book Antiqua', serif;
            font-weight: 400;
            letter-spacing: 0.01em;
        }

        h1 {
            font-size: clamp(2.4rem, 4vw, 4rem);
            line-height: 0.98;
            margin-bottom: 24px;
            border-bottom: 1px solid var(--border-soft);
            padding-bottom: 14px;
        }

        h3 {
            font-size: 1.7rem;
            margin-bottom: 16px;
        }

        .category-card {
            margin-bottom: 36px;
            padding-bottom: 36px;
            border-bottom: 1px solid var(--border-soft);
        }

        .category-card:last-child {
            border-bottom: none;
        }

        .category-card p {
            margin-bottom: 16px;
            font-size: 1.02rem;
            color: var(--text-muted);
        }

        .links-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 14px;
        }

        @media (max-width: 768px) {
            body {
                padding: 24px 16px 40px;
            }

            h1 {
                margin-bottom: 20px;
            }

            .links-container {
                grid-template-columns: 1fr;
            }
        }
`;
