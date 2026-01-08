function _fzf_search_git_branch -d "Select a git branch using fzf and insert it at cursor"
    # Check if we're in a git repository
    if not git rev-parse --git-dir &>/dev/null
        printf "\n%s\n" "Not in a git repository" >&2
        commandline --function repaint
        return 1
    end

    # Get all branches initially
    set -l branches (_fzf_list_git_branches all)

    if test -z "$branches"
        printf "\n%s\n" "No branches found" >&2
        commandline --function repaint
        return 1
    end

    # Set up fzf options with reload bindings for filtering
    set -l fzf_opts \
        --ansi \
        --height=80% \
        --reverse \
        --no-hscroll \
        --border=rounded \
        --border-label=" Git Branches " \
        --preview="_fzf_preview_git_branch {}" \
        --preview-window=right:60%:wrap \
        --prompt="All> " \
        --header="Filter: ctrl-l (local) | ctrl-r (remote)
        ctrl-a (all)
More info: ctrl-o" \
        --bind="ctrl-l:reload(_fzf_list_git_branches local)+change-prompt(Local> )" \
        --bind="ctrl-r:reload(_fzf_list_git_branches remote)+change-prompt(Remote> )" \
        --bind="ctrl-a:reload(_fzf_list_git_branches all)+change-prompt(All> )" \
        --bind="ctrl-o:execute(_fzf_show_git_branch {} | less -R)"

    # Apply custom options if set
    if set --query fzf_git_branch_opts
        set fzf_opts $fzf_opts $fzf_git_branch_opts
    end

    # Launch fzf and get selection
    set -l selected (printf "%s\n" $branches | fzf $fzf_opts)

    # Always repaint to restore the command line
    commandline --function repaint

    # If a branch was selected, insert it at cursor position
    if test -n "$selected"
        commandline --insert -- $selected
    end
end
