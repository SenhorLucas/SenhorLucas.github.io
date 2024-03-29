---
date: 2022-07-05T16:36:48+01:00
draft: false
tags: ["GNU", "sed", "command-line", "tools", "coreutils"]
title: "Learn `sed` and be happy"
---
When you're done reading this article, you'll be ready to become a `sed`
expert. Yes, you read it right -- So let's hit the ground running.


What is `sed`?
--------------

Ever wanted to edit a file without having to open it in a text editor? Or maybe
you want to modify several files and don't want to do it manually?

With `sed`, you just issue a short command in the terminal and bam!, you've
changed the contents of a file. You can see it as `CTRL+R` on super steroyds.
`sed` is capable of doing simple search and replace (regex based), delete lines,
add lines or even reverse the lines of a file.

FYI: I've been using the word "file" here, and that includes `stdin` and
`stderr`.


The simples usage
-----------------

Those that have used `sed` before might be familiar with this command, which
is a regex based text replacement. It replaces "hello" by "world":

```bash
$ echo 'hello world' | sed 's/hello/world/'
world world
```

Or clearing all lines that start with a `#` (in a horrendous way!):

```sh
$ cat input.txt | sed 's/^#.*//'
```

We should not get satisfied with this! `sed` can do so much more. Only knowing
how to "search-and-replace" with `sed` is like owning a Ferrari but never taking
it to the racetrack.

So let's take a step back and look at the anatomy of a `sed` expression. It will
be dense reading, but bear with me, it will be totally worth it.


## Expressions

`sed` expressions take the following form:

```text
[address]command[options]
```

- `address`: An optional filter which lines to apply the `command` to.
- `command`: a mandatory _single letter_ to specify what to do to the selected
  lines.
- `options`: Optional. Each command has its own options, which can look quite
  different.

Looking back at our initial example:

```text
  ` s/hello/world/g`
   ^^\____________/
   ||      ^
   ||      |
   ||      +- Options of command `s`
   |+- Signle letter command `s` that means substitute
   +- Address: No address given, fine, it's optional
```

Here we can see that the `s/hello/world` expression ommits the `address`, uses
the `s` command with `/hello/world` as `options`.

What the heck is an `address` though?


## Address

The address itself has its own general syntax:

```text
addr1[,addr2][!]
```

Where `addr` can be either a line number or a regular expression, and the
optional `!` (bang) reverses the meaning ;)

Examples using line numbers:

address | meaning
--------|--------
`1`| Matches only line number 1
`54`| Matches only line number 54
`1,5`| Matches lines from 1 to 5 (included)
`1,5!`| Match all lines that are not from 1 to 5

Examples using regular expressions:

address | meaning
--------|--------
`/abc/` | Matches lines containing "abc".
`\ra*r` | Matches lines containing "abc". Instead of marking the regular expression with `/<regex>/` it uses `\r<regex>r`, where `r` can be any character.
`/abc/!` | Matches lines that do not contain "abc".

Mixed examples:

address | meaning
--------|--------
`/abc/,2`| Matches a line containing "abc" and the next 2 lines
`2,/abc/`| Matches the second line until a line containing "abc"

### Pimp up the `s` command with addresses

Now you should know what this will do:

```sh
sed '2,4s/hello/world'
```

Yep, it will substitute "hello" by "world" from lines 2 to 4. You can go bananas
combining the addresses, with the `s` command.

Tip: use the `!` for extra points with your peers -- this is _barely_
documented. I don't know why the `man` pages don't make it clearly. Ugh!


## Command

There are quite a lot of commands to familiarize yourself with. All of them are
a single character, sometimes followed by a `\\`. Here are some useful commands
to try out:

### `s`

    s/regex/replacement/flags

This is the most useful and most known `sed` command. It is also the one with
the most options.

You can refer to [the `sed`
manual](https://www.gnu.org/software/sed/manual/sed.html#The-_0022s_0022-Command)
for detailed explanations on all flags. Here I will mention some useful tips for
the `s` command:

#### 1. Use groups and references

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

#### 2. `g`: Apply to all occurences in each line
More often than not, this is what you want. So your expression will usually
looke like this:

```sed
s/search/replace/g
```

#### 3. `i`: Case insensitive

### `d`

```sed
1,5d
```

Delete lines that were matched by the `address`. See how addresses can be super
useful?

### `p`

```bash
sed -n '1,5p'
```

Only print lines from 1 to 5. The `-n` flag tells `sed` to not print anything by
default.

### `n`

Fast-forward one line. You'll understand that in the [next chapter]({{< ref "#internals" >}})

```sed
n;n;s/a/b/
```

This command fast replaces "a" by "b" every third line.


## Internal workings of `sed`  {#internals}

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

```text
cycle (line)    | command           | pattern  | hold     | output
----------------|-------------------|----------|----------|---------
1               | read one line     | line 1   |          |
1               | 1h                | line 1   | line 1   |
1               | 1d (end cycle)    |          | line 1   |
1 - end         | print pattern     |          | line 1   | <blank>
2               | read one line     | line 2   | line 1   |
2               | 1h;1d;4p;4g       | line 2   | line 1   |
2 - end         | print pattern     | line 2   | line 1   | line 2\n
3               | read one line     | line 3   | line 1   |
3               | 1h;1d;4p;4g       | line 3   | line 1   |
3 - end         | print pattern     | line 3   | line 1   | line 3\n
4               | read one line     | line 4   | line 1   |
4               | 1h;1d             | line 4   | line 1   |
4               | 4p                | line 4   | line 1   | line 4\n
4               | 4g                | line 1   | line 1   |
1 - end         | print pattern     | line 1   | line 1   | line 1\n
5               | read one line     | line 5   | line 1   |
5               | 1h;1d;4p;4g       | line 5   | line 1   |
5 - end         | print pattern     | line 5   | line 1   | line 5\n
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
