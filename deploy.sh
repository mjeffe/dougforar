#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

print_usage() {
    cat <<'EOF'
Usage: ./deploy.sh stage|prod [--dry-run]

Build the site and sync dist/ to the configured DreamHost directory.
Settings are loaded from .deploy.env by default. Set
DOUGFORAR_DEPLOY_CONFIG to use another configuration file.
EOF
}

TARGET=""
DRY_RUN=()

for argument in "$@"; do
    case "$argument" in
        stage|prod)
            if [[ -n "$TARGET" ]]; then
                echo "Only one deployment target may be specified." >&2
                print_usage
                exit 2
            fi
            TARGET="$argument"
            ;;
        -n|--dry-run)
            DRY_RUN=(--dry-run)
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $argument" >&2
            print_usage
            exit 2
            ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    print_usage
    exit 2
fi

CONFIG_FILE=${DOUGFORAR_DEPLOY_CONFIG:-"$SCRIPT_DIR/.deploy.env"}
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Deployment configuration not found: $CONFIG_FILE" >&2
    echo "See README.md for the required settings." >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

required=(DEPLOY_HOST DEPLOY_USER)
for variable in "${required[@]}"; do
    if [[ -z "${!variable:-}" ]]; then
        echo "Missing required setting: $variable" >&2
        exit 1
    fi
done

case "$TARGET" in
    stage) remote_dir_variable=DEPLOY_STAGE_DIR ;;
    prod) remote_dir_variable=DEPLOY_PROD_DIR ;;
esac

if [[ -z "${!remote_dir_variable:-}" ]]; then
    echo "Missing required setting: $remote_dir_variable" >&2
    exit 1
fi
REMOTE_DIR=${!remote_dir_variable}

expected_prefix="/home/${DEPLOY_USER}/"
if [[ "$REMOTE_DIR" != "$expected_prefix"* || "$REMOTE_DIR" == "$expected_prefix" ]]; then
    echo "Refusing unsafe remote directory: $REMOTE_DIR" >&2
    echo "DreamHost paths must be below $expected_prefix" >&2
    exit 1
fi

for command in npm rsync; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Required command not found: $command" >&2
        exit 1
    fi
done

echo "Building site..."
npm run build

DESTINATION="${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_DIR%/}/"

if [[ "$TARGET" == "prod" && ${#DRY_RUN[@]} -eq 0 ]]; then
    echo
    read -r -p "Deploy to production at $DESTINATION? [y/N] " answer
    case "$answer" in
        y|Y|yes|YES) ;;
        *) echo "Deployment canceled."; exit 1 ;;
    esac
fi

echo
echo "Syncing dist/ to $DESTINATION"
rsync \
    -avhc \
    --delete \
    --itemize-changes \
    --exclude='.well-known/' \
    --exclude='.dh-diag' \
    "${DRY_RUN[@]}" \
    dist/ \
    "$DESTINATION"

if [[ ${#DRY_RUN[@]} -gt 0 ]]; then
    echo "Dry run complete. No remote files were changed."
else
    echo "Deployment complete."
fi
