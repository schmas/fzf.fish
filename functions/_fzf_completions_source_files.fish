function _fzf_completions_source_files -d "Return a command to recursively find files"
    set -l path (_fzf_completions_path_to_complete | string escape)
    set -l hidden (string match "*." "$path")

    if string match --quiet -- '~*' "$fzf_completions_query"
        set -e fzf_completions_query
    end

    # Sort function: hidden files/folders last
    set -l sort_cmd "awk '{if (\$0 ~ /^\\./ || \$0 ~ /\\/\\./) print \"1\" \$0; else print \"0\" \$0}' | sort -V | cut -c2-"

    if type -q fd
        if _fzf_completions_test_version (fd --version) -ge "8.3.0"
            set fd_custom_opts --strip-cwd-prefix
        end

        # Add --hidden flag if user configured fzf_completions_show_hidden or path indicates hidden
        set -l hidden_flag
        if set -q fzf_completions_show_hidden; and test "$fzf_completions_show_hidden" = true
            set hidden_flag --hidden
        else if test -n "$hidden"; or test "$path" = "."
            set hidden_flag --hidden
        end

        # Build fd command with user options AFTER our base options so they take precedence
        if test "$path" = {$PWD}/
            echo "fd . --color=always $hidden_flag $fd_custom_opts $fzf_completions_fd_opts | $sort_cmd"
        else if test "$path" = "."
            echo "fd . --color=always $hidden_flag $fd_custom_opts $fzf_completions_fd_opts | $sort_cmd"
        else if test -n "$hidden"
            echo "fd . --color=always $hidden_flag -- $path $fzf_completions_fd_opts | $sort_cmd"
        else
            echo "fd . --color=always $hidden_flag -- $path $fzf_completions_fd_opts | $sort_cmd"
        end
    else if test -n "$hidden"
        # Use sed to strip cwd prefix
        echo "find . $path $fzf_completions_find_opts ! -path . -print 2>/dev/null | sed 's|^\./||' | $sort_cmd"
    else
        # Exclude hidden directories unless fzf_completions_show_hidden is enabled
        if set -q fzf_completions_show_hidden; and test "$fzf_completions_show_hidden" = true
            echo "find . $path $fzf_completions_find_opts ! -path . -print 2>/dev/null | sed 's|^\./||' | $sort_cmd"
        else
            echo "find . $path $fzf_completions_find_opts ! -path . ! -path '*/.*' -print 2>/dev/null | sed 's|^\./||'"
        end
    end
end
