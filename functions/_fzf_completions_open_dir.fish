function _fzf_completions_open_dir
    if type -q broot
        broot --color=yes $fzf_completions_broot_opts $fzf_completions_candidate
    end
end
