function _fzf_completions_path_to_complete
    set -l token (string unescape -- $fzf_completions_token)
    if string match --regex --quiet -- '.*(\w|\.|/)+$' "$token"
        _fzf_completions_expand_tilde "$token"
    else
        echo {$PWD}/
    end
end
