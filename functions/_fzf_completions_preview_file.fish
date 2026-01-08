function _fzf_completions_preview_file -d "Preview the selected file with the right tool depending on its type"
    set -l file_type (_fzf_completions_file_type "$fzf_completions_candidate")

    switch $file_type
        case txt
            if type -q bat
                bat --color=always $fzf_completions_bat_opts "$fzf_completions_candidate"
            else
                cat "$fzf_completions_candidate"
            end
        case json
            if type -q bat
                bat --color=always -l json $fzf_completions_bat_opts "$fzf_completions_candidate"
            else
                cat "$fzf_completions_candidate"
            end
        case image pdf
            if type -q chafa
                chafa $fzf_completions_chafa_opts "$fzf_completions_candidate"
            else
                _fzf_completions_preview_file_default "$fzf_completions_candidate"
            end
        case archive
            if type -q 7z
                7z l ""$fzf_completions_candidate"" | tail -n +17 | awk '{ print $6 }'
            else
                _fzf_completions_preview_file_default "$fzf_completions_candidate"
            end
        case binary
            if type -q hexyl
                hexyl $fzf_completions_hexyl_opts "$fzf_completions_candidate"
            else
                _fzf_completions_preview_file_default "$fzf_completions_candidate"
            end

    end
end
