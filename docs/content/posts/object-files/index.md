---
date: 2023-04-11T13:42:00+02:00
description: Digging deep into ELF files
draft: true
title: "Dissecting ELF files"
---


# Object files

In the never-ending search for the lower-level truth, eventually, you stumble
into an ELF.

I was trying to learn assembly and was hitting some existential questions that
I could not answer:

- What does the `.global` instruction _really_ do?
- Where are the `.text` section and `.data` sections loaded in memory?
- How does the executable file layout translate into a memory layout?
- Does the executable file have any information about the stack?

Those questions, and many more, I have found to be answered in the definition
of an object file.

When you write assembly code, you are so close to the CPU that it becomes
impossible to ignore the above questions. I realized that I needed to understand
what was coming out on the other end of the assembler.

Object files are the cornerstone of software. Or, rather, they **are** the
actual software. We write code in many programming languages but in the end,
what comes out on the other end are _machine instructions_ to be executed.

In bare-metal, where what you develop _is_ the OS, the object file gets loaded
at a certain place in memory, e.g. `0x8000` on some ARM systems. Then that value
is stored in the CPU program counter register, and execution begins.

When what you develop is run by an OS (as opposed to a bare-metal program),
object files are the API that compilers, assemblers, linkers, loaders and the
CPU itself all abide by. The object file contains all metadata needed for the OS
to know how to load it into memory.

At the end of the day, what you develop, high level, low level, mesoscale, it
all becomes an object file that describes the memory image of a process.

## Types of object files

There are many types of object file specifications:

- ELF
- AIF
- COFF
- raw binary format (more on this later)

And each specification can define different types of object files:

- Relocatable
- Executable
- Share object (position independent)

We start by taking a good look at the ELF format since it is widely adopted, the
standards are easily available and they can provide answers.

## ELF format

### Why so secret?

The biggest mystery in the software world is: "Where can I find the standards
and specifications?" For example, the POSIX standard, arguably the most
important one, is free to download, but it is so well hidden that people choose
to pay hundreds of dollars for it on the ISO web page.

The ELF specification isn't any different. Initially, it is buried in the
System V ABI specification, chapters 4 to 6, but now it is available on this
website:

https://www.sco.com/developers/gabi/

Who's gabi? What is Xinuos, and what is the SCO developer network (apparently
led by Intel?) I've seen too many links get broken and the link above also will -- so download the documents and keep them safe while it's still time.

### The specification

The ELF specification is separated into 2 parts, one generic and one that is
processor specific. By combining those parts, you get a complete specification
that is valid for a single family of processors.

