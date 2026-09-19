#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

wp() {
    docker compose run --rm wp-cli "$@"
}

ensure_page() {
    local title="$1"
    local slug="$2"
    local content="$3"
    local page_id

    page_id="$(wp post list --post_type=page --name="$slug" --field=ID --format=ids)"
    if [[ -z "$page_id" ]]; then
        page_id="$(wp post create --post_type=page --post_status=publish \
            --post_title="$title" --post_name="$slug" --post_content="$content" \
            --porcelain)"
    fi

    printf '%s' "$page_id"
}

docker compose up -d wordpress

printf 'Waiting for WordPress files...\n'
until docker compose exec -T wordpress test -f /var/www/html/wp-config.php; do
    sleep 2
done

if ! wp core is-installed >/dev/null 2>&1; then
    wp core install \
        --url="http://localhost:${WP_PORT:-8080}" \
        --title="Doug Corbitt for Arkansas" \
        --admin_user=admin \
        --admin_password=local-development-only \
        --admin_email=dougcorbitt@arkansas54.net \
        --skip-email
fi

wp theme activate dougforar
wp option update blogdescription "Candidate for Arkansas State Representative, District 54"
wp option update timezone_string "America/Chicago"
wp option update permalink_structure "/%postname%/"
wp rewrite flush

for default_slug in hello-world sample-page; do
    default_id="$(wp post list --post_type=any --name="$default_slug" --field=ID --format=ids)"
    if [[ -n "$default_id" ]]; then
        wp post delete "$default_id" --force >/dev/null
    fi
done

home_content="$(<"$repo_root/wp-content/themes/dougforar/content/home.html")"
home_id="$(ensure_page "Home" "home" "$home_content")"
blog_id="$(ensure_page "Blog" "blog" "")"

priorities_content="$(<"$repo_root/wp-content/themes/dougforar/content/priorities.html")"
ensure_page "Priorities" "priorities" "$priorities_content" >/dev/null

privacy_content="$(<"$repo_root/wp-content/themes/dougforar/content/privacy-policy.html")"
privacy_id="$(ensure_page "Privacy Policy" "privacy-policy" "$privacy_content")"
wp post update "$privacy_id" --post_status=publish --post_content="$privacy_content" >/dev/null
wp option update wp_page_for_privacy_policy "$privacy_id"

