function _fzf_completions_expand_tilde
    string replace --regex -- '^~' "$HOME" $argv
end
