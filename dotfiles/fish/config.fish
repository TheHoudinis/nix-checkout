# Keep Fish quiet when a new terminal opens.
set -g fish_greeting

# Prefer the current user-installed Spicetify release.
if test -d "$HOME/.spicetify"
    fish_add_path --prepend "$HOME/.spicetify"
end

# Read colours from Caelestia's live palette. This is called by the prompt, so
# a wallpaper or scheme change is reflected without restarting Fish.
function __caelestia_colour --argument-names key fallback
    set -l palette "$HOME/.config/hypr/scheme/current.lua"
    set -l line

    if test -r "$palette"
        set line (string match -r "^[[:space:]]*$key = \"[[:xdigit:]]{6}\"," < "$palette")
    end

    if test -n "$line"
        string replace -r '.*"([[:xdigit:]]{6})".*' '$1' -- "$line"
    else
        echo "$fallback"
    end
end

function __caelestia_apply_fish_theme
    set -g __caelestia_primary (__caelestia_colour primary 7aa2f7)
    set -g __caelestia_secondary (__caelestia_colour secondary bb9af7)
    set -g __caelestia_tertiary (__caelestia_colour tertiary 7dcfff)
    set -g __caelestia_text (__caelestia_colour onSurface c0caf5)
    set -g __caelestia_muted (__caelestia_colour onSurfaceVariant 9aa5ce)
    set -g __caelestia_outline (__caelestia_colour outline 565f89)
    set -g __caelestia_surface (__caelestia_colour surfaceContainerHighest 24283b)
    set -g __caelestia_error (__caelestia_colour error f7768e)
    set -g __caelestia_green (__caelestia_colour green 9ece6a)

    set -g fish_color_normal $__caelestia_text
    set -g fish_color_command $__caelestia_primary
    set -g fish_color_keyword $__caelestia_secondary
    set -g fish_color_quote $__caelestia_green
    set -g fish_color_redirection $__caelestia_tertiary
    set -g fish_color_end $__caelestia_secondary
    set -g fish_color_error $__caelestia_error
    set -g fish_color_param $__caelestia_text
    set -g fish_color_comment $__caelestia_outline
    set -g fish_color_operator $__caelestia_secondary
    set -g fish_color_escape $__caelestia_tertiary
    set -g fish_color_autosuggestion $__caelestia_outline
    set -g fish_color_selection $__caelestia_text --background=$__caelestia_surface
    set -g fish_color_search_match $__caelestia_text --background=$__caelestia_surface
    set -g fish_color_cwd $__caelestia_primary
    set -g fish_color_user $__caelestia_primary
end

__caelestia_apply_fish_theme
