#!/bin/bash
OPTS_SPEC="\
${0##*/} [<options>] <pos1> <pos2>

some-command does foo and bar!

<pos1>    positional argument 1
<pos2>    positional argument 2
--
h,help    show the help

f,foo       some nifty option --foo
bar=      some cool option --bar with an argument
baz=arg   another cool option --baz with a named argument
qux?path  qux may take a path argument but has meaning by itself

An option group Header
C?        option C with an optional argument"

# Global variables representing the options
foo=false
bar=
baz=
qux=default-value

# The output from `git rev-parse --parseopt`, in case we need to parse twice,
# (e.g. when we have subcommands)
set_args=

# Positional arguments
pos1=
pos2=

parse_args() {
	set_args="$(echo "$OPTS_SPEC" | git rev-parse --parseopt -- "$@" || echo exit $?)"

	eval "$set_args"

	while (( $# > 2 )); do
		opt=$1
		shift
		echo "opt: $opt, $*"
		case "$opt" in
			-f|--foo) foo=true ;;
			--bar) bar=$1; shift ;;
			--baz) baz=$1; shift ;;
			# Optional value arguments are broken. Git does not inject an empty
			# argument for us to know whether or not an argument was passed.
			# Sad.
			--qux) [[ $1 ]] && qux=$1 && shift ;;
		esac
	done

	pos1=$1
	pos2=$2

	if [[ -z $pos1 ]] || [[ -z $pos2 ]]; then
		echo "Positional parameters are required"
		exit 1
	fi

}

main() {
	parse_args "$@"
	# do something
}

main "$@"

# ======== tests
_test() {
	local input=(--foo /file1 /file2)
	echo "=== Test 1: ${input[*]}"
	parse_args "${input[@]}"
	echo "foo=$foo pos1=$pos1 pos2=$pos2"


	input=(--foo --bar=barvalue --baz bazvalue --qux /file1 /file2)
	echo "=== Test 2: ${input[*]}"
	parse_args "${input[@]}"
	echo "foo=$foo pos1=$pos1 pos2=$pos2 bar=$bar baz=$baz qux=$qux"
}
