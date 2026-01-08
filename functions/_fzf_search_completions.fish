function _fzf_search_completions
    set -f --export SHELL (command --search fish)
    set -l result
    set -Ux _fzf_completions_extract_regex
    set -gx _fzf_completions_complist_path (string join '' (mktemp) "_fzf_completions")
    set -gx _fzf_completions_custom_fzf_opts
    set -gx fzf_completions_extracted
    set -gx fzf_completions_commandline
    set -gx fzf_completions_token (commandline --current-token)
    set -gx fzf_completions_query "$fzf_completions_token"

    # Get commandline buffer
    if test "$argv" = ""
        set fzf_completions_commandline (commandline --cut-at-cursor)
    else
        set fzf_completions_commandline $argv
    end

    if _fzf_completions_test_version "$FISH_VERSION" -ge "3.4"
        set complete_opts --escape
    end

    complete -C $complete_opts -- "$fzf_completions_commandline" | string split '\n' >$_fzf_completions_complist_path

    set -gx fzf_completions_group (_fzf_completions_completion_group)
    set source_cmd (_fzf_completions_action source)

    set fzf_completions_fzf_query (string trim --chars '\'' -- "$fzf_completions_fzf_query")

    set -l fzf_cmd "
        _fzf_completions_launched_by_fzf=1 SHELL=fish fzf \
            -d \t \
            --exact \
            --tiebreak=length \
            --select-1 \
            --exit-0 \
            --ansi \
            --tabstop=4 \
            --multi \
            --reverse \
            --header '$header' \
            --preview '_fzf_completions_action preview {} {q}' \
            --bind='$fzf_completions_open_keybinding:execute(_fzf_completions_action open {} {q} &> /dev/tty)' \
            --query '$fzf_completions_query' \
            $_fzf_completions_custom_fzf_opts"

    set -l cmd (string join -- " | " $source_cmd $fzf_cmd)
    # We use eval hack because wrapping source command
    # inside a function cause some delay before fzf to show up
    eval $cmd | while read -l token
        # don't escape '~' for path, `$` for environ
        if string match --quiet '~*' -- $token
            set -a result (string join -- "" "~" (string sub --start 2 -- $token | string escape))
        else if string match --quiet '$*' -- $token
            set -a result (string join -- "" "\$" (string sub --start 2 -- $token | string escape))
        else
            set -a result (string escape --no-quoted -- $token)
        end
        # Perform extraction if needed
        if test -n "$_fzf_completions_extract_regex"
            set result[-1] (string match --regex --groups-only -- "$_fzf_completions_extract_regex" "$token")
        end
    end

    # Add space trailing space only if:
    # - there is no trailing space already present
    # - Result is not a directory
    # We need to unescape $result for directory test as we escaped it before
    if test (count $result) -eq 1; and not test -d (string unescape -- $result[1])
        set -l buffer (string split -- "$fzf_completions_commandline" (commandline -b))
        if not string match -- ' *' "$buffer[2]"
            set -a result ''
        end
    end

    if test -n "$result"
        commandline --replace --current-token -- (string join -- ' ' $result)
    end

    commandline --function repaint

    rm $_fzf_completions_complist_path
    # Clean state
    set -e _fzf_completions_extract_regex
    set -e _fzf_completions_custom_fzf_opts
    set -e _fzf_completions_complist_path
    set -e fzf_completions_token
    set -e fzf_completions_group
    set -e fzf_completions_extracted
    set -e fzf_completions_candidate
    set -e fzf_completions_commandline
    set -e fzf_completions_query
end
