Bash cheatsheet
===============

Quick reference guide to avoid googling things over and over again.
http://mywiki.wooledge.org/BashGuide
https://tldp.org/LDP/abs/html/refcards.html
https://devhints.io/bash


Parameters
----------

### Substitutions

`${FOO%suffix}`			Remove suffix
`${FOO#prefix}`			Remove prefix
`${FOO%%suffix}`		Remove long suffix
`${FOO##prefix}`		Remove long prefix
`${FOO/from/to}`		Replace first match
`${FOO//from/to}`		Replace all
`${FOO/%from/to}`		Replace suffix
`${FOO/#from/to}`		Replace prefix

Useful examples:

`STR="/path/to/foo.cpp"`
`echo ${STR%.cpp}`		/path/to/foo
`echo ${STR%.cpp}.o`	/path/to/foo.o
`echo ${STR%/*}`		/path/to
`echo ${STR##*.}`		cpp (extension)
`echo ${STR##*/}`		foo.cpp (basepath)
`echo ${STR#*/}`		path/to/foo.cpp
`echo ${STR##*/}`		foo.cpp
`echo ${STR/foo/bar}`# /path/to/bar.cpp


Tests
-----

Type | [ | [[ | Description
--- | --- | --- | ---
String comparison   | `\> \< = !=` | `> <  = (or ==) !=` | `[ a \< b ]` or `[[ a < b ]]`
Integer comparison  | `-gt -ge -lt -le -eq -ne` | same | `[ 5 -lt 10 ]` or `[[ 5 -lt 10]]`
Conditionals | `-a -o` | `&& \|\|` | `-a -o` are deprecated. `[[ -n $file && -f $file ]]`
Grouping | `\( ... \)` | `( ... )` | `[[ $file = img* && ( $file = *.png || $file = *.jpg) ]]`
Pattern matching | not available |  `= ==` | `[ $name = a\*de\* ]]`


### Tests supported by [ (also known as test) and [[:

`! EXPR`: Inverts the result of the expression (logical NOT).

Operations that are true if the file:
`-e FILE`: exists.
`-f FILE`: is a regular file.
`-d FILE`: is a directory.
`-h FILE`: is a symbolic link.
`-r FILE`: is readable by you.
`-s FILE`: file exists and is not empty.
`-w FILE`: is writable by you.
`-x FILE`: is executable by you.
`-O FILE`: is effectively owned by you.
`-G FILE`: is effectively owned by your group.

`-t FD `: True if FD is opened on a terminal.
`-p PIPE`: pipe exists.

`FILE -nt FILE`: the first file is newer than the second.
`FILE -ot FILE`: the first file is older than the second.

Operations that are true if the string:
`-z STRING`: is empty (its length is zero).
`-n STRING`: is not empty (its length is not zero).

`STRING = STRING`: is identical to the second.
`STRING != STRING`: is not identical to the second.
`STRING < STRING`: sorts before the second.
`STRING > STRING`: sorts after the second.

Numeric operators:
`INT -eq INT`: equal.
`INT -ne INT`: not equal.
`INT -lt INT`: less than.
`INT -gt INT`: greater than.
`INT -le INT`: less than or equal.
`INT -ge INT`: greatter than or equal.

### Additional tests supported *only by `[[`*:
`STRING = (or ==) PATTERN`: True if the string matches the glob pattern.
`STRING != PATTERN`: True if the string does not match the glob pattern.
`STRING =~ REGEX`: True if the string matches the regex pattern.
`( EXPR )`: Parentheses can be used to change the evaluation precedence.
`EXPR && EXPR`: Like the `-a` operator of `test`, but does not evaluate the second expression if the first already turns out to be false.
`EXPR || EXPR`: Like the `-o` operator of `test`, but does not evaluate the second expression if the first already turns out to be true.

### Tests *exclusive to `[` and `test`* (deprecated):
`EXPR -a EXPR`: both expressions are true (logical AND).
`EXPR -o EXPR`: either expression is true (logical OR).


Arrays
------

### Creation
`arr=()` | Create a empty array.
`arr=(1 2 3)` | Create and populate an array.
`arr=( $(echo *) )` | Create array based on command output.
`local -a arr` | Declare `arr` as a local array.

### Retrieving data
```bash
${arr[0]} # first element.
"${arr[@]}" # all elements, separate words.
"${arr[*]}" # all elements in a single word, separated by first character in IFS.
${!arr[@]} # all indexes.
${#arr[@]} # array size.
```

### Slicing
`"${arr[@]:0:2}"` | 2 elements from index 0.
`"${arr[@]:2}"` | All elements from index 2.

### Setting data
`arr[1]=2` | Modify element at index.
`arr+=(4 5 6)` | Append.

### Removing elements
`unset -v "arr[1]"` | Results in indexes 0 2 3 4 ... and assing NULL to element.

### Perfect insert / remove
Consider the deletion index i=2:
`arr=( "${arr[@]:0:$i" "new" "${arr[@]:$i} )` | add element to array.
`arr=( "${arr[@]:0:$(($i-1))" "${arr[@]:$i} )` | add element to array.


Logging
-------

### Colors

```bash
declare -r F_BOLD=$(tput bold)
declare -r F_RESET=$(tput sgr0)
declare -r F_RED=$(tput setaf 1)
declare -r F_GREEN=$(tput setaf 2)
declare -r F_BLUE=$(tput setaf 4)
declare -r F_MAGENTA=$(tput setaf 5)
declare -r ICON_START="$F_BOLD${F_BLUE}▸$F_RESET"
declare -r ICON_DONE="$F_BOLD${F_GREEN}✔$F_RESET"
declare -r ICON_ERROR="$F_BOLD${F_RED}✘$F_RESET"

log() { printf '%b%s%b: %s\n' "$F_MAGENTA" "${0##*/}" "$F_RESET" "$1"; }
log_error() { log "$ICON_ERROR $F_BOLD${F_RED}error$F_RESET: $1" 1>&2; }
_log_task() { log "$1 $F_BOLD$2$F_RESET"; }
log_start() { _log_task "$ICON_START" "$1"; }
log_done() { _log_task "$ICON_DONE" "Done"; }
```


CLI parsing
-----------

### Usage
```bash
usage() {
    cat <<-USAGE
	Short description.

	Usage: ${0##*/} [-h][-f] {cmd1|cmd2}

	Commands:
	  cmd1       Some command
	  cmd2       Some command

	Configuration:
	  Environemt variable 1:
	    ${ENV_VAR1[*]}
	USAGE
}
```

### Without argparse
```bash
main() {
    trap exit_trap INT TERM EXIT
    local -r cmd=$1
    if (($# != 1)); then log_error 'invalid usage'; usage; exit 2; fi
    case "$cmd" in
        build )     cmd_build;;
        test )      cmd_test;;
        * )         log_error "invalid command \`$cmd\`"; usage; exit 2;;
    esac
}

main "$@"
```


Looping
-------

### Looping over an array

```bash
array=(1 2 3)
for i in "${array[@]}"; do
done
```
