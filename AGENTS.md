# Doug for Arkansas Website: Agent Guidelines

## Project Overview

This is the static campaign website for Doug Corbitt, a Democratic candidate
for Arkansas State Representative in District 54 in 2026.

The site is currently in a design-review phase. The root page links to three
initial concepts and one refined working draft:

- `/common-ground/`
- `/neighbor-first/`
- `/bold-campaign/`
- `/refined/`

Keep the concept pages available until a final direction is approved. The
selected design will eventually become the production home page.

## Architecture

- Vite 8 with `src/` as the project root
- Tailwind CSS 4 through the `@tailwindcss/vite` plugin
- CSS-first Tailwind configuration in `src/assets/css/main.css`
- Plain HTML with no template system or JavaScript framework
- Source HTML in `src/`; generated output in `dist/`
- Static files in `src/public/`, copied unchanged to `dist/`

Do not introduce Handlebars, Alpine.js, or another dependency unless the
approved site requires behavior that cannot be implemented simply without it.

## Development

- `npm run dev`: start the Vite development server
- `npm run build`: build the site into `dist/`
- `npm run preview`: serve the production build on port 4173
- `npm run a11y`: audit all configured pages against WCAG 2 AA; requires a
  preview server on `http://localhost:4173` or `PA11Y_BASE_URL`
- `./deploy.sh stage|prod`: build and deploy `dist/` to DreamHost
- `./deploy.sh stage|prod --dry-run`: preview an rsync deployment

Deployment settings belong in the untracked `.deploy.env` file. Never commit
SSH credentials or server-specific secrets.

## Adding or Removing Pages

HTML entry points are explicit. Whenever a page is added, removed, or renamed,
update both:

1. `build.rollupOptions.input` in `vite.config.js`
2. The audited URL list in `.pa11yci.cjs`

## HTML and CSS Conventions

- Indent HTML with 4 spaces.
- Use Tailwind utility classes directly. Avoid one-use component abstractions.
- Use `stone-*`, not `gray-*`, for neutral Tailwind colors.
- Prefer semantic theme colors: `primary`, `primary-hover`, `secondary`,
  `accent`, `paper`, and `ink`.
- Prefix custom CSS classes with `dc-`.
- Use relative paths for internal links and assets.
- Use semantic HTML, visible keyboard focus, descriptive alternative text, and
  WCAG 2 AA color contrast.
- Keep Unix line endings.

## Content and Privacy

- `facebook-content.md` contains draft source material from Doug's 2024
  campaign. Condense and adapt it, but do not invent positions or biographical
  claims.
- Current confirmed public contact methods are `dougcorbitt@arkansas54.net` and the
  campaign Facebook page.
- Do not publish Doug's phone number without explicit approval.
- Do not add donation, volunteer, email, or SMS collection until the campaign
  supplies the approved service, destination, and any required consent text.
- Keep `noindex, nofollow` on concept and staging pages. Remove it only from the
  approved production site.
- The current paid-for disclaimer is provisional and must be confirmed with the
  campaign before production launch.

## Assets

Campaign photographs are in `src/public/assets/img/`. Use lowercase kebab-case
filenames for new assets. Do not upscale low-resolution photographs beyond a
size where they remain visually acceptable.

## Writing Style

- Use plain ASCII in code, scripts, configuration, and Markdown.
- Use straight quotes and ordinary hyphens. Do not use smart quotes, em dashes,
  Unicode arrows, or decorative glyphs.
- Keep campaign copy direct, specific, and grounded in Doug's approved words.

## Git and Generated Files

- Use conventional commit messages with a first line under 72 characters.
- Do not add agent attribution to commits.
- Do not edit or commit `dist/`; it is replaced by every build.
- Do not commit `node_modules/` or `.deploy.env`.
