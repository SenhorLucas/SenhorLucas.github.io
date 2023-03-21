---
date: 2023-02-07T17:26:32-03:00
description: The number one source of bugs in shell scripting
draft: true
tags: ["bash"]
title: "Bash word splitting"
---

## The problem

```bash
for f in "$(ls *.mp3)"; do
    rm -rf "$f"
done
```

The code above makes my eyes bleed, and if you don't see it, read on -- or stop
writing Bash.

So what is so wrong with this code? Let's examine.

## Anatomy of a Bash command

At its core Bash is simply a command executor, i.e. it executes commands. You
tell Bash the name of a command (usually the name of a program to be executed)
and give it a few arguments. In simplified terms it looks like this:

```bash
command argument argument argument ...
```

Bash's job is to take this information and call the [`execve`] [system call],
which has the following signature:

```c
#include <unistd.h>
int execve(const char *pathname, char *const argv[], char *const envp[]);
```

Which would look more or less like this when Bash calls it:

```c
execve("/path/to/command", ["argument", "argument", "argument"], env)
```

Don't worry about the C syntax. This system call takes a path name, an array of
arguments and an array of environment variables.


Let's zoom into this array of arguments that Bash passes to `execve`. In the most
basic case, Bash does not do much for us:

```bash
cat myfile.txt
```

In the C side, the array of arguments looks like this:

```C
execve("/bin/cat", ["myfile.txt"], ...)
```

Nothing fancy. Bash simply takes the argument and forwards it to the system call
unchanged.

## Shell expansions

Now consider the following

```bash
filename=myfile.txt
cat $filename  # Parameter expansion
```

In this case Bash will perform [parameter expansion] before doing the system
call.  and the result would still like this:

```c
execve("/bin/cat", ["myfile.txt"], ...)
```

In fact, before executing the system call, Bash manipulates the argument array in
9 ways! These are called [shell expansions]:

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
9 | Quote Removal                   | `"hello"` → `hello`


## Word splitting is number 7

One in particular is the cause of much suffering in this world: **word splitting**.
Word splitting is slightly hidden, because it only applies to the result of
previously executed expansions.

```bash
myfile='Stairway to heaven.mp3'
ls $myfile
```

Internally, the following expansions are performed to the argument `$myfile`:

```c
["$myfile"]  // Initially parsed word
["Stairway to heaven.mp3"]  // After parameter expansion
["Stairway", "to", "heaven.mp3"]  // After word splitting

// And the (extremely simplified version of the) system call
execve("/bin/ls", ["Stairway", "to", "heave.mp3"]);
```

We asked Bash to run the `ls` command with the single argument `$myfile`, but
instead, 3 arguments were passed. Unsuspectingly, we had white spaces in the
value of the variable `$myfile`, and because parameter substitution happens
_before_ word splitting the substituted value got split into words. The result
from `ls $myfile` is then:

```
ls: heaven.mp3: No such file or directory
ls: stairway: No such file or directory
ls: to: No such file or directory
```

Word splitting is the 7th expansion to be performed, so it will apply to the
results of 6 other expansions, and that is the number one source of bugs in Bash
scripts written by beginners. And more importantly, file name expansions
happen _after_ word splitting, so the files found with globbing, for example,
will not be split into further words.

## Zooming into word splitting

Let's start by creating a directory with a few tricky file names. Remember that
file names can contain any characters, except `NULL` and `/`. So `\n` (new
line), `*`, or even `漢` are game.

```bash
$ mkdir test
$ cd test
$ touch "hello space" "hello"'$\n'"newline" "hello*glob"  # $'\n' guarantees an actual new line character
```

And now our test files with tricky names look like this:

```bash
$ tree
.
├── hello\012newline
├── hello space
└── hello*glob
```

Now let run some commands:

```text
a[b,c] → ["ab ac"] → ["ab", "ac"]
$(ls) → 


[simple command]: https://www.gnu.org/software/bash/manual/html_node/Simple-Commands.html
[`execve`]: https://man7.org/linux/man-pages/man2/execve.2.html
[system call]: https://man7.org/linux/man-pages/man2/syscalls.2.html
[parameter expansion]: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
[shell expansions]: https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html