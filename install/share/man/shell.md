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


[posix]: http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html
[pattern]: http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_13
[case]: http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_13#tag_02_09_04_05
