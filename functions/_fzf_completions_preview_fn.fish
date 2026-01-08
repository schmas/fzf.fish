function _fzf_completions_preview_fn -d "Preview the function definition"
    if type -q bat
        type $fzf_completions_candidate | bat --color=always --language fish $fzf_completions_bat_opts
    else
        type $fzf_completions_candidate
    end
end
