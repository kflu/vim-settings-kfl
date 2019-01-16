# SHELL REFERENCE

* [POSIX doc][posix]
* [case command][case]
* [Shell pattern matching][pattern]

case
----------------------------------------------------------------------

    case word in
        [(]pattern1) compound-list;;
        [[(]pattern[ | pattern] ... ) compound-list;;] ...
        [[(]pattern[ | pattern] ... ) compound-list]
    esac


for
----------------------------------------------------------------------

    for i in "x" "y" "z"; do __; done
    for i in `seq 10`; do __; done


getopts
----------------------------------------------------------------------

    USAGE=$(cat <<EOF
    Usage:
        [-r <doc_root>] doc
    EOF
    )

    root="$HOME/install/share/man/"  # default $root
    while getopts 'r:h' opt; do  # getopts '<flags>:<default>' <arg_var>
        case "$opt" in
            r)
                root="$OPTARG";;
            h)
                echo "$USAGE" >&2; exit 0;;
        esac
    done

    # get positional arguments after parsing
    shift $((OPTIND-1))
    term="$1"


* `getopts 'a[:]...' <arg_var>`
    * character without `:` means flag
    * character with `:` mean option with argument
* `OPTARG`: argument for current option
* `OPTIND`: current option's index
* Use `exit` in scripts; `return` in functions
* refer to [tutorial][getopts] and [man][getopts_man]


shell redirection
----------------------------------------------------------------------

Redirect both stdout & stderr:

    ls foo > /dev/null 2>&1


Remarks:

`[x]>&[y]` copies file descriptor `y` to `x`. DON'T think of redirection, but copy.
Therefore, the redirection order matters:

`ls foo > /dev/null 2>&1` means:

1. `stdout <- /dev/null`
2. `stderr <- stdout`

So effectively:

    /dev/null == stdout == stderr



[posix]: http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html
[pattern]: http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_13
[case]: http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_13#tag_02_09_04_05
[getopts]: https://wiki.bash-hackers.org/howto/getopts_tutorial
[getopts_man]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/getopts.html
