# Doug for Arkansas Website: Agent Guidelines

## Project Overview

This is the custom WordPress campaign website for Doug Corbitt, a Democratic
candidate for Arkansas State Representative in District 54 in 2026.

The WordPress block theme in `wp-content/themes/dougforar/` is the sole website
and the production direction. Do not add a separate static site, design concept,
or frontend build tool unless the user explicitly requests one.

## Architecture

- WordPress 7.1 with PHP 8.2 and MariaDB 11.4 for local development
- Custom block theme in `wp-content/themes/dougforar/`
- Block templates and template parts written as WordPress block markup
- Theme settings and styles in `theme.json` and `style.css`
- Local services managed by Docker Compose
- Local site content initialized by `scripts/setup-local-wordpress.sh`

Use WordPress core blocks and APIs before adding plugins, JavaScript libraries,
CSS frameworks, or build tooling.

## Development

- `npm run wp:setup`: initialize WordPress, activate the theme, and ensure local
  pages exist
- `npm run dev` or `npm run wp:start`: start the existing WordPress and database
  containers
- `npm run wp:stop`: stop and remove the local containers
- `npm run wp:logs`: follow WordPress logs
- Local site: `http://localhost:8080`
- Local admin: `http://localhost:8080/wp-admin/`

The theme directory is bind-mounted into WordPress, so theme changes appear
without rebuilding an image. WordPress core, uploads, and database data live in
Docker volumes and must not be committed.

## Deployment

- `./deploy.sh stage --dry-run` or `./deploy.sh prod --dry-run`: preview a theme
  deployment
- `./deploy.sh stage` or `./deploy.sh prod`: sync the custom theme to an existing
  remote WordPress installation
- Deployment includes only runtime theme files. It does not deploy WordPress
  core, uploads, plugins, database content, or `content/` setup fixtures.
- `scripts/setup-local-wordpress.sh` is local-only. Never run it against staging
  or production.
- Changes to page or post content, WordPress options, users, or plugins require
  a separate database operation with explicit approval. Do not assume deploying
  a changed `content/` fixture updates an existing remote page.
- Deployment settings belong in the ignored `.deploy.env` file. Never commit
  server-specific settings or credentials.
- Run a dry run before every theme deployment. After a production change, check
  the affected public routes and inspect representative desktop and mobile
  renders when appearance could change.

## Production Operations

- Production is a DreamHost-managed WordPress installation at
  `https://www.dougforar.com/`; staging is a separate WordPress installation.
- Production has public registration, comments, and pingbacks disabled. Existing
  content is also closed to comments and pings.
- Production defines `DISALLOW_FILE_EDIT` and `FORCE_SSL_ADMIN` in
  `wp-config.php`. Preserve those settings.
- DreamHost Panel Login is an active plugin that intentionally hides itself from
  the normal Plugins screen. Do not remove it merely because it is not visible
  there.
- UpdraftPlus sends daily database and file backups to Google Drive and retains
  14 of each. Do not expose its OAuth settings or tokens. DreamHost shared
  hosting must not be used for persistent backup storage.
- Local backup archives belong in the ignored `backups/` directory and may
  contain database credentials, password hashes, and personal information. Keep
  them private and never commit them.

## Theme Conventions

- Follow WordPress block-theme conventions.
- Indent HTML with 4 spaces and PHP with 4 spaces.
- Prefix custom PHP functions, CSS classes, and identifiers with `dougforar_`
  or `dc-` as appropriate.
- Keep custom styling in `style.css` and global design tokens in `theme.json`.
- Use semantic HTML, visible keyboard focus, descriptive alternative text, and
  WCAG 2 AA color contrast.
- Keep Unix line endings.

## Content and Privacy

- `facebook-content.md` contains draft source material from Doug's 2024
  campaign. Condense and adapt it, but do not invent positions or biographical
  claims.
- Current confirmed public contact methods are `dougcorbitt@arkansas54.net` and
  the campaign Facebook page.
- Do not publish Doug's phone number without explicit approval.
- Do not add volunteer, email, or SMS collection until the campaign supplies
  the approved service, destination, and required consent text.
- Do not invent donation recipients or links.
- The campaign paid for the website from its campaign checking account, but the
  exact legal name of the true sponsor has not been verified. Arkansas requires
  electronic political communications to identify the true sponsor. Do not
  treat the current disclaimer wording as confirmed until Doug or the campaign
  treasurer verifies that it matches the sponsor name used in campaign records.
- The privacy policy reflects a site with no forms, public accounts, comments,
  advertising cookies, or tracking cookies. Revisit it before adding any of
  those features or embedding third-party content.

## Assets

Original campaign photographs are stored in the root `images/` directory as a
source archive. Files served by the website belong under
`wp-content/themes/dougforar/assets/`; copy and optimize source images there as
needed. Use lowercase kebab-case filenames. Do not upscale low-resolution
photographs beyond a size where they remain visually acceptable.

## Writing Style

- Use plain ASCII in code, scripts, configuration, and Markdown.
- Use straight quotes and ordinary hyphens. Do not use smart quotes, em dashes,
  Unicode arrows, or decorative glyphs.
- Keep campaign copy direct, specific, and grounded in Doug's approved words.

## Git and Generated Files

- Use conventional commit messages with a first line under 72 characters.
- Do not add agent attribution to commits.
- Do not commit WordPress core, uploads, local database data, `node_modules/`,
  `.env`, or temporary files.
