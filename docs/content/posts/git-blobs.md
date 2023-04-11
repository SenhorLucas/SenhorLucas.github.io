---
date: 2023-02-01T11:48:01+01:00
description: "Welcome to the very core of Git!"
draft: true
tags: ["git", "blobs"]
title: "Git blobs and trees explained"
params:
    ShowCodeCopyButtons: false
    ShowBreadCrumbs: true
---


## What is a blob?

How do Git remembers every version of every file in you project? Easy. Blobs.
For each version of every file in your repository, Git created a blob. So what
is a blob?

The definition is very simple: a blob is a file that lives under `.git/objects`.
This file is named after the sha1 of the original file, and its content is:

```
blob <size>\0<content>
```

That is, the word `blob`, space, the size of the blob in bytes, the null ASCII
character, and then the content of the original file. Oh, yes, and that file is
compressed to save space.

Let's put it to the test. We can tell Git to tell us the checksum of a file
using `git hash-object` like so:

```bash
$ printf 'hello' | git hash-object --stdin
b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0
```

Let's see if we can recreate this sha1 without using Git? Simple:

```bash
$ printf 'blob 5\0hello' | sha1sum
b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0
```

There you go, exactly the same. That shows that Git _really_ creates blobs in
the format that we expect.


### Creating a blob object from scratch, without Git

Creating a blob from scratch is super easy. Just create the string, compress and
save it to a file. Below, instead of saving it to a file, we do a `hexdump` to
see exactly what kind of garbled bytes come out on the other end, so we can
compare it with what Git actually produces.

```bash
$ printf 'blob 5\0hello' | pigz -z -1 | hexdump
0000000 0178 ca4b 4fc9 3052 c865 cd48 c9c9 0007
0000010 aa19 0904
0000014
```

To get Git to create a blob for us, all we need to do is `git add`. So below we
create the original file, with `hello` as content. After `git add`, we can do
a `hexdump` of the blob, so we can confirm that indeed, Git does exactly what
we did, and each bit is as we expected.

```bash
$ printf 'hello' > myfile
$ git add myfile
$ hexdump .git/objects/b6/fc4c620b67d95f953a5c1c1230aaab5db5a1b0
0000000 0178 ca4b 4fc9 3052 c865 cd48 c9c9 0007
0000010 aa19 0904 
0000014
```

Voila! The exact same bits.


## Trees

Trees are blobs for directories, so Git can remember where each file lives.
Just like blobs, trees live under `.git/objects` and they are named after their
checksum.


















```sh
# Add content to repo
$ echo 'test content' | git hash-object -w --stdin
d670460b4b4aece5915caf5c68d12f560a9fe3e4

$ git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4
test content

$ echo 'version 1' > test.txt
# Add content from work tree to repo
$ git hash-object -w test.txt
83baae61804e65cc73a7201a7252750c76066a30

$ echo 'version 2' > test.txt

$ git hash-object -w test.txt
1f7a7a472abf3dd9643fd615f6da379c4acb3e3a

# Repo to index
$ git update-index --add --cacheinfo 100644 83baae61804e65cc73a7201a7252750c76066a30 test.txt

$ git write-tree
d8329fc1cc938780ffdd9f94e0d364e0ea74f579

$ git cat-file -p d8329fc1cc938780ffdd9f94e0d364e0ea74f579
100644 blob 83baae61804e65cc73a7201a7252750c76066a30      test.txt

$ git cat-file -t d8329fc1cc938780ffdd9f94e0d364e0ea74f579
tree

$ git update-index --add --cacheinfo 10644 1f7a7a472abf3dd9643fd615f6da379c4acb3e3a text.txt

$ echo 'new file' > new.txt
$ git update-index --add new.txt

$ git write-tree
0155eb4229851634a0f03eb265b69f5a2d56f341

$ git cat-file -p 0155eb4229851634a0f03eb265b69f5a2d56f341
100644 blob 1f7a7a472abf3dd9643fd615f6da379c4acb3e3a      test.txt
100644 blob fa49b077972391ad58037050f2a75f74e3671e92      new.txt

$ git read-tree --prefix=bak d8329fc1cc938780ffdd9f94e0d364e0ea74f579

$ echo 'First commit'  | git commit-tree d8329f
fdf4fc3344e67ab068f836878b6c4951e3b15f3d
$ echo 'Second commit' | git commit-tree 0155eb -p fdf4fc3
cac0cab538b970a37ea1e769cbbde608743bc96d
$ echo 'Third commit'  | git commit-tree 3c4e9c -p cac0cab
1a410efbd13591db07496601ebc7a059dd55cfe9
```

Commands summary:

```sh
git cat-file [-p|-t]
git hash-object [-w] [--stdin]
git update-index [--add] [--cacheinfo] <permission> <hash> <file-name>
git write-tree
git read-tree [--prefix=<dir-name>] <hash>
```

```goat
.-----------.                 .-------.                     .------------.
| work tree |                 | index |                     | repository |
'-+-+-+-+---'                 '-+-+-+-'                     '---+-+-+-+--'
  ^ | | ^                       | ^ |                           ^ | ^ |
  | | | |                       | | | (create tree from index)  | | | |
  | | | |                       | | | write-tree                | | | |
  | | | +-----------------------+ | +---------------------------+ | | |
  | | |                           | (add tree to index)           | | |
  | | |                           | read-tree --prefix=path       | | |
  | | | update-index --add file   | update-index --cacheinfo sha1 | | |
  | | +---------------------------+-------------------------------+ | |
  | |  hash-object -w                                               | |
  | +---------------------------------------------------------------+ |
  |                                                                   |
  +-------------------------------------------------------------------+
```


## Permissions

- 100644: normal file
- 100755: executable
- 120000: symlink

## Blob anatomy

When Git stores a blob in the repository, the blob has the following form:

| 1    | 2                |   3  |   4         |
|------|------------------|------|-------------|
| blob | `<content-size>` | `\0` | `<content>` |


```text
# Format
blob <content-size>\0<content>

# For example
blob 5\0hello
```

Where:

1. The literal word `blob` followed by a white space.
2. The content size is the number of bytes in the file being stored.
3. A null byte
4. The actual content

That can be easily confirmed  in the command line:

```sh
$ printf 'blob 5%bhello' $'\0' | sha1sum
b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0

$ printf 'hello' | git hash-object --stdin
b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0
```

Apart from the ninja Bash command, it is pretty clear what a blob _is_. But if
we look in the repository, for the blob living at
`.git/objects/b6/fc4c620b67d95f953a5c1c1230aaab5db5a1b0`, the contents are
unnexpected.

```
$ cat .git/objects/b6/fc4c620b67d95f953a5c1c1230aaab5db5a1b0
xKOR0eH

$ cat .git/objects/b6/fc4c620b67d95f953a5c1c1230aaab5db5a1b0 | hexdump -C
00000000  78 01 4b ca c9 4f 52 30  65 c8 48 cd c9 c9 07 00  |x.K..OR0e.H.....|
00000010  19 aa 04 09                                       |....|
00000014
```

If we simply `cat` the file we see gibberish, and if we check the output
byte-by-byte we realize that there are plety of non-printing bytes in the
output. So what is going on? Why don't we see `blob 5<null>hello`?

As it turns out Git also compresses the blob using `zlib`

```
$ cat .git/objects/b6/fc4c620b67d95f953a5c1c1230aaab5db5a1b0 | python3 -c 'import sys; import zlib; print(zlib.decompress(sys.stdin.buffer.read()))'
b'blob 5\x00hello'
```

That convoluted way of decompressing zlib finally gave us the result we wanted.

