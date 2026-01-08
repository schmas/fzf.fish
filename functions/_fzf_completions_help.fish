function __fzf_completions_help_print
    argparse -s "i/indentation=?" "l/level=?" "c/color=?" e/escape n -- $argv
    set -l spaces "$_flag_i"
    set -l level "$_flag_l"
    set -l color "$_flag_c"
    set -l echo_opt

    if test -z "$spaces"
        set spaces 4
    end
    if test -z "$level"
        set level 1
    end
    if test -n "$_flag_e"
        set -a echo_opt -e
    end
    if test -n "$_flag_n"
        set -a echo_opt -n
    end
    if test -z "$_flag_c"
        set color -o white
    end
    set indent (string repeat --count (math $spaces x $level) " ")

    set_color $color
    echo $echo_opt "$indent$argv[1]"
    for line in $argv[2..-1]
        set_color $color
        echo $echo_opt "\n$indent$line"
    end
    # end
    set_color normal
end

function __fzf_completions_help_section
    __fzf_completions_help_print -e -l0 --color=yellow (string join -- "" (string upper -- "$argv") "\n")
end

function __fzf_completions_help_opt
    set -l opt (string split -- '=' $argv[1])
    __fzf_completions_help_print -n -e --color=green -l1 -- "$opt[1]"
    if test (count $opt) -eq 2
        set_color yellow
        echo "=$opt[2]"
    else
        echo ""
    end
    set -l desc (string split -- '\n' $argv[2..-1] | string trim)
    __fzf_completions_help_print -e -l2 -- $desc
    echo ""
end

function _fzf_completions_help -d "Print fzf_configure_completions help message"
    __fzf_completions_help_section NAME
    __fzf_completions_help_print -e "fzf_configure_completions - Set custom completion rules for use with fzf.fish completions\n"

    __fzf_completions_help_section SYNOPSIS
    __fzf_completions_help_print -e "fzf_configure_completions [OPTIONS]\n"

    __fzf_completions_help_section DESCRIPTION

    __fzf_completions_help_print -e -n \
        "The fzf_configure_completions command allows you to add custom completion rules that can enhance fish completions or override them.\n" \
        "A rule is composed of condition(s) that, if valid, trigger commands that can:" \
        "  - Change fzf preview (-p)" \
        "  - Feed fzf input (-s)" \
        "  - Execute when fzf_completions_open_keybinding is pressed (defaults to ctrl-o) (-o)"

    __fzf_completions_help_print -e "\n\n"

    __fzf_completions_help_print -e -n \
        "A condition can be either:" \
        " - A regex that must match commandline before cursor position (-r)" \
        " - An arbitrary command that must exit with a non-zero status (-n)"

    __fzf_completions_help_print -e "\n"

    __fzf_completions_help_print -e -n \
        "Rule are evaluated in the order in which they are defined," \
        "and fzf will stop at the first rule where all conditions are met"

    __fzf_completions_help_print -e "\n\n"

    __fzf_completions_help_opt \
        "-r, --regex=REGEX" \
        "Regex that must match commandline preceding the cursor for the rule to be valid"

    __fzf_completions_help_opt \
        "-e, --extract=COMMAND" \
        "Regex used to extract string from selected results before appending them to the commandline"

    __fzf_completions_help_opt \
        "-n, --condition=COMMAND" \
        "Command or function that must exit with a non-zero status for the rule to be valid"

    __fzf_completions_help_opt \
        "-p, --preview=COMMAND" \
        "Preview command passed to fzf if the rule is valid"

    __fzf_completions_help_opt \
        "-s, --source=COMMAND" \
        "Command that will feed fzf input if the rule is valid"

    __fzf_completions_help_opt \
        "-o, --open=COMMAND" \
        "Command binded to fzf_completions_open_keybinding (defaults to ctrl-o) when using fzf"

    __fzf_completions_help_opt \
        "-O, --order=INT" \
        "The order in which the rule is evaluated." \
        "If missing, the rule will be evaluated after all ordered ones, and all unordered rules defined before."

    __fzf_completions_help_opt \
        "-f, --fzf-options" \
        "Custom fzf options (can override previous ones)"

    __fzf_completions_help_opt \
        "-h, --help" \
        "Show this help"

    __fzf_completions_help_print -e "Examples:\n"

    __fzf_completions_help_print -e -l2 -- "- Preview files using bat (already builtin):\n"
    __fzf_completions_help_print -e -l2 --color=white -- \
        '  fzf_configure_completions -n \'test -f "$fzf_completions_candidate"\' -p "bat --color=always $fzf_completions_candidate"'

    __fzf_completions_help_print -e "\n"

    __fzf_completions_help_print -e -l2 -- "- Use fd to search files recursively (already builtin):\n"
    __fzf_completions_help_print -e -l2 --color=white -- \
        '  fzf_configure_completions -n \'test "$fzf_completions_group" = files\' -s \'fd . --color=always --strip-cwd-prefix\''

    __fzf_completions_help_print -e "\n"

    __fzf_completions_help_print -e -l2 -- "- Interactively search packages on archlinux:\n"
    __fzf_completions_help_print -e -n -l2 --color=white -- \
        " fzf_configure_completions \\" \
        " -r '^pacman(\h*\-S)?\h+\w+' \\" \
        " -s 'pacman --color=always -Ss "\$fzf_completions_token" | string match -r \"^[^\h+].*\"' \\" \
        " -e '.*/(.*?)\h.*' \\" \
        " -f '--query \"\"' \\" \
        " -p 'pacman -Si "\$fzf_completions_extracted"' \\ \n"
end
