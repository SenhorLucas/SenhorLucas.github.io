---
date: 2023-02-20T14:50:00+01:00
description: The best ways to parse arguments, and some script skeletons
draft: false
title: "Parsing command line arguments in Bash"
---

If you don't have a CLI option parser in your scripts, you don't have scripts,
you have childish cake recipes.

As a software developer, you are the product of the systems you've built to
assist you in your thinking. I've heard the following phrase somewhere, so I
won't take credit:

> We should minize the time spent getting in position to think.

Then we should be writing scripts that are capable of handling our use-cases
efficiently, without the constant need for us to go in and hack it up further.

## The goal

We want to write our Bash scripts so we can invoke them with a multitude of
input options, so the script does the work without us needing to open it in the
editor.

We also want scritps that we can simply `./call-it --help`. And quickly be
reminded of the syntax to invoke it.

## Parsing arguments

There are multiple ways of whipping together a command line argument parser for
shell scripts. None is quite on par with Python's `argparse` but that doesn't
mean we won't try!

All we want is to create user-friendly Bash scripts that can be run like this:

```bash
$ my-awedome-script -a --fast --file myfile.txt execute
```

## General form

From a bird's eye perspective, scripts have this general form:

```bash
$ script-name [<optional>] [--] [<positional>]
```

- `optional`: optional arguments, e.g. `-a`, `-abc`. `--some-flag`.
- `positional`: positional arguments for which the order matters.
- `--`: End of options. What follows this are positional arguments.

In other words, optional arguments need to be given with some kind of name, or
pre-defined identifier preceeded by one or two hyphens, whereas positional
arguments get their meaning from the order in which they appear.

## The world is messier, though

The world is much messier than that. Consider the following.

```sh
docker -D run -it ubuntu --rm
```

What this command does is not important, look only at how the arguments are
passed. This exemplifies a few things:

- There are short and long options (e.g. `-i` and `--rm`).
- Some program don't enforce that positional arguments come last (e.g.
  `ubuntu --rm`).
- Short options sometimes can be combined: `-i -t == -it`
- Some commands have subcommands, and both can have their on options (e.g.
  `docker -D` and `run -it --rm`, where `run` is a subcommand of `docker`).

Moreover, there are different styles of options out there:

```sh
ps aux
```

This is the BSD option style for the `ps` command, and the short options are
combined, but not preceeded by a hyphen. We will hapilly ignore this form,
unless, of course, we are running `ps`. Be advised, though that `ps` does
support the more usual hyphenated form, if you prefer.

## Positional arguments: pretty easy

Positional arguments are those that take their meaning from the order in which
they appear when calling a script, for example:

```bash
$ script arg1 arg2 arg3
# $0     $1   $2   $3
```

In Bash all arguments (optional or positional) can be accessed via the variables
`$0` through `$9`. If you have even more arguments you will need the curly
braces: `${10}`.

If your script has no optional arguments, the job is done:

```bash
#!/bin/bash
arg1=$1
arg2=$2
arg3=$3
...
```

## Optional arguments: the hard part

Due to the wild variety of ways available for passing optional arguments to a
script, implementing a parser can be as complex as you wish.

Here are a few suggestions in what is a pretty reasonable set of alternatives
to get us started:

```bash
1. script -a -b -c value   # Separated, single letters. Option -c has a `value`
2. script -abc             # Grouped. Equivalent to `-a -b -c`.
3. script -abc value       # Grouped. Equivalent to `-a -b -c value`.

4. script --long-option        # Long form option
5. script --long-option value  # Long form with value
6. script --long-option=value  # Long form with value
```

From now we slowly introduce ways of dealing with the above options.

## `getopts`

This is probably the best cost/benefit parsing tool available to Bash scripts.

Built-in command `getopts` is capable of skilfully parsing short-form optional
arguments, but it only supports short-style options.

The general boiler-plate code looks like this:

```bash
usage() {
	cat <<- EOF
		Usage: ${0##*/} [-abc] pos1 pos2

		    -a          description.
		    -b          description.
		    -c OUTFILE  description.
            -h          display this usage text.
		EOF
}

while getopts 'abc:h' opt; do
	case $opt in
		a) do-a;;
		b) do-b;;
		c) cvar=$OPTARG;;
        h) usage; exit 0;;
		\?) usage; exit 1;;
	esac
done
shift "$((OPTIND-1))"

pos1=$1
pos2=$2
```

