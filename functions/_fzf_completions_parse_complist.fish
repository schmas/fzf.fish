function _fzf_completions_parse_complist -d "Extract the first column of fish completion list"
    cat $_fzf_completions_complist_path \
        | string unescape \
        | uniq \
        | awk -F '\t' '{ print $1 }'
end
