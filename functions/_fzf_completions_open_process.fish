function _fzf_completions_open_process -d "Open the tree view of the selected process (procs only)"
    set -l pid (_fzf_completions_parse_pid "$fzf_completions_candidate")

    if type -q procs
        procs --color=always --tree --pager=always $fzf_completions_procs_opts "$pid"
    end
end