The above shows that `getopts` takes a string argument telling it which options
are possible. So `getopt abc` would allow for the options `-a`, `-b` and `-c`.
In this string, if an argument ends with colon (`:`), then that option also
takes a value, e.g. `getopt a:b:` would allow for `-a value -b value`.

We run `getopt` in a loop, and in each iteration it reads the argument pointed
to by the `$OPTIND` variable, which starts at 1 (and that is extremely dumb,
since things should be zero indexed).

In each iteration the following variables are set by `getopts`:

- `$opt` is the name of the current option discovered by `getopts` (e.g. `a`)
- `$OPTARG` is the value of the option
- `$OPTIND` is the position of the option (more on that soon)

```text
$0     $1  $2 $3    $4   $5
script -ab -c value pos1 pos2
|       |   |   |
|       |   |   +-> OPTIND=4, opt=c, OPTARG=value
|       |   +-----> OPTIND=3, skipped
|       +---------> OPTIND=2, opt=a, opt=b
+-----------------> OPTIND=1, skipped
```

At each loop these are the values of the relevant parameters:

Loop | opt   | OPTARG  | OPTIND
-----|-------|---------|-------
1    | `a`   |         | 2
2    | `b`   |         | 2
3    | `c`   | `value` | 4

And finally, we terminate with `shift "$((OPTIND-1))"` to fix up the argument
array. This allows us to find the positional arguments.

```Bash
# After the `shift` operation the argument array looks like this:
$0                  $1   $2
script -ab -c value pos1 pos2
```

## Parsign manually

Using `getopts` is pretty convenient, but also limiting since it does not
support long-form options and options with an optional value.

The following script shows how to manually parse arguments taking into account
several possibilities using `case` and other built-in Bash facilities.

```bash
# Adapted from Greg's Bash FAQ.
while :; do
    case $1 in
        # Handle options with values, short and long form
        -c|--create)
            if [[ $2 ]]; then
                create=$2
                shift
            else
                echo '`--create` argument is mandatory'; exit 1;
            fi
            ;;

        # Handle `=` as separator
        # Here we use parameter substitution e.g. ${varname#prefix-to-remove}
        --create=?*) create=${1#*=};;

        # Handle multiple verbose levels
        -v|--verbose) verbose=$((verbose + 1));;

        # Handle short and long forms without value
        -h|-\?|--help) show_help; exit;;

        # End of options
        --) shift; break;;

        # Unknown option, print a warning to stderr
        -?*) printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2;;

        # Default case, not an optional argument. Break out.
        *) break;;
    esac
    shift
done

[[ $create ]] || echo '`--create` argument is mandatory' && exit 1
```

## `git rev-parse`

An obscure, cryptically documented[^1], inaptly named, yet _good_ complementary
tool, is `git-rev-parse`. It does not do the entire job though. It only looks
though and _normalizes_ the argument list so you will have a much easier time
parsing the arguments using the manual method described in the previous section.

Let's start with the example give in the documentation:

```bash
#!/bin/bash
OPTS_SPEC="\
some-command [<options>] <args>...

some-command does foo and bar!
--
h,help    show the help

foo       some nifty option --foo
bar=      some cool option --bar with an argument
baz=arg   another cool option --baz with a named argument
qux?path  qux may take a path argument but has meaning by itself

An option group Header
C?        option C with an optional argument"

eval "$(echo "$OPTS_SPEC" | git rev-parse --parseopt -- "$@" || echo exit $?)"

print "$@"
```

The above demonstrates that things are done in 4 steps:

1. Create an _option parsing specification_ There you define how your options
   should be interpreted by `git-rev-parse`.
2. Pipe the option specification to `git-rev-parse` standard input, and give it
   `"$@"` as arguments.
3. `eval` the output of `git-rev-parse`.
4. You now have a brand new argument array (`"$@"`), with normalized arguments.

Let's examine each step carefully.


### 1. Option format specification

This command expects a "option format specification" in the standard input, and
the syntax for it is pretty straight forward, from the documentation:

```text
some-command [<options>] <args>...

some-command does foo and bar!
--
h,help    show the help

foo       some nifty option --foo
bar=      some cool option --bar with an argument
baz=arg   another cool option --baz with a named argument
qux?path  qux may take a path argument but has meaning by itself

An option group Header
C?        option C with an optional argument
```

