function _fzf_completions_open_file -d "Open a file with the right tool depending on its type"
    set -l filepath "$fzf_completions_candidate"

    if test -n "$argv"
        set filepath "$argv"
    end

    set -q fzf_completions_editor || set -l fzf_completions_editor "$EDITOR"

    set -l file_type (_fzf_completions_file_type "$filepath")

    switch $file_type
        case txt json archive
            $fzf_completions_editor "$filepath"
        case image
            if type -q chafa
                chafa --watch $fzf_completions_chafa_opts "$filepath"
            else
                $fzf_completions_editor "$filepath"
            end
        case binary
            if type -q hexyl
                hexyl $fzf_completions_hexyl_opts "$filepath" | less --RAW-CONTROL-CHARS
            else
                $fzf_completions_editor "$filepath"
            end
    end
end
