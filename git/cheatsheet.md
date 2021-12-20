# Git cheatsheet

```ascii
Working                     Staging                     Repository
directory

project                     project/.git/index          project/.git/objects
    |                           |                           |
    |      add                  |                           |
    |  ---------------------->  |                           |
    |                           |      commit               |
    |                           |  ---------------------->  |
    |                                                       |
    |                       checkout                        |
    |  <-------------------------------------------------   |
    |                           |                           |
```

Project tree:
```ascii
project
├── dir1
└── dir2
    ├── file.txt
    └── file2
```

Index:
file        | wdir  | stage | repo  |
------------|-------|-------|-------|
file.txt    |cf5    |cf5    |cf5    |
file2       |5d0    |5d9    |5d9    |

Repository:
```ascii
                                                  +-> cf5
                                                  |   blob
HEAD ---> branch_name ---> ad6    ----> f89   ----+
                           commit       tree      |
                                                  +-> 5d9
                                                      blob
```

## Types of git objects

### Blob
### Tree
### Commit
### Branch
### HEAD


## Git revisions (`man gitrevisions`)

* <sha1>
* <describeOutput> <tag>-123-g<abbrev-sha1>
* <refname>: master, refs/heads/master
* TODO: all refs with @
* <ref>^, <ref>~<n>
* TODO...
*
origin..HEAD

## Commands

`git log -L '<start>,<end>:<file>'`
`git log -L ':<funcname>:<file>'` Still a bit cryptic, find examples

`git log -L '4,12:path/to/file'`
`git log -L '/content of line/,+1:path/to/file'`