It starts with a description of the command in free text format. The description
ends when a line containing `--` is found.

### 2. `git rev-parse --parseopt` Thai massage

All that `git rev-parse --parseopt` really does is to normalize the input
argument array. A normilized argument list is very easy to parse because:

- Positional arguments are easy to detect:
  - All non-option arguments (i.e. positional) are moved all the way to the
    right.
  - At the end of the options, there will aways be a `--` delimiter.

```bash
# This input
$ script -opt1 pos1 --opt2 pos2
# becomes
$ script --opt1 --opt2 -- pos1 pos2
```

- Optional arguments are nice and tidy:
  - Combined short-form arguments are split appart
  - Options with values are always space-separated (i.e. no `--opt=val`)

```bash
# This input
$ script -abcd -e value1 --bar pos1 --baz=value2
# Becomes
$ script -a -b -c -d -e value1 --bar --baz value2 -- pos1
```

- The `-h` and `--help` optional arguments are intercepted and help is printed
  on _standard output_ (i.e. not on _standard error_).
  In this case the command also reports the error code `129`, for _you_ to act
  upon.

- When wrong options are passed to the script, the help text is printed on
  _standard error_ andthe error code `129` is reported for _you_ to act upon.


### 3. `eval` the output

The "Thai massaged" output of `git rev-parse --parseopt` is, in fact a string
that can be `eval`d, and once that is done the argument array is reshuffled.

Without the eval you'd have this instead:

```bash
$ myscript --foo pos1 --bar value pos2
set -- --foo --bar 'value' -- 'pos1' 'pos2'
```

This `set` command gets printed, but it not executed. If we do execute it the
following happens

arguments | `$0`        | `$1`      | `$2`      | `$3`      | `$4`      | `$5`      | `$6`
----------|-------------|-----------|-----------|-----------|-----------|-----------|-----
before    | `myscript`  | `--foo`   | `pos1`    | `--bar`   | `value`   | `pos2`    |
after     | `myscript`  | `--foo`   | `--bar`   | `value`   | `--`      | `pos1`    | `pos2`

### 4. Now you're ready to start parsing ;)

Now, no matter how messy the input your user passed to the script was, you have
a nice and massaged argument array to work with. Simply use the manual parsing
method.

### A fully functional copy/paste example

```bash
#!/bin/bash
OPTS_SPEC="\
${0##*/} [<options>] [--] <pos1> <pos2>

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

```

## Another tool yet: `parseopt`, oh gosh!

The problem with `parseopt` is that there are 2 versions of the same program
out there, which is incredibly unfortunate.

`parseotp` is a Unix utility that breaks in many situations in modern shell
environments, where file names with white spaces are common places. So long
story short, avoid it if you can.

Then a group of Linux devs decided to fix the `parseopt` utility, and bundle it
in something called `util-linux`, making it available in all Linux systems.
But they didn't change the name :face-palm:!

Since we're concerning ourselves only with Bash in this post, and Bash runs on
MacOS and other non-Linux systems, it is impossible to _know for sure_ what
`parseopt` will do in the environment where it runs. What a bummer.

Fret not -- `parse opt` does more or less the same thing as
`git rev-parse --parseopt`, with the different that even the `util-linux` fixed
up version does a worse job. So if you really need some advanced option parsing,
use Git!

However, if you are no Linux, don't have Git available (I mean... nobody,
nowadays) you can see an example of `--parseopt` in action installed in your
system right now. head to `man parseopt` and scroll to the bottom to find the
location. On Ubuntu 22.04 it is
`/usr/share/doc/util-linux/examples/getopt-example.bash`.




[^1]: Someone has actually contacted the authors of the `git-rev-parse` man page
    asking for improvements to readbility and they answered: "I've read it
    again, what part don't you understand?"

    I'd say, well, I understand most of it, but it is so badly organized that
    it irks in me. Maybe I will be the one to fix it some day." I suspect that
    the documentaiton for `git-rev-parse` is the main reason behind the
    existence of the [Git man page generator].

    So when reading the `git-rev-parse` documentation jump straight to the
    _PARSEOPT_ section.


[Git man page generator]: git-man-page-generator.lokaltog.net
