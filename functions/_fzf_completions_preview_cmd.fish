function _fzf_completions_preview_cmd -d "Open man page of the selected command"
    if type -q bat
        man $fzf_completions_candidate 2>/dev/null | bat --color=always --language man $fzf_completions_bat_opts
    else
        man $fzf_completions_candidate 2>/dev/null
    end
end
