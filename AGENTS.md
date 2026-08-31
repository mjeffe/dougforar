# ARC Website: Agent Guidelines

## Project Overview

This is the static HTML website for the political candidate Doug Corbitt, running
for Arkansas State Representative for district 54, as a Democrat.

It uses Vite + Tailwind CSS 4 with Handlebars partials for shared header/footer.

## Writing style

- Use plain ASCII characters only. No Unicode decorative glyphs: no smart
  quotes, no fancy arrows, no bullet alternatives. Use standard ASCII
  replacements: `->` for arrows, `*` or `-` for bullets, straight quotes.
- Avoid stylistic tics common in LLM output. No sign-off pleasantries
  ("Certainly!", "Let me know if..."). No overuse of bold/italics for
  emphasis in documents meant for external sharing. Do not use em-dashes; reword
  with a comma, parentheses, or a separate sentence instead.

## Commit Messages

- Follow the Writing style rules above (ASCII only, no em dashes)
- Use conventional commits (feat:, fix:, etc.)
- First line under 72 characters, blank line before body
- No agent attribution or "Generated with" footers

## Architecture

- **Vite** build tool with `@tailwindcss/vite` plugin and `vite-plugin-handlebars`
- **Tailwind CSS 4**: CSS-first config via `@theme {}` in `src/assets/css/main.css`
  (no `tailwind.config.js` or `postcss.config.js`)
- **Handlebars partials** in `src/partials/`: `head.html`, `header.html`, `footer.html`
- All source HTML lives in `src/`, build output goes to `dist/`

## Site Sections

fill this in

## Development

- `npm run dev`: Vite dev server with hot reload
- `npm run build`: production build to `dist/`
- `npm run a11y`: run pa11y-ci accessibility audit (WCAG 2 AA, htmlcs + axe).
  Requires `npm run preview` to be running on `http://localhost:4173`, or set
  `PA11Y_BASE_URL` to test a remote site. `./deploy.sh` runs this automatically
  against the local build before rsyncing to the server.
- Code is in GitHub; only `main` branch is maintained
- Deploy with `./deploy.sh dev|prod` which builds and rsyncs `dist/` to server
- **Keep Unix line endings**: Windows CRLF breaks JS and creates noisy diffs

### Adding a new HTML page

When you add a new page under `src/`, you must also add its path to the `paths`
array in [`.pa11yci.cjs`](./.pa11yci.cjs). Otherwise pa11y will silently skip
auditing it on every deploy. (Vite picks up new `src/*.html` files automatically
for the build, but pa11y has no way to know which URLs to audit.)

## Conventions

- HTML is indented with 4 spaces
- Use Tailwind utility classes directly: no component abstractions
- Use `stone-*` (not `gray-*`) for all gray shades
- Semantic colors defined in `@theme`: `primary`, `primary-hover`, `secondary`, `accent`
- CSS custom styles prefixed with `arc-` (e.g., `arc-accordion`)
- Use relative paths for all internal links and assets
- JS files in `src/assets/` must use `<script type="module">` (plain `<script>` tags 404 in production)
- **ASCII-only in code, scripts, Apache config files, and Markdown files**
  (`*.js`, `*.cjs`, `*.sh`, `*.css`, `*.md`, `apache/*.conf`). No em dashes,
  smart quotes, or Unicode arrows in code or comments: use straight quotes
  and `->` instead. Quick check: `grep -rP '[^\x00-\x7F]' <file>`.
- See `DEVELOPMENT.md` for page template, UI patterns (headings, links, lists,
  thumbnails, cards, accordions, YouTube/Tableau embeds), and Vite build gotchas

## Asset Organization

Static assets live in `src/public/` (copied as-is to `dist/`):

**flll this in...**

All filenames use **lowercase kebab-case**. Thumbnail images use a `-thumb` suffix
(e.g., `edi-phase1-report-thumb.png`).

## Important Notes

- Do NOT modify files in `dist/`: they are overwritten on each build
