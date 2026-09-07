<?php
/**
 * Theme setup.
 *
 * @package DougForArkansas
 */

declare(strict_types=1);

add_action(
    'wp_enqueue_scripts',
    static function (): void {
        wp_enqueue_style(
            'dougforar-style',
            get_stylesheet_uri(),
            array(),
            wp_get_theme()->get('Version')
        );
    }
);

add_action(
    'after_setup_theme',
    static function (): void {
        add_editor_style('style.css');
    }
);
