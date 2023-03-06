#!/bin/bash
# This is an adjusted copy of the
# `/usr/share/doc/util-linux/exampes/getop-example.bash` that is present on
# my Ubuntu 22.04 installation

# Globals for the options
a=false
b=
c=default-value

# Globals for positional arguments
pos1=
pos2=

# Prints usage text. Spaces and tabs in indentation are intentional and serve
# a purpose.
usage() {
	cat <<-EOF
		${0##*/} [options] [--] <pos1> <pos2>

		OPTIONS
		  -a, --a-long              An 'a' option
		  -b, --b-long <value>      A \`b\` option, requires <value>
		  -c, --c-long [<value>]    \`c\` option, default <value> = default-value


		ARGUMENTS
		  <pos1>                    Pos1 description
		  <pos2>                    Pos2 description

	EOF
}

parse_opts() {
	local TEMP
	TEMP=$(getopt -o 'ab:c::' --long 'a-long,b-long:,c-long::' -n 'example.bash' -- "$@")
	if (($?)); then
		echo "Failed to parse options" >&2
		usage >&2
		exit 1
	fi

	# Note the quotes around "$TEMP": they are essential!
	echo "$TEMP"
	eval "set -- $TEMP"
	unset TEMP

	local opt
	while true; do
		# echo "Current array: $*"
		opt=$1
		shift
		case "$opt" in
			'-a'|'--a-long') a=true;;
			'-b'|'--b-long') b=$1; shift;;
			'-c'|'--c-long') [[ $1 ]] && c=$1; shift;;
			'--') break;;
			*) usage >&2; exit 1;;
		esac
	done

	pos1=$1
	pos2=$2

	if [[ -z $pos1 ]] || [[ -z $pos2 ]]; then
		echo "Positional arguments are required" >&2
		usage >&2
		exit 1
	fi

	echo "a=$a"
	echo "b=$b"
	echo "c=$c"
	echo "pos1=$pos1"
	echo "pos2=$pos2"
}

main() {
	parse_opts "$@"
	# Do something
}

main "$@"
