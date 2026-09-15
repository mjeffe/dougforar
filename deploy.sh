#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
theme_dir="$script_dir/wp-content/themes/dougforar"

print_usage() {
    cat <<'EOF'
Usage: ./deploy.sh stage|prod [--dry-run]

Sync the custom WordPress theme to an existing remote WordPress installation.
Settings are loaded from .deploy.env by default. Set
DOUGFORAR_DEPLOY_CONFIG to use another configuration file.
EOF
}

target=""
dry_run=()

for argument in "$@"; do
    case "$argument" in
        stage|prod)
            if [[ -n "$target" ]]; then
                echo "Only one deployment target may be specified." >&2
                print_usage
                exit 2
            fi
            target="$argument"
            ;;
        -n|--dry-run)
            dry_run=(--dry-run)
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

if [[ -z "$target" ]]; then
    print_usage
    exit 2
fi

config_file=${DOUGFORAR_DEPLOY_CONFIG:-"$script_dir/.deploy.env"}
if [[ ! -f "$config_file" ]]; then
    echo "Deployment configuration not found: $config_file" >&2
    echo "Copy .deploy.env.example to .deploy.env and configure it." >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$config_file"

required=(DEPLOY_HOST DEPLOY_USER)
for variable in "${required[@]}"; do
    if [[ -z "${!variable:-}" ]]; then
        echo "Missing required setting: $variable" >&2
        exit 1
    fi
done

case "$target" in
    stage) remote_dir_variable=DEPLOY_STAGE_DIR ;;
    prod) remote_dir_variable=DEPLOY_PROD_DIR ;;
esac

if [[ -z "${!remote_dir_variable:-}" ]]; then
    echo "Missing required setting: $remote_dir_variable" >&2
    exit 1
fi
remote_dir=${!remote_dir_variable}

expected_prefix="/home/${DEPLOY_USER}/"
if [[ "$remote_dir" != "$expected_prefix"* || "$remote_dir" == "$expected_prefix" ]]; then
    echo "Refusing unsafe remote directory: $remote_dir" >&2
    echo "DreamHost paths must be below $expected_prefix" >&2
    exit 1
fi

for command in rsync ssh; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Required command not found: $command" >&2
        exit 1
    fi
done

if [[ ! -d "$theme_dir" ]]; then
    echo "Theme directory not found: $theme_dir" >&2
    exit 1
fi

destination_host="${DEPLOY_USER}@${DEPLOY_HOST}"
remote_theme_dir="${remote_dir%/}/wp-content/themes/dougforar"
printf -v remote_check 'test -f %q && test -d %q' \
    "${remote_dir%/}/wp-config.php" "${remote_dir%/}/wp-content/themes"

if ! ssh -x "$destination_host" "$remote_check"; then
    echo "Refusing to deploy: $remote_dir is not an existing WordPress installation." >&2
    exit 1
fi

if [[ "$target" == "prod" && ${#dry_run[@]} -eq 0 ]]; then
    echo
    read -r -p "Deploy the custom theme to production at $destination_host:$remote_theme_dir/? [y/N] " answer
    case "$answer" in
        y|Y|yes|YES) ;;
        *) echo "Deployment canceled."; exit 1 ;;
    esac
fi

echo
echo "Syncing the custom theme to $destination_host:$remote_theme_dir/"
rsync \
    -avhc \
    -e 'ssh -x' \
    --delete \
    --itemize-changes \
    --exclude='/.DS_Store' \
    --exclude='/content/' \
    "${dry_run[@]}" \
    "$theme_dir/" \
    "$destination_host:$remote_theme_dir/"

if [[ ${#dry_run[@]} -gt 0 ]]; then
    echo "Dry run complete. No remote files were changed."
else
    echo "Theme deployment complete."
fi
