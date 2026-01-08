function _fzf_completions_source_directories -d "Return a command to recursively find directories"
    if type -q fd
        set --local --export fzf_completions_fd_opts $fzf_completions_fd_opts -t d
        _fzf_completions_source_files
    else
        set --local --export fzf_completions_find_opts $fzf_completions_find_opts -type d
        _fzf_completions_source_files
    end
end
