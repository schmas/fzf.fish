function _fzf_completions_open_fn -d "Open a function definition using open file wrapper"
    set -l pathname (functions --details $fzf_completions_candidate 2>/dev/null)
    if test -f $pathname
        _fzf_completions_open_file $pathname
    end
end
