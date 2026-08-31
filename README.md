# Doug for Arkansas Campaign Website

Static campaign website for Doug Corbitt, candidate for Arkansas State
Representative in District 54.

The project currently contains three design concepts and one refined working
draft. The root page provides links to each option.

## Development

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

## Deployment

Deployment uses SSH and rsync. Create an untracked `.deploy.env` file:

```bash
DEPLOY_HOST="example.dreamhost.com"
DEPLOY_USER="dreamhost-user"
DEPLOY_STAGE_DIR="/home/dreamhost-user/stage.dougforar.com"
DEPLOY_PROD_DIR="/home/dreamhost-user/dougforar.com"
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
