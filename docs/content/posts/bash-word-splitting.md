---
date: 2023-02-07T17:26:32-03:00
description: The number one source of bugs in shell scripting
draft: false
tags: ["bash"]
title: "Bash word splitting"
---

## The problem

The code examples below make my eyes bleed, and if you don't see it, read on --
or stop writing Bash.

```bash
for f in $(ls *.mp3); do
    rm -rf "$f"
done
```

```bash
for f in $(find -name '*.mp3'); do
    rm -rf $f
done
```

We will go over what's wrong with such code, but before, we need to understand
Bash a little better.

## How bash executes commands

### The argument vector and `execve`

At its core, Bash is simply a command executor. You tell Bash the name of a
command and give it a few arguments. A simplified form of a [simple command] is:

```bash
command argument argument argument
```

Bash's job is to take this information and transform it into the [`execve`]
[system call], which has the following signature:

```c
#include <unistd.h>
int execve(const char *pathname, char *const argv[], char *const envp[]);
```

Which in practice looks like this when Bash calls it (super simplified!):

```c
execve("/path/to/command", ["argument", "argument", "argument"], env)
```

So, for example, when you run this command:

```bash
cat file1 file2 file3
```

Internally, Bash runs this C function:

```C
execve("/bin/cat", ["file1", "file2", "file3"], ...)
```

### Shell expansions

Each and every word that you give to Bash _might_ be expanded and modified.
By "word" I mean the command name _and_ the arguments!

Consider the following:

```bash
filename=myfile.txt
cat $filename  # Parameter expansion
```

In this case, Bash will perform [parameter expansion] before invoking the system
call. This means that Bash, quite literally, replaces `$filename` by
`myfile.txt`, so that the system call looks like this:

```c
execve("/bin/cat", ["myfile.txt"], ...)
```

In fact, before executing the system call, Bash _might_ manipulate the argument
array in 8 ways! These are called [shell expansions]:

\#| Expansion type                  | Example
--| --------------------------------|---------
1 | Brace Expansion                 | `a{b,c} → ab ac`
2 | Tilde Expansion                 | `~/projects → /home/lucas/projects`
3 | Shell Parameter Expansion       | `$filename → myfile.txt`
4 | Command Substitution            | `$(echo hello) → hello`
5 | Arithmetic Expansion            | `$((1+1)) → 2`
6 | Process Substitution            | `<(ls) → /tmp/file`
7 | **Word Splitting**              | Read on for examples.
8 | Filename Expansion              | `*.mp3 → ["Stairway to heaven.mp3", "How deep is your love.mp3", "Levels.mp3"]`

I'm sorry, but knowing the above list by heart is mandatory for every serious
Bash programmer. But worry not, the most important thing to know is:

## Word splitting is number 7

> The shell treats each character of $IFS as a delimiter, and splits the results
> of the other expansions into words using these characters as field
> terminators.

In other words, Bash splits each argument when it finds any of the IFS (Internal
Field Separator) characters in it.

By default, the IFS consists of the usual "blank" characters":

- Tabs
- New lines
- White spaces

Out of these, white spaces are by far the most common. They can, and they _will_
appear in file names, paths, and in all sorts of unexpected places.

The fact that word split happens after 6 other substitutions is the cause of
much suffering in this world.

### Word splitting in action

Let's say you wanted to check the permissions of a file using the `ls -l`
command:

```bash
$ myfile='Stairway to heaven.mp3'
$ ls -l $myfile
ls: heaven.mp3: No such file or directory
ls: stairway: No such file or directory
ls: to: No such file or directory
```

That did not do what we wanted. What is going on?

Internally, the following expansions are performed to the argument `$myfile`:

```c
["-l", "$myfile"]  // Initially parsed word
["-l", "Stairway to heaven.mp3"]  // After parameter expansion
["-l", "Stairway", "to", "heaven.mp3"]  // After word splitting

// And the (extremely simplified version of the) system call
execve("/bin/ls", ["-l", "Stairway", "to", "heave.mp3"]);
```

We asked Bash to run the `ls` command with the single positional argument
`$myfile`, but instead, 3 arguments were passed. Unsuspectingly, we had white
spaces in the value of the variable `$myfile`, and because parameter
substitution happens _before_ word splitting the substituted value got split
into words.

## Doing things the right way

### Quoting for the win

More often than not _we do not want word splitting to happen!_ Hence, you
should get in the habit of double quoting your variables. Double quotes prevent
word splitting altogether, while still allowing:

3. Parameter expansion
4. Command substitution
5. Arithmetic expansion

i.e. the `$` sign retains its special powers.

Let's go back to the example where we wanted to use `ls -l` to check the
permissions of a file. Using double quotes we get the correct result:

```bash
$ myfile='Stairway to heaven.mp3'
$ ls -l "$myfile"  # notice the quotes here
-rw-r--r--  1 lviana  lviana  0 Mar 13 13:42 Stairway to heaven.mp3
```

### Globbing vs. word splitting

The one expansion that happens _after_ word splitting is file name expansion.
This is easy to remember. So this will always do the right thing, independently
of whether or not file names have spaces.

```bash
$ ls -l *
```

The implication is deep. This will also work as god intended:

```bash
for f in *.mp3; do
    echo "$f"
done
```

And that, ladies and gentlemen, is the best way to iterate through the files
in a directory.

No need to `$(ls *.mp3)`, or `$(find -name '*.mp3')`. Those are wasteful because
they need to create 2 new processes, search through the path, etc. All you need
is the good old, built-in glob.

## When is word splitting good?

The short answer is -- almost never.

The longer answer involves a little historical background. The reason word
splitting even exists is that arrays did not exist on the original
Bourne Shell, and still don't exist in strictly POSIX-compliant shells. In these
shells, to iterate through things some trickery was needed, so they devised word
splitting.

Nowadays, though, Bash is ubiquitous in Linux systems, and macOS has Zsh by
default, which actually does not apply word splitting to parameter expansions at
all! And by the way, if you're on macOS, do yourself a favor and install Bash.

Talking about macOS, it comes with the (utterly broken version of) `getopt`
argument parsing utility. On its _man_ page, you have this recommendation:

```bash
$ args=`getopt abo: $*`
...
$ set -- $args
```

And there you see the unquoted `$args`! This is exactly what makes the `getopt`
utility so broken: it relies on word splitting.

So don't use `getopt` (use `getopts` instead), and don't rely on word splitting.
Even if you need POSIX compliance.

[simple command]: https://www.gnu.org/software/bash/manual/html_node/Simple-Commands.html
[`execve`]: https://man7.org/linux/man-pages/man2/execve.2.html
[system call]: https://man7.org/linux/man-pages/man2/syscalls.2.html
[parameter expansion]: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
[shell expansions]: https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html
