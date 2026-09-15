# Doug for Arkansas Campaign Website

Custom WordPress block theme for Doug Corbitt, candidate for Arkansas State
Representative in District 54.

The WordPress site is the only website in this repository. Theme source lives
in `wp-content/themes/dougforar/`. Original campaign photography is kept in
`images/`; optimized or cropped files used by the site belong in the theme's
`assets/images/` directory.

## Local development

Requirements: Docker with Docker Compose and the Docker daemon running.

Initialize WordPress, activate the campaign theme, and create the local pages:

```bash
npm run wp:setup
```

The site runs at <http://localhost:8080>. The local-only administrator is
`admin` with password `local-development-only`.

On later runs, start the existing WordPress and database containers with:

```bash
npm run dev
```

The available commands are:

| Command | Purpose |
| --- | --- |
| `npm run wp:setup` | Initialize the local site and ensure its pages exist |
| `npm run dev` | Start the existing local containers |
| `npm run wp:start` | Alias for `npm run dev` |
| `npm run wp:stop` | Stop and remove the local containers |
| `npm run wp:logs` | Follow the WordPress container logs |

These npm scripts invoke Docker Compose; they do not start or stop the Docker
daemon. The custom theme is bind-mounted into WordPress, so theme file changes
appear without rebuilding the container. WordPress core, uploads, and the local
database are stored in Docker volumes and are not committed.

Set `WP_PORT` if port 8080 is unavailable.

## Project structure

- `wp-content/themes/dougforar/`: production theme source
- `wp-content/themes/dougforar/content/`: block content used during local setup
- `scripts/setup-local-wordpress.sh`: repeatable local WordPress initialization
- `images/`: original source photography, not served directly by WordPress
- `compose.yaml`: local WordPress, WP-CLI, and MariaDB services

## Deployment

Deployment syncs only the runtime files in the custom theme. It does not deploy
WordPress core, plugins, uploads, database content, or the local setup fixture
in the theme's `content/` directory. The destination must already be a working
WordPress installation.

Copy `.deploy.env.example` to the ignored `.deploy.env` file and configure the
SSH host, user, and WordPress root directories. Preview a deployment first:

```bash
./deploy.sh stage --dry-run
./deploy.sh prod --dry-run
```

Deploy the theme with:

```bash
./deploy.sh stage
./deploy.sh prod
```

Production deployment requires interactive confirmation. The script uses the
SSH configuration and keys available to the current user.
