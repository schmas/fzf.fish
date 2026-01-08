# fzf.fish is only meant to be used in interactive mode. If not in interactive mode and not in CI, skip the config to speed up shell startup
if not status is-interactive && test "$CI" != true
    exit
end

# Because of scoping rules, to capture the shell variables exactly as they are, we must read
# them before even executing _fzf_search_variables. We use psub to store the
# variables' info in temporary files and pass in the filenames as arguments.
# This variable is global so that it can be referenced by fzf_configure_bindings and in tests
set --global _fzf_search_vars_command '_fzf_search_variables (set --show | psub) (set --names | psub)'


# Install the default bindings, which are mnemonic and minimally conflict with fish's preset bindings
fzf_configure_bindings

# Tab completion configuration - Private
set -gx _fzf_completions_comp_count 0
set -gx _fzf_completions_unordered_comp
set -gx _fzf_completions_ordered_comp

# Keybindings for tab completions
set -qU fzf_completions_keybinding
or set -U fzf_completions_keybinding \t

set -qU fzf_completions_open_keybinding
or set -U fzf_completions_open_keybinding ctrl-o

for mode in default insert
    bind --mode $mode \t _fzf_search_completions
    bind --mode $mode $fzf_completions_keybinding _fzf_search_completions
end

# Set sources rules
fzf_configure_completions \
    -n 'test "$fzf_completions_group" = "directories"' \
    -s _fzf_completions_source_directories
fzf_configure_completions \
    -n 'test "$fzf_completions_group" = "files"' \
    -s _fzf_completions_source_files
fzf_configure_completions \
    -n 'test "$fzf_completions_group" = processes' \
    -s 'ps -ax -o pid=,command='

# Load completions preview rules only when fish is launched fzf
if set -q _fzf_completions_launched_by_fzf
    # Builtin preview/open commands
    fzf_configure_completions \
        -n 'test "$fzf_completions_group" = "options"' \
        -p _fzf_completions_preview_opt \
        -o _fzf_completions_open_opt
    fzf_configure_completions \
        -n 'test \( -n "$fzf_completions_desc" -o -z "$fzf_completions_commandline" \); and type -q -f -- "$fzf_completions_candidate"' \
        -r '^(?!\\w+\\h+)' \
        -p _fzf_completions_preview_cmd \
        -o _fzf_completions_open_cmd
    fzf_configure_completions \
        -n 'test -n "$fzf_completions_desc" -o -z "$fzf_completions_commandline"' \
        -r '^(functions)?\\h+' \
        -p _fzf_completions_preview_fn \
        -o _fzf_completions_open_fn
    fzf_configure_completions \
        -n 'test -f "$fzf_completions_candidate"' \
        -p _fzf_completions_preview_file \
        -o _fzf_completions_open_file
    fzf_configure_completions \
        -n 'test -d "$fzf_completions_candidate"' \
        -p _fzf_completions_preview_dir \
        -o _fzf_completions_open_dir
    fzf_configure_completions \
        -n 'test "$fzf_completions_group" = processes -a (ps -p (_fzf_completions_parse_pid "$fzf_completions_candidate") &>/dev/null)' \
        -p _fzf_completions_preview_process \
        -o _fzf_completions_open_process \
        -e '^\\h*([0-9]+)'
end

# Doesn't erase autoloaded _fzf_* functions because they are not easily accessible once key bindings are erased
function _fzf_uninstall --on-event fzf_uninstall
    _fzf_uninstall_bindings

    set --erase _fzf_search_vars_command
    set --erase _fzf_completions_comp_count
    set --erase _fzf_completions_unordered_comp
    set --erase _fzf_completions_ordered_comp
    functions --erase _fzf_uninstall _fzf_migration_message _fzf_uninstall_bindings fzf_configure_bindings fzf_configure_completions
    complete --erase fzf_configure_bindings
    complete --erase fzf_configure_completions

    set_color cyan
    echo "fzf.fish uninstalled."
    echo "You may need to manually remove fzf_configure_bindings or fzf_configure_completions from your config.fish if you were using custom configurations."
    set_color normal
end
