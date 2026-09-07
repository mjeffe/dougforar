# Doug for Arkansas Campaign Website

Campaign website for Doug Corbitt, candidate for Arkansas State Representative
in District 54.

The production direction is a custom WordPress block theme. Earlier static
design concepts remain in `src/` for reference during development.

## WordPress development

Requirements: Docker with Docker Compose and the Docker daemon running.

For the first run, initialize WordPress, activate the campaign theme, create the
local pages, and start the containers with:

```bash
npm run wp:setup
```

The site runs at <http://localhost:8080>. The local-only administrator is
`admin` with password `local-development-only`.

On later runs, start the existing WordPress and database containers with:

```bash
npm run wp:start
```

The available WordPress commands are:

| Command | Purpose |
| --- | --- |
| `npm run wp:setup` | Initialize or refresh the local setup and start it |
| `npm run wp:start` | Start the existing local containers |
| `npm run wp:stop` | Stop the local containers |
| `npm run wp:logs` | Follow the WordPress container logs |

These npm scripts invoke Docker Compose; they do not start or stop the Docker
daemon. The theme is bind-mounted from `wp-content/themes/dougforar`, so theme
file changes appear without rebuilding the container.

Stop the environment with:

```bash
npm run wp:stop
```

Set `WP_PORT` if port 8080 is unavailable.

## Static concept development

Requirements: Node.js 20.19+ or 22.12+ and npm.

```bash
npm install
npm run dev
```

Create a production build with:

```bash
npm run build
```

To run accessibility checks, start `npm run preview` in one terminal and run
`npm run a11y` in another.

## Static concept deployment

Deployment uses SSH and rsync. Create an untracked `.deploy.env` file:

```bash
DEPLOY_HOST="example.dreamhost.com"
DEPLOY_USER="dreamhost-user"
DEPLOY_STAGE_DIR="/home/dreamhost-user/sites/stage.dougforar.com"
DEPLOY_PROD_DIR="/home/dreamhost-user/sites/dougforar.com"
```

Preview a deployment before sending files:

```bash
./deploy.sh stage --dry-run
```

Deploy with:

```bash
./deploy.sh stage
./deploy.sh prod
```

Only the generated contents of `dist/` are uploaded.
