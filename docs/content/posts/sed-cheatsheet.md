---
author: "Lucas Viana"
title: "`sed` cheatsheet"
date: 2022-07-05T16:36:48+01:00
tags: ["GNU", "sed", "command-line", "tools", "coreutils"]
showToc: true
draft: true
---

## Examples

## `sed` step by step execution


1. Read line from the input stream. A line is a sequence of characters ended by
   a newline `\n`.
2. Remove the trailing newline.
3. Store the line in the _pattern_ space.
4. Check if the line matches the `address`.
5. If matched, run the commands. The commands may change the contents of the
   _pattern_ and the _hold_ spaces.
6. Print out the content of the _pattern_ space.
7. Delete content of _pattern_ space, but keep the _hold_ space untouched.
8. Repeat.

## Command structure

`sed` is called with a *script* to process a stream.  The script is made of
*expressions*, and each *expression* has an *address*, a *command* and
*options*.

### Calling `sed`
General structure

    [other command] | sed [options] script [input-file]

Examples:

    echo 'hello world' | sed -e 's/d/d!/' -e 's/^h/H/'

TODO

### Script structure

Semi-colon or new-line separated expressions:

    'expression; expression
    expression'

Called with `-e` or `-f`:

    -e 'expression; expression' -e 'expression'
    -f myscript.sed

### Expression structure

    [address]command[options]

- `address`: filter lines to apply command on
- `command`: single letter command (e.g. `s`)
- `options`: command specific options


### The `s` command
Example:
```text
    s/\(hello \)\(world \)/\2\1/
          |        |        | |
          |        |        | +-> \1: reference to group 1
          |        |        +---> \2: referebce to group 2
          |        +------------> \(world\): group 2
          +---------------------> \(hello\): group 1
```

### address
Addresses select which lines the expression to. Can be either `/regex/` or
`nr`.

    addr1[,addr2][!]

- `addr1`: if match, apply command to the current line
- `addr2`: if present, select lines between `addr1` and `addr2`
- `!`: Invert address selection result

Examples:

address     | meaning
------------|--------
1,2d        | delete lines 1 and 2
55d         | delete line 55
/[a-z]/p    | print lines that contain lower-case characters


## Command

There are quite a lot of commands to familiarize yourself with. All of them are
a single character, sometimes followed by a `\\`. Here are some useful commands
to try out:

### `s`


This is the most useful and most known `sed` command. It is also the one with
the most options.

You can refer to [the `sed`
manual](https://www.gnu.org/software/sed/manual/sed.html#The-_0022s_0022-Command)
for detailed explanations on all flags. Here I will mention some useful tips for
the `s` command:

1. Use groups and references

```
    s/\(hello \)\(world \)/\2\1/
          |        |        | |
          |        |        | +-> \1: reference to group 1
          |        |        +---> \2: referebce to group 2
          |        +------------> \(world\): group 2
          +---------------------> \(hello\): group 1
```

   This example swaps around the words "hello" and "world"

   Groups are created by surrounding parts of your regular expression with
   escaped parenthesis `\( \)`. Then in the `replacement` you can refer to a
   group using `\1` syntax.

2. `g`: Apply to all occurences in each line

3. `i`: Case insensitive

### `d`

    1,5d

Delete lines that were matched by the `address`. See how addresses can be super
useful?

### `p`

    sed -n '1,5p'

Only print lines from 1 to 5. The `-n` flag tells `sed` to not print anything by
default.

### `n`

Fast-forward one line

    n;n;s/a/b/

This command fast replaces "a" by "b" every third line.


## Internal workings of `sed`

Understanding what `sed` does under the hood will take your `sed`itious work to
the next level!

First, accept this fact: `sed` has 2 buffers:
- pattern space
- hold space

Those are simply "variables" that hold some information.

Also accept that `sed` runs in cycles. Each cycle does this:
1. Read line from the input stream. A line is a sequence of characters ended by
   a newline `\n`.
2. Remove the trailing newline.
3. Store the line in the _pattern_ space.
4. Check if the line matches the `address`.
5. If matched, run the commands. The commands may change the contents of the
   _pattern_ and the _hold_ spaces.
6. Print out the content of the _pattern_ space.
7. Delete content of _pattern_ space, but keep the _hold_ space untouched.
8. Repeat.


### `g` and `h` options

Say we have a simple imput and want to shuffle the lines as follows:

```
input           result
----------------------
line 1          line 2
line 2          line 3
line 3  ---->   line 4
line 4          line 1
line 5          line 5
```

We want to cut out `line 1` and paste it after `line 4`. Easy.

    cat input.txt > sed '1h;1d;4p;4g'

Internally, `sed` will perform the following operations:

```
cycle (line)    | command         | pattern  | hold     | output
----------------+-----------------+----------+----------+---------
1               | read one line   | line 1   |          |
1               | 1h              | line 1   | line 1   |
1               | 1d (end cycle)  |          | line 1   |
end 1           | print pattern   |          | line 1   | <blank>
2               | read one line   | line 2   | line 1   |
2               | 1h;1d;4p;4g     | line 2   | line 1   |
end 2           | print pattern   | line 2   | line 1   | line 2\n
3               | read one line   | line 3   | line 1   |
3               | 1h;1d;4p;4g     | line 3   | line 1   |
end 3           | print pattern   | line 3   | line 1   | line 3\n
4               | read one line   | line 4   | line 1   |
4               | 1h;1d           | line 4   | line 1   |
4               | 4p              | line 4   | line 1   | line 4\n
4               | 4g              | line 1   | line 1   |
end 1           | print pattern   | line 1   | line 1   | line 1\n
5               | read one line   | line 5   | line 1   |
5               | 1h;1d;4p;4g     | line 5   | line 1   |
end 5           | print pattern   | line 5   | line 1   | line 5\n
```

In the step-by-step above we go through each line of input and each command that
is executed on them. The command `1h` stores the content of the first line in the
_hold_ space. In order to prevent `line 1\n` from being printed, we delete it
from the _pattern_ space with `1d`. This command also ignores the next commands
and immediately starts a new cycle.

When we reach the 4th cycle we replace the _pattern_ space with the contents of
_hold_ space. But before doing that we print out the initial content with `4p`.

Remember: read into _pattern_ space, operate, print out the _pattern_ space.
Simple.