district_content='<!-- wp:paragraph {"className":"dc-page-intro"} -->
<p class="dc-page-intro">Explore the official boundaries of Arkansas House District 54.</p>
<!-- /wp:paragraph -->
<!-- wp:group {"align":"wide","className":"dc-map-preview","layout":{"type":"default"}} -->
<div class="wp-block-group alignwide dc-map-preview"><!-- wp:image {"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="/wp-content/themes/dougforar/assets/images/arkansas-house-district-54-map-preview.jpg" alt="Official map of Arkansas House District 54 and the surrounding area"><figcaption class="wp-element-caption">House District 54 map adopted by the Arkansas Board of Apportionment on November 29, 2021.</figcaption></figure>
<!-- /wp:image --></div>
<!-- /wp:group -->
<!-- wp:heading {"level":2} --><h2 class="wp-block-heading">View the detailed map</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p>The official map includes county lines, highways, local roads, precincts, and neighboring House districts. Open the full-size file to zoom in or download a copy.</p><!-- /wp:paragraph -->
<!-- wp:buttons --><div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="/wp-content/themes/dougforar/assets/documents/arkansas-house-district-54-map-2021.pdf" target="_blank" rel="noopener" aria-label="Open full-size map, PDF, 9.6 MB, in a new tab">Open full-size map (PDF, 9.6 MB)</a></div>
<!-- /wp:button --></div><!-- /wp:buttons -->'
ensure_page "District 54" "district-54" "$district_content" >/dev/null

involved_content='<!-- wp:paragraph {"className":"dc-page-intro"} -->
<p class="dc-page-intro">Volunteer, request a yard sign, ask a question, or tell Doug what matters to your family.</p>
<!-- /wp:paragraph -->
<!-- wp:buttons --><div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="mailto:dougcorbitt@arkansas54.net">Email the campaign</a></div>
<!-- /wp:button --></div><!-- /wp:buttons -->
<!-- wp:heading {"level":2} --><h2 class="wp-block-heading">Contact</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p>Email <a href="mailto:dougcorbitt@arkansas54.net">dougcorbitt@arkansas54.net</a> or follow Doug on Facebook.</p><!-- /wp:paragraph -->'
ensure_page "Get Involved" "get-involved" "$involved_content" >/dev/null

donate_content='<!-- wp:paragraph {"className":"dc-page-intro"} -->
<p class="dc-page-intro">Doug is self-funding this campaign. If you would like to make a political contribution, Doug asks you to consider supporting these fellow Arkansas candidates.</p>
<!-- /wp:paragraph -->
<!-- wp:columns {"className":"dc-card-grid dc-donate-grid"} --><div class="wp-block-columns dc-card-grid dc-donate-grid">
<!-- wp:column --><div class="wp-block-column"><!-- wp:heading {"level":2} --><h2 class="wp-block-heading">Fred Love</h2><!-- /wp:heading --><!-- wp:paragraph --><p>Arkansas Governor</p><!-- /wp:paragraph --><!-- wp:buttons --><div class="wp-block-buttons"><!-- wp:button --><div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="https://secure.actblue.com/donate/fred-love-for-governor" target="_blank" rel="noopener" aria-label="Donate to Fred Love via ActBlue, opens in a new tab">Donate via ActBlue</a></div><!-- /wp:button --></div><!-- /wp:buttons --><!-- wp:paragraph {"className":"dc-campaign-site"} --><p class="dc-campaign-site"><a href="https://www.fredlove.com/" target="_blank" rel="noopener" aria-label="Visit the Fred Love campaign website, opens in a new tab">Visit campaign website</a></p><!-- /wp:paragraph --></div><!-- /wp:column -->
<!-- wp:column --><div class="wp-block-column"><!-- wp:heading {"level":2} --><h2 class="wp-block-heading">Kelly Grappe</h2><!-- /wp:heading --><!-- wp:paragraph --><p>Arkansas Secretary of State</p><!-- /wp:paragraph --><!-- wp:buttons --><div class="wp-block-buttons"><!-- wp:button --><div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="https://goodchange.app/donate/commi-h8" target="_blank" rel="noopener" aria-label="Donate to Kelly Grappe via GoodChange, opens in a new tab">Donate via GoodChange</a></div><!-- /wp:button --></div><!-- /wp:buttons --><!-- wp:paragraph {"className":"dc-campaign-site"} --><p class="dc-campaign-site"><a href="https://www.kellygrappe.com/" target="_blank" rel="noopener" aria-label="Visit the Kelly Grappe campaign website, opens in a new tab">Visit campaign website</a></p><!-- /wp:paragraph --></div><!-- /wp:column -->
<!-- wp:column --><div class="wp-block-column"><!-- wp:heading {"level":2} --><h2 class="wp-block-heading">Cynthia Nations</h2><!-- /wp:heading --><!-- wp:paragraph --><p>Arkansas House, District 55</p><!-- /wp:paragraph --><!-- wp:buttons --><div class="wp-block-buttons"><!-- wp:button --><div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="https://goodchange.app/donate/natio-nh" target="_blank" rel="noopener" aria-label="Donate to Cynthia Nations via GoodChange, opens in a new tab">Donate via GoodChange</a></div><!-- /wp:button --></div><!-- /wp:buttons --><!-- wp:paragraph {"className":"dc-campaign-site"} --><p class="dc-campaign-site"><a href="https://www.nationsforarkansas.com/" target="_blank" rel="noopener" aria-label="Visit the Cynthia Nations campaign website, opens in a new tab">Visit campaign website</a></p><!-- /wp:paragraph --></div><!-- /wp:column -->
<!-- wp:column --><div class="wp-block-column"><!-- wp:heading {"level":2} --><h2 class="wp-block-heading">Chris Jones</h2><!-- /wp:heading --><!-- wp:paragraph --><p>U.S. House, District 2</p><!-- /wp:paragraph --><!-- wp:buttons --><div class="wp-block-buttons"><!-- wp:button --><div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="https://goodchange.app/donate/suppo-co?mk=web-3" target="_blank" rel="noopener" aria-label="Donate to Chris Jones via GoodChange, opens in a new tab">Donate via GoodChange</a></div><!-- /wp:button --></div><!-- /wp:buttons --><!-- wp:paragraph {"className":"dc-campaign-site"} --><p class="dc-campaign-site"><a href="https://chrisjonesforcongress.com/" target="_blank" rel="noopener" aria-label="Visit the Chris Jones campaign website, opens in a new tab">Visit campaign website</a></p><!-- /wp:paragraph --></div><!-- /wp:column -->
<!-- wp:column --><div class="wp-block-column"><!-- wp:heading {"level":2} --><h2 class="wp-block-heading">Hallie Shoffner</h2><!-- /wp:heading --><!-- wp:paragraph --><p>U.S. Senate</p><!-- /wp:paragraph --><!-- wp:buttons --><div class="wp-block-buttons"><!-- wp:button --><div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="https://goodchange.app/donate/halli-gq?mk=website-7" target="_blank" rel="noopener" aria-label="Donate to Hallie Shoffner via GoodChange, opens in a new tab">Donate via GoodChange</a></div><!-- /wp:button --></div><!-- /wp:buttons --><!-- wp:paragraph {"className":"dc-campaign-site"} --><p class="dc-campaign-site"><a href="https://www.hallieshoffner.com/" target="_blank" rel="noopener" aria-label="Visit the Hallie Shoffner campaign website, opens in a new tab">Visit campaign website</a></p><!-- /wp:paragraph --></div><!-- /wp:column -->
</div><!-- /wp:columns -->'
donate_id="$(ensure_page "Donate" "donate" "$donate_content")"
wp post update "$donate_id" --post_content="$donate_content" >/dev/null

wp option update show_on_front page
wp option update page_on_front "$home_id"
wp option update page_for_posts "$blog_id"

if [[ -z "$(wp post list --post_type=post --name=local-preview-post --field=ID --format=ids)" ]]; then
    wp post create --post_status=publish --post_title="Local Preview Post" \
        --post_name=local-preview-post \
        --post_content='<p>This sample post is part of the local development environment and will not be deployed.</p>' \
        >/dev/null
fi

printf '\nLocal WordPress is ready at http://localhost:%s\n' "${WP_PORT:-8080}"
printf 'Admin: http://localhost:%s/wp-admin/ (admin / local-development-only)\n' "${WP_PORT:-8080}"