The generic ABI (that's gABI!) doesn't change, and can be found at:

- https://www.sco.com/developers/gabi/latest/contents.html

The processor specific ABI has to be provided by the processor vendor:

- ARM: https://github.com/ARM-software/abi-aa/releases/download/2022Q1/aaelf32.pdf
- AMD64: http://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf

Again, download those and keep them safe!

## ELF x86 format: the fun begins

### General structure

ELF files have:

- ELF header
- Program header: needed for execution, not needed for relocation
- Section header: needed for relocation, not needed for execution.
- Body: A collections segments, each is a collection of sections.

```goat
                         +-----------------------+
                      +--| ELF HEADER            |----------+
                      |  +-----------------------+ Loading  |
                      +->| Program Header        |--+-+-+   |
                         +-----------------------+  | | |   |
              +--------->| Section  | Segment    |<-+ | |   |
              | +------->| Section  |            |    | |   |
              | | +----->| Section  |            |    | |   |
              | | | +--->| Section  | Segment    |<---+ |   |
              | | | | +->| Section  | Segment    |<-----+   |
              | | | | |  +-----------------------+          |
              +-+-+-+-+--| Section Header        |<---------+
          Reloaction     +-----------------------+
```

### Compilation and linking

Remember that there are 3 types of ELF files: relocatable, executable and
shared objects.

When we first compile each source file separately, we generate relocatable files
that are not directly executable. Those relocatable files contain Section
Headers that are used by the linker to generate executables. The final
executable contains Program Headers that contain information about how to load
the different segments to memory.

```goat
Human readable            Section headers              Program headers


            compilation
source1.s   ------------> relocatable1.o  |
                                           linking
source2.s   ------------> relocatable2.o  |----------> executable (or shared object)

source3.s   ------------> relocatable3.o  |

source4.s   ------------> relocatable4.o  |

```

### Simple example

The following program is a simple hello world that would print `Hello world!` to
the standard output. We will compile, link and execute this program, and we will
know 100% of what is going on in each byte of the process.

```s
.global _start

.data
    hello_world db "Hello world!", 10
    hello_world_len  equ $ - hello_world

.text
    _start:
        mov rax, 1
        mov rdi, 1
        mov rsi, hello_world
        mov rdx, hello_world_len
        syscall

        mov rax, 60
        mov rdi, 0
        syscall
```

For me to compile this on my Ubuntu 22.04 machine, running on an x86_64
processor, I run the following commands:

```bash
$ as -o hello_world.o hello_world.s
$ as -o hello_world hello_world.o
```

The fun is about to start! Let's look into the `hello_world.o` and `hello_world`
binary files.

### The raw content

Let's first look at the raw content of the _relocatable_ object file
`hello_world.o`, i.e. before linking.

```text
$ gc hello_world.o
00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
00000010  01 00 3e 00 01 00 00 00  00 00 00 00 00 00 00 00  |..>.............|
00000020  00 00 00 00 00 00 00 00  60 01 00 00 00 00 00 00  |........`.......|
00000030  00 00 00 00 40 00 00 00  00 00 40 00 08 00 07 00  |....@.....@.....|
00000040  b8 04 00 00 00 bb 01 00  00 00 b9 00 00 00 00 ba  |................|
00000050  0d 00 00 00 cd 80 b0 01  bb 00 00 00 00 cd 80 48  |...............H|
00000060  65 6c 6c 6f 20 77 6f 72  6c 64 21 0a 00 00 00 00  |ello world!.....|
00000070  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000080  00 00 00 00 00 00 00 00  00 00 00 00 03 00 03 00  |................|
00000090  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000a0  01 00 00 00 00 00 03 00  00 00 00 00 00 00 00 00  |................|
000000b0  00 00 00 00 00 00 00 00  0d 00 00 00 00 00 f1 ff  |................|
000000c0  0d 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000d0  1d 00 00 00 10 00 01 00  00 00 00 00 00 00 00 00  |................|
000000e0  00 00 00 00 00 00 00 00  00 68 65 6c 6c 6f 5f 77  |.........hello_w|
000000f0  6f 72 6c 64 00 68 65 6c  6c 6f 5f 77 6f 72 6c 64  |orld.hello_world|
00000100  5f 6c 65 6e 00 5f 73 74  61 72 74 00 00 00 00 00  |_len._start.....|
00000110  0b 00 00 00 00 00 00 00  0a 00 00 00 01 00 00 00  |................|
00000120  00 00 00 00 00 00 00 00  00 2e 73 79 6d 74 61 62  |..........symtab|
00000130  00 2e 73 74 72 74 61 62  00 2e 73 68 73 74 72 74  |..strtab..shstrt|
00000140  61 62 00 2e 72 65 6c 61  2e 74 65 78 74 00 2e 64  |ab..rela.text..d|
00000150  61 74 61 00 2e 62 73 73  00 00 00 00 00 00 00 00  |ata..bss........|
00000160  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
000001a0  20 00 00 00 01 00 00 00  06 00 00 00 00 00 00 00  | ...............|
000001b0  00 00 00 00 00 00 00 00  40 00 00 00 00 00 00 00  |........@.......|
000001c0  1f 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001d0  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001e0  1b 00 00 00 04 00 00 00  40 00 00 00 00 00 00 00  |........@.......|
000001f0  00 00 00 00 00 00 00 00  10 01 00 00 00 00 00 00  |................|
00000200  18 00 00 00 00 00 00 00  05 00 00 00 01 00 00 00  |................|
00000210  08 00 00 00 00 00 00 00  18 00 00 00 00 00 00 00  |................|
00000220  26 00 00 00 01 00 00 00  03 00 00 00 00 00 00 00  |&...............|
00000230  00 00 00 00 00 00 00 00  5f 00 00 00 00 00 00 00  |........_.......|
00000240  0d 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000250  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000260  2c 00 00 00 08 00 00 00  03 00 00 00 00 00 00 00  |,...............|
00000270  00 00 00 00 00 00 00 00  6c 00 00 00 00 00 00 00  |........l.......|
00000280  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000290  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000002a0  01 00 00 00 02 00 00 00  00 00 00 00 00 00 00 00  |................|
000002b0  00 00 00 00 00 00 00 00  70 00 00 00 00 00 00 00  |........p.......|
000002c0  78 00 00 00 00 00 00 00  06 00 00 00 04 00 00 00  |x...............|
000002d0  08 00 00 00 00 00 00 00  18 00 00 00 00 00 00 00  |................|
000002e0  09 00 00 00 03 00 00 00  00 00 00 00 00 00 00 00  |................|
000002f0  00 00 00 00 00 00 00 00  e8 00 00 00 00 00 00 00  |................|
00000300  24 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |$...............|
00000310  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000320  11 00 00 00 03 00 00 00  00 00 00 00 00 00 00 00  |................|
00000330  00 00 00 00 00 00 00 00  28 01 00 00 00 00 00 00  |........(.......|
00000340  31 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |1...............|
00000350  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000360
```

### ELF header

```c
typedef struct {
        unsigned char   e_ident[EI_NIDENT];
        Elf64_Half      e_type;
        Elf64_Half      e_machine;
        Elf64_Word      e_version;
        Elf64_Addr      e_entry;
        Elf64_Off       e_phoff;
        Elf64_Off       e_shoff;
        Elf64_Word      e_flags;
        Elf64_Half      e_ehsize;
        Elf64_Half      e_phentsize;
        Elf64_Half      e_phnum;
        Elf64_Half      e_shentsize;
        Elf64_Half      e_shnum;
        Elf64_Half      e_shstrndx;
} Elf64_Ehdr;
```

This corresponds to the first 64 bytes of the file:

```
00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
00000010  01 00 3e 00 01 00 00 00  00 00 00 00 00 00 00 00  |..>.............|
00000020  00 00 00 00 00 00 00 00  60 01 00 00 00 00 00 00  |........`.......|
00000030  00 00 00 00 40 00 00 00  00 00 40 00 08 00 07 00  |....@.....@.....|
```

Variable    | Value                     | Meaning
------------|---------------------------|--------
e_ident     | `7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00` | see next
e_type      | `01 00`                   | relocatable
e_machine   | `3e 00`                   | AMD x86-64 architecture
e_version   | `01 00 00 00`             | Version 1 of ELF specification
e_entry     | `00 00 00 00 00 00 00 00` | Entry point not specified
e_phoff     | `00 00 00 00 00 00 00 00` | Program header offset (No program header.)
e_shoff     | `60 01 00 00 00 00 00 00` | Section header offset (At `0x160`, i.e. 352 bytes)
e_flags     | `00 00 00 00`             | No processor specific flags
e_ehsize    | `40 00`                   | Elf header size (`0x40` == 64 bytes)
e_phentsize | `00 00`                   | Program header has zero bytes
e_phnum     | `00 00`                   | Program header has zero entries
e_shentsize | `40 00`                   | Each section header has `0x40` bytes
e_shnum     | `08 00`                   | There are 8 section headers
e_shstrndx  | `07 00`                   | Section header string table index (mumbo jumbo, but we will see later.)

The ELF header has the following format:

#### `e_ident`

Since `EI_NIDENT=16`, we know that `e_ident` is a 16 bytes array:

```text
7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00
```
e_ident
According to the specification, those values mean:

| idx| Variable name  | Hex | Meaning       | description
|----|----------------|-----|---------------|------------
| 0  | EI_MAG0        | 7f  | `0x7F`        | A fixed magic number
| 1  | EI_MAG1        | 45  | `E`           | A fixed magic number
| 2  | EI_MAG2        | 4c  | `L`           | A fixed magic number
| 3  | EI_MAG3        | 46  | `F`           | A fixed magic number
| 4  | EI_CLASS       | 02  | 64 bits       | File class. 1 for 32 bits, 2 for 64 bits
| 5  | EI_DATA        | 01  | Little endian | Data encoding
| 6  | EI_VERSION     | 01  | Version one   | File version
| 7  | EI_OSABI       | 00  | Unspecified   | Specifies if OS dependent extensions were used
| 8  | EI_ABIVERSION  | 00  | ?             | ABI version
| 9  | EI_PAD         | 00  | Padding       | Start of padding bytes
| 16 | EI_NIDENT      | 00  | Padding       | Size of e_ident[]

For `EI_ABIVERSION` we got the value `0`, which means we have an invalid
version. I do not know why that is.

#### `readelf -h`

Now you'll never have to do this manually again. Next time you need information
from the ELF header, you can run `readelf -h <filename>`. Everything until
`ABI Version` comes from the `e_ident`, and the rest are the other elements of
the header `struct`.

```text
$ readelf -h hello_world.o
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0

  Type:                              REL (Relocatable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x0
  Start of program headers:          0 (bytes into file)
  Start of section headers:          352 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           0 (bytes)
  Number of program headers:         0
  Size of section headers:           64 (bytes)
  Number of section headers:         8
  Section header string table index: 7
```

### Section headers

From the ELF header we got that:

- The section headers start at `0x160`
- Each header has `0x40` bytes (interesting, same size as the ELF header)
- There are 8 sections.

```text
00000160  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*

000001a0  20 00 00 00 01 00 00 00  06 00 00 00 00 00 00 00  | ...............|
000001b0  00 00 00 00 00 00 00 00  40 00 00 00 00 00 00 00  |........@.......|
000001c0  1f 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001d0  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|

000001e0  1b 00 00 00 04 00 00 00  40 00 00 00 00 00 00 00  |........@.......|
000001f0  00 00 00 00 00 00 00 00  10 01 00 00 00 00 00 00  |................|
00000200  18 00 00 00 00 00 00 00  05 00 00 00 01 00 00 00  |................|
00000210  08 00 00 00 00 00 00 00  18 00 00 00 00 00 00 00  |................|

00000220  26 00 00 00 01 00 00 00  03 00 00 00 00 00 00 00  |&...............|
00000230  00 00 00 00 00 00 00 00  5f 00 00 00 00 00 00 00  |........_.......|
00000240  0d 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000250  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|

00000260  2c 00 00 00 08 00 00 00  03 00 00 00 00 00 00 00  |,...............|
00000270  00 00 00 00 00 00 00 00  6c 00 00 00 00 00 00 00  |........l.......|
00000280  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000290  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|

000002a0  01 00 00 00 02 00 00 00  00 00 00 00 00 00 00 00  |................|
000002b0  00 00 00 00 00 00 00 00  70 00 00 00 00 00 00 00  |........p.......|
000002c0  78 00 00 00 00 00 00 00  06 00 00 00 04 00 00 00  |x...............|
000002d0  08 00 00 00 00 00 00 00  18 00 00 00 00 00 00 00  |................|

000002e0  09 00 00 00 03 00 00 00  00 00 00 00 00 00 00 00  |................|
000002f0  00 00 00 00 00 00 00 00  e8 00 00 00 00 00 00 00  |................|
00000300  24 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |$...............|
00000310  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|

00000320  11 00 00 00 03 00 00 00  00 00 00 00 00 00 00 00  |................|
00000330  00 00 00 00 00 00 00 00  28 01 00 00 00 00 00 00  |........(.......|
00000340  31 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |1...............|
00000350  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
```

The format of each section header is:

```c
typedef struct {
	Elf64_Word	sh_name;
	Elf64_Word	sh_type;
	Elf64_Xword	sh_flags;
	Elf64_Addr	sh_addr;
	Elf64_Off	sh_offset;
	Elf64_Xword	sh_size;
	Elf64_Word	sh_link;
	Elf64_Word	sh_info;
	Elf64_Xword	sh_addralign;
	Elf64_Xword	sh_entsize;
} Elf64_Shdr;
```

#### Section 0: Null section header

It is specified that the first section header, the one with index zero, should
be filled out as zeros. So bytes `0x160` to `0x19F` are all zeros. In certain
cases, the null section can be used to provide some extra information.

#### Section 7: Section header string table

The first actual section we should look at is section 7. If remember from the
ELF header at the top, the field `eh_shstrndx` had value 7. This is the section
header that points to the **section header string table**

Here are the raw bytes from this section header (at the very bottom of the
file):

```text
00000320  11 00 00 00 03 00 00 00  00 00 00 00 00 00 00 00  |................|
00000330  00 00 00 00 00 00 00 00  28 01 00 00 00 00 00 00  |........(.......|
00000340  31 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |1...............|
00000350  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
```

Name           | Value                      | Meaning
---------------|----------------------------|--------
sh_name        | `11 00 00 00`              | Section name found at index 11 in the section header string table
sh_type        | `03 00 00 00`              | Type: string table
sh_flags       | `00 00 00 00 00 00 00 00`  | No flags
sh_addr        | `00 00 00 00 00 00 00 00`  | No address in memory
sh_offset      | `28 01 00 00 00 00 00 00`  | Section starts at `0x128` (296) bytes into the file
sh_size        | `31 00 00 00 00 00 00 00`  | Section is `0x31` (49) bytes long
sh_link        | `00 00 00 00`              | No link information
sh_info        | `00 00 00 00`              | No additional information
sh_addralign   | `01 00 00 00 00 00 00 00`  | No alignment constraints
sh_entsize     | `00 00 00 00 00 00 00 00`  | Section header string table has variable entry size

Now that we know the start and length of the section, we can get its contents
quite easily with `hexdump`:

```bash
$ hexdump -C -s 296 -n 49 hello_world_x86_64.o
00000128  00 2e 73 79 6d 74 61 62  00 2e 73 74 72 74 61 62  |..symtab..strtab|
00000138  00 2e 73 68 73 74 72 74  61 62 00 2e 72 65 6c 61  |..shstrtab..rela|
00000148  2e 74 65 78 74 00 2e 64  61 74 61 00 2e 62 73 73  |.text..data..bss|
00000158  00                                                |.|
00000159
```

Each entry in the table starts anywhere in the table and ends with a null byte,
e.g.:

```
2e 73 68 73 74 72 74  61 62 00  | .shstrtab
73 74 72 74  61 62 00  | strtab
```

So let's rewrite the entire table in human readable format:

index   | name
--------|-----
1       | `.symtab`
9       | `.strtab`
17      | `.shstrtab`
27      | `.rela.text` (This contains 2 section names, overlapping!)
38      | `.data`
44      | `.bss`

That feels good! Now we know all the section names.

Now we can checkout the name of section 7 itself, by using section 7's content!
The first 4 bytes of the section header `0x11 00 00 00` is the `sh_name` value.
This is the index into the _section header string table_ we can find the section
name. At `0x11` (17 in decimal), we have the name of the section: **.shstrtab**.

#### Section 1

Let's look at the other sections in order now, one by one.

The section one has the following raw content:

```
000001a0  20 00 00 00 01 00 00 00  06 00 00 00 00 00 00 00  | ...............|
000001b0  00 00 00 00 00 00 00 00  40 00 00 00 00 00 00 00  |........@.......|
000001c0  1f 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000001d0  01 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
```

Name            | Value                     | Meaning
----------------|---------------------------|--------
`sh_name`       | `20 00 00 00`             | Index 2 into the _section header string table_
`sh_type`       | `01 00 00 00`             | Type 1: `PROGBITS`, i.e. the actual program
`sh_flags`      | `06 00 00 00 00 00 00 00` | `0x6 == 0x4 + 0x2`. `ALLOC` and `EXECINSTR`
`sh_addr`       | `00 00 00 00 00 00 00 00` | Address where section will be loaded into memory
`sh_offset`     | `40 00 00 00 00 00 00 00` | Section starts at byte `0x40` (64) into the file
`sh_size`       | `1f 00 00 00 00 00 00 00` | Size of the section `0x1f` (31) bytes
`sh_link`       | `00 00 00 00`             | Zero, no link
`sh_info`       | `00 00 00 00`             | No auxiliary information
`sh_addralign`  | `01 00 00 00 00 00 00 00` | No alignment constraints
`sh_entsize`    | `00 00 00 00 00 00 00 00` | Entries in this section have variable size

The section name is at index `0x20` (32) into the _section header string table_.
This section name starts right in the middle of the string `.rela.text`, and
if we count exactly 32 bytes into the table, we get exactly `.text`. It is
quite interesting how strings can overlap that way. Massively space saving :/

Now we know that this is our text section, and we intended to create such a
section, as we instructed in the assembly code:

```s
.text
    _start:
        mov rax, 1
        ...
```

The raw content of this section, starting at byte `0x40` and walking `0x1f`
forward (i.e. up to `0x5e`) is:

```text
$ hexdump -C -s 64 -n 31 hello_world_x86_64.o
00000040  b8 04 00 00 00 bb 01 00  00 00 b9 00 00 00 00 ba  |................|
00000050  0d 00 00 00 cd 80 b0 01  bb 00 00 00 00 cd 80     |...............|
0000005f
```

That is the actual hexadecimal representation of our assembly code. With help
from `objdump` we can reverse engineer it:

```text
$ objdump --disassemble hello_world_x86_64.o

hello_world_x86_64.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <_start>Other sections:
   0:   b8 04 00 00 00          mov    $0x4,%eax
   5:   bb 01 00 00 00          mov    $0x1,%ebx
   a:   b9 00 00 00 00          mov    $0x0,%ecx
   f:   ba 0d 00 00 00          mov    $0xd,%edx
  14:   cd 80                   int    $0x80
  16:   b0 01                   mov    $0x1,%al
  18:   bb 00 00 00 00          mov    $0x0,%ebx
  1d:   cd 80                   int    $0x80
```

How cool is that?! We now know exactly where the actual instructions are located
in our file: from `0x40` to `0x5e` we have the program section, and the full
section description is located in bytes `0x1a0` to `0x1d0`. That section is at
index 1 of the section header table, which starts at `0x160` bytes into the
file, as described by the ELF header.

#### All sections summary

Before moving on to all other sections, we now introduce a faster way of getting
information from ELF files. The `readelf` utility can give you all information
you would possibly want without you having to go in an manually count the bytes.
We could have used this utility from the start, but I find it soothing to know
exactly what is going on behind the scenes.

```text
$ readelf --sections hello_world.o
There are 8 section headers, starting at offset 0x160:

Section Headers:
  [Nr] Name        Type       Address           Offset   Size              EntSize          Flags  Link  Info  Align
  [ 0]             NULL       0000000000000000  00000000 0000000000000000  0000000000000000        0     0     0
  [ 1] .text       PROGBITS   0000000000000000  00000040 000000000000001f  0000000000000000  AX    0     0     1
  [ 2] .rela.text  RELA       0000000000000000  00000110 0000000000000018  0000000000000018   I    5     1     8
  [ 3] .data       PROGBITS   0000000000000000  0000005f 000000000000000d  0000000000000000  WA    0     0     1
  [ 4] .bss        NOBITS     0000000000000000  0000006c 0000000000000000  0000000000000000  WA    0     0     1
  [ 5] .symtab     SYMTAB     0000000000000000  00000070 0000000000000078  0000000000000018        6     4     8
  [ 6] .strtab     STRTAB     0000000000000000  000000e8 0000000000000024  0000000000000000        0     0     1
  [ 7] .shstrtab   STRTAB     0000000000000000  00000128 0000000000000031  0000000000000000        0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), l (large), p (processor specific)
```

Wow, that is a lot of information. But we already know what sections 0, 1 and 7
are all about. We will tackle the others now, and we will use `readelf` to make
things faster. Keep an eye on the table above, because we will not use the hex
dump of the section headers anymore.

#### Section 6: string table

Section 6 is a low hanging fruit, easy to understand. It is just another string
table. Let's use `readelf` to get its contents:

```text
$ readelf --hex-dump 6 --string-dump 6 hello_world.o

Hex dump of section '.strtab':
  0x00000000 0068656c 6c6f5f77 6f726c64 0068656c .hello_world.hel
  0x00000010 6c6f5f77 6f726c64 5f6c656e 005f7374 lo_world_len._st
  0x00000020 61727400                            art.


String dump of section '.strtab':
  [     1]  hello_world
  [     d]  hello_world_len
  [    1d]  _start
```

That was fast and easy. We now know that section 6 has name `.strtab` and
contains 3 entries: `hello_world`, `hello_world_len` and `_start`. Those word
are familiar, and we will soon see how it all comes together.

#### Section 5: symbol table

Section 5 has type `SYMTAB`, meaning that it is a [symbol table]. Note also that
this is the first section where we have a non-zero `sh_entsize`. In this case,
each entry in the symbol table is `0x18` (24) bytes long.

Each entry in the symbol table has the following format:

```c
typedef struct {
	Elf64_Word	st_name;
	unsigned char	st_info;
	unsigned char	st_other;
	Elf64_Half	st_shndx;
	Elf64_Addr	st_value;
	Elf64_Xword	st_size;
} Elf64_Sym;
```

The hex dump of this section looks like this:

```text
$ readelf --hex-dump 5 hello_world_x86_64.o

Hex dump of section '.symtab':
  0x00000000 00000000 00000000 00000000 00000000 ................
  0x00000010 00000000 00000000 00000000 03000300 ................
  0x00000020 00000000 00000000 00000000 00000000 ................
  0x00000030 01000000 00000300 00000000 00000000 ................
  0x00000040 00000000 00000000 0d000000 0000f1ff ................
  0x00000050 0d000000 00000000 00000000 00000000 ................
  0x00000060 1d000000 10000100 00000000 00000000 ................
  0x00000070 00000000 00000000                   ........
```

Doing the manual `struct` unpacking:

index  | `st_name`   | `st_info`   | `st_other`  | `st_shndx`  | `st_value`            | `st_size`
-------|-------------|-------------|-------------|-------------|-----------------------|----------
0      | `00000000`  | `00`        | `00`        | `0000`      | `00000000 00000000`   | `00000000 00000000`
1      | `00000000`  | `03`        | `00`        | `0300`      | `00000000 00000000`   | `00000000 00000000`
2      | `01000000`  | `00`        | `00`        | `0300`      | `00000000 00000000`   | `00000000 00000000`
3      | `0d000000`  | `00`        | `00`        | `f1ff`      | `0d000000 00000000`   | `00000000 00000000`
4      | `1d000000`  | `10`        | `00`        | `0100`      | `00000000 00000000`   | `00000000 00000000`

These numbers are not self-explanatory, so we will go field-by-field before
understanding each symbol.

The first entry in the table contains only zeroes, and it represents the
undefined symbol, so I'll it out from now on.

##### Symbol table `st_name`

This is the index into the string table `.strtab` in section 6, where we find
the symbol name.

index | hex    | dec   | string
------|--------|-------|-------
1     |`0x00`  | 0     | no name
2     |`0x01`  | 1     | `hello_world`
3     |`0x0d`  | 13    | `hello_world_len`
4     |`0x1d`  | 34    | `_start`

Symbol 1 has no name, but we will see why that is soon.

##### Symbol table `st_info`

The `st_info` field groups 2 properties together, probably to save some space:

- `ELF64_ST_BIND`: Specifies linking visibility local, global or weak. If you
  try to use a local symbol from another object file, you will get a linking
  error.
- `ELF64_ST_TYPE`: Specifies what kind of symbol it is: object, function,
  section file, common or a thread-local storage. The type `STT_COMMON`, for
  example represents (I suspect) symbols in the `.bss` section.

According to the documentation, it means:

```c
   #define ELF64_ST_BIND(i)   ((i)>>4)
   #define ELF64_ST_TYPE(i)   ((i)&0xf)
   #define ELF64_ST_INFO(b,t) (((b)<<4)+((t)&0xf))
```

and this is just rude.

What they are trying to say is that `ELF64_ST_BIND` is the upper 4 bits, and
`ELF64_ST_TYPE` is the lower 4 bits in the `st_info` byte:

index       | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | result
------------|---|---|---|---|---|---|---|---|-------
`st_info`   | 0 | 0 | 0 | 1 | 0 | 0 | 1 | 1 | `0x13`
`BIND`      | 0 | 0 | 0 | 1 |   |   |   |   | `0x01`
`TYPE`      |   |   |   |   | 0 | 0 | 1 | 1 | `0x03`

Once we discovered the value of `TYPE` and `BIND` we can look in the
specification to find out their meaning:

index   | hex     | bits        | ST_BIND   | Meaning     | ST_TYPE | Meaning
--------|---------|-------------|-----------|-------------|---------|--------
1       | `0x03`  | `0000 0011` | 0         | STB_LOCAL   | 3       | STT_SECTION
2       | `0x00`  | `0000 0000` | 0         | STB_LOCAL   | 0       | STT_NOTYPE
3       | `0x00`  | `0000 0000` | 0         | STB_LOCAL   | 0       | STT_NOTYPE
4       | `0x10`  | `0001 0000` | 1         | STB_GLOBAL  | 0       | STT_NOTYPE

Remember that symbol 1 had no name? Now we know that it has type `STT_SECTION`,
so it represents a sectoin. All other symbols have type `STT_NOTYPE`, which
probably means that we didn't give the compiler enough information about it,
but at this point I am not 100% sure.

##### Symbol table `st_other`

This specifies the visibility of the symbol. `st_other` is a terrible name to
describe this functionality.

Four values are currently possible:

```text
STV_DEFAULT	  0
STV_INTERNAL	1
STV_HIDDEN	  2
STV_PROTECTED	3
```

The visibility is tightly related to the `ELF64_ST_BIND` property we just saw
above.

All symbols in our table have default visibility, meaning that they get their
visibility from the value of `ELF64_ST_BIND`. For example, `STT_LOCAL` symbols
are given `STV_HIDDEN`. `STT_GLOBAL` and `STT_WEAK` are visible outside their
defining component.

Visibility is important only at execution time, whereas binding is important at
linking time.

##### Symbol table `st_shndx

Every symbol "belongs" to a certain section, so this field tells you the index
of its respective section header. From the raw hex data, we have:

index |name              |  `st_shndx`  | meaning
------|------------------|--------------|--------
1     | no name          | `0300`       | Symbol relative to section 3, `.data`
2     | `hello_world`    | `0300`       | Symbol relative to section 3, `.data`
3     | `hello_world_len`| `f1ff`       | `SHN_ABS`: absolute position in the file, not to be relocated.
4     | `_start`         | `0100`       | Symbol relative to section 1, `.text`

Just refreshing our heads on original assembly code:

```s
...
.data
    hello_world db "Hello world!", 10
    hello_world_len  equ $ - hello_world

.text
    _start:
...
```

Symbols 2 and 4 match pretty well: `hello_world` is defined in the `.data`
section and `_start` is defined in the `.text` section, as we wanted.

Symbol 3 (`hello_world_len`) has the value `0xfff1` (big endian), which means
that it is an absolute symbol and its value shall not change during linking.
That does make sense, because the length of `Hello world!` is a constant. What
we are seeing here is that the assembler (`as`) is smart enough to know if a
symbol (labels) point to a memory location that might change, or if their values
are constant. The linker then knows which symbol values to change during
relocation.

And finally we know the meaning of symbol 1, which had no name and `STT_SECTION`.
This symbol simply represents the `.data` section, not more than that. I am not
quite sure, however, why we don't have a symbol for the `.text` section.

And, at last, let's look at the symbol values!

##### Symbol table `st_size` and `st_value`

Now that we have decoded all the symbol table metadata, not least the `st_info`
sub-fields, we can now decode each symbol, and see what their values mean.

All symbol's size and value are zero, except for symbol 3, which has the
expected value of `0xd`. That's odd. We expected symbol 2 `hello_world` to point
the the address of the first character of the `Hello world!` string.

index | name             |  `st_shndx`  | `st_value`            | `st_size`
------|------------------|--------------|-----------------------|----------
1     | no name          | `0300`       | `00000000 00000000`   | `00000000 00000000`
2     | `hello_world`    | `0300`       | `00000000 00000000`   | `00000000 00000000`
3     | `hello_world_len`| `f1ff`       | `0d000000 00000000`   | `00000000 00000000`
4     | `_start`         | `0100`       | `00000000 00000000`   | `00000000 00000000`

So, what is going on?

Let's start by pulling up the contents of the `.data` section with `hexdump`.
Looking at the section headers from before, the `.data` section starts at `0x5f`
(95) and is `0xd` (13) bytes long:

```text
$ hexdump -C -s 95 -n 13 hello_world_x86_64.o
0000005f  48 65 6c 6c 6f 20 77 6f  72 6c 64 21 0a           |Hello world!.|
0000006c
```

See that? The string `Hello world!\n` _is_ at index zero of the `.data` section!
That is why the value of symbol 2 `hello_world` is zero.

Likewise, `_start` points to the first byte of the `.text` section, which makes
total sense: that's where we put it. That's why it has value zero.

And we still have symbol 1, looking strange, also pointing to the beginning of
the `.data` section.

##### Summarizing the symbol table

To quickly get a glimpe into the symbol table we can use the `nm` utility:

```text
$ nm --format sysv -a hello_world_x86_64.o


Symbols from hello_world_x86_64.o:

Name                  Value           Class        Type         Size             Line  Section

.data               |0000000000000000|   d  |                  |                |     |
hello_world         |0000000000000000|   d  |            NOTYPE|                |     |.data
hello_world_len     |000000000000000d|   a  |            NOTYPE|                |     |*ABS*
_start              |0000000000000000|   T  |            NOTYPE|                |     |.text
```

We can quickly see the symbol name and value, but the other parts of the output
I find lacking. We do not get exact information about each field, such as
bind and type. The `.data` symbol, for example, has `STT_SECTION`, but that is
not mentioned in the output.

So there you go. This is an opportunity for us to get coding and create a tool
that gives us more information.

The full information of our symbol table is as follows:

i | Name              | Section   | ST_TYPE       | ST_BIND      |Other          |Size             |  Value          
--|-------------------|---------  |---------------|--------------|---------------|-----------------|-----------------
0 | undefined         | 0         | 0             | 0            | 0             | 0               | 0
1 | no name           | `.data`   | `STT_SECTION` | `STB_LOCAL`  | `STV_DEFAULT` |`000000000000000`| `0000000000000000`
2 | `hello_world`     | `.data`   | `STT_NOTYPE`  | `STB_LOCAL`  | `STV_DEFAULT` |`000000000000000`| `0000000000000000`
3 | `hello_world_len` |  *ABS*    | `STT_NOTYPE`  | `STB_LOCAL`  | `STV_DEFAULT` |`000000000000000`| `000000000000000d`
4 | `_start`          | `.text`   | `STT_NOTYPE`  | `STB_GLOBAL` | `STV_DEFAULT` |`000000000000000`| `0000000000000000`

Phew!

### Section 2, the `.rela.text` section

[Nr] Name        Type       Address           Offset   Size              EntSize          Flags  Link  Info  Align
[ 2] .rela.text  RELA       0000000000000000  00000110 0000000000000018  0000000000000018   I    5     1     8

### Section 3, the `.data` section

[Nr] Name        Type       Address           Offset   Size              EntSize          Flags  Link  Info  Align
[ 3] .data       PROGBITS   0000000000000000  0000005f 000000000000000d  0000000000000000  WA    0     0     1

### Section 4, the `.bss` section

[Nr] Name        Type       Address           Offset   Size              EntSize          Flags  Link  Info  Align
[ 4] .bss        NOBITS     0000000000000000  0000006c 0000000000000000  0000000000000000  WA    0     0     1


Section Headers:
  [ 3] .data       PROGBITS   0000000000000000  0000005f 000000000000000d  0000000000000000  WA    0     0     1
  [ 4] .bss        NOBITS     0000000000000000  0000006c 0000000000000000  0000000000000000  WA    0     0     1

[symbol table]: https://www.sco.com/developers/gabi/latest/ch4.symtab.html
