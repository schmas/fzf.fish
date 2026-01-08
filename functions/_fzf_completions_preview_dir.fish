function _fzf_completions_preview_dir -d "List content of the selected directory"
    if type -q exa
        exa --color=always $fzf_completions_exa_opts $fzf_completions_candidate
    else
        ls --color=always $fzf_completions_ls_opts $fzf_completions_candidate
    end
end
