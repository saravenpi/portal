export const portalBaseStyles = `
        :root {
            --bg: #15171c;
            --surface: #1b1e25;
            --surface-strong: #22262f;
            --surface-hover: #ebe3d5;
            --text: #f4eee3;
            --text-strong: #1c1915;
            --text-muted: #b8af9f;
            --border-soft: #6f675c;
            --accent: #d6a24b;
            --shadow: rgba(6, 8, 12, 0.28);
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
