---
date: 2021-11-03T16:36:48+0100
draft: false
tags: ["encoding", "engineering", "computer-science"]
title: "Encodings part 3: The down and dirty of UTF-16"
---

This is part 3 of a series of posts on Unicode and encodings:

- [Encodings Part 1: Unicode, ASCII, UTF-8 and... Latin-1?]
- [Encodings Part 2: The down and dirty of UTF-8]
- [Encodings Part 3: The down and dirty of UTF-16]

A very short background
-----------------------

At the end of the '80s, there were two competing forces for standardizing
character sets: ISO 10646 and Unicode. ISO was idealistic and Unicode was
pragmatic. ISO created a character set containing more than 2 billion code
points (of course, most were not allocated). Unicode, on the other hand,
represented by computer companies, wanted to represent all characters in a
maximum of 2 bytes, i.e. there could not be more than 65 536 characters. Neither
was perfect, ISO's 4-byte-per-character scheme was wasteful, whereas Unicode
simply did not have enough space.

In 1991 and 1992 [Unicode and ISO merged] (yay!). On the flip side, the merged
standard defined UCS-2 and UCS-4 character encodings, and neither was good.
UCS-2, with only 2 bytes, could only represent 65536 characters, whereas UCS-4,
with (guess!) 4 bytes was beyond wasteful.

UCS-2 morphs into UTF-16!
-------------------------

But there was a hidden treasure in the new merged standard. As it turns out,
within the range `0xD800` to `0xDFFF` (55 296 to 57 343, in decimal), leaving
2048 values available. The engineers set off to make good use of these.  This
range, named the "surrogate rage", was split in half:

- The first 1024 values, from `0xD800` to `0xDBFF`, is called the "high
  surrogate."
- The second 1024 values, `0xDC00` to `0xDFFF`, is called the "low surrogate."

Now comes the trick: if you pair a high surrogate and a low surrogate
you can create 1 048 576 values. And this is what is called a surrogate pair.

    0xD800 0xDBFF -> surrogate pair

The resulting scheme is that code points from `0x0` to `0xFFFF` are encoded by
their actual values, just like UCS-2. But starting from `0x10000` (which is the
next number after `0xFFFF`) the code point is represented by a surrogate pair.

Cooking up a surrogate pair
---------------------------

- Get the code point that needs to be represented by a surrogate pair and
  subtract `0x10000`.
- The first 10 bits are added to the high surrogate, and the last 10 bits are
  added to the low surrogate.
- The high and the low 10-bit values are in the range `0x000`–`0x3FF`.

Examples
--------

### Snowman character (☃) --  U+2603

`U+2603` < `U+FFFF`, hence, simply use the code point number 0x26 0x03.

### Peach (🍑) -- U+1F351

`U+1F351` > `U+FFFF`, hence, a surrogate pair is needed.

```text
0x1F351 - 0x10000 = 0xF351

Split 0xF351 in 2 groups of 10 bits
Then add 0xD800 to the first group and DX00 to the second

0x0F351 →        00 0011 1100        11 0101 0001
0xD800  → 1101 0100 0000 0000
0xDC00  →                     1101 1100 0000 0000
_________________________________________________

          1101 0100 0011 1100 1101 1111 0101 0001 → 0xD83C 0xDF51
```

Python examples
---------------

Instead of doing all the bit-by-bit calculations by hand, let's see if we can
use Python to figure out the exact UTF-16 encoding of any Unicode code points.

Since the Python interpreter knows how to read Unicode. This means that our
Python programs can contain any Unicode code points, including in variable
names.

To get the UTF-16 encoding of the peach character, you just need a normal string
containing it, and then encode it to UTF-16. It's that easy.

```python
>>> '🍑'.encode('utf-16')
b'\xff\xfe<\xd8Q\xdf'  # This is hard to read, let'f fix it.
>>> '🍑'.encode('utf-16').hex(' ', 2)
'fffe 3cd8 51df'
```

We expected `d83c df51` but we got `fffe 3cd8 51df`. So what is going on?

Byte order and the BOM
----------------------

We got the correct result from Python, but there are 2 strange things:

- The result starts with `fffe`. We will look at this later.
- The byte pairs are inverted, `D8 3C` became `3C D8`. Let's understand this
  first.

Depending on the processor architecture that your computer is running on the
memory addresses are read going up or going down. This is called "endianess".
The result is that a little-endian processor reads the data structures in a
"reverse" order, placing the most significant byte at a higher memory value.

```text
                          Most significant byte
                          |   Least significant byte
                          |   |
Value                     D8  3C  | DF  51
Little endian address     4   3   | 2   1
Big endian address        1   2   | 3   4
```

This means that on little-endian processors the number `D8 3C` will be read from
memory as `3C D8`. That is fine, but what if you write a file using a big-endian
computer and read that file on a little-endian computer?  Well, in the best
case, it would explode with some kind of decoding error.  In the worse, case it
would return the wrong characters. Let's see if we can intentionally cause that
error in Python.

To cause that error we first need to know the endianess of my processor.
We can piece together that I am running on a little-endian machine because
Python decoded the '🍑' as `3cd8 51df`. So let's give Python a big-endian
byte string and tell it to decode it as UTF-16.

```python
>>> b'\xdf\x51\xd8\x3c'.decode('utf-16')
'凟㳘'  # Wrong! Byte order incorrect.
>>> b'\x3c\xd8\x51\xdf'.decode('utf-16')
'🍑'  # Better
```

Byte Order Mark
---------------

So how do computers with different endianess communicate via UTF-16? The answer
to that is the [Byte Order Mark] (BOM, for short). The UTF-16 convention is to
stuff `FFFE` at the beginning of a file or stream to indicate that it is
little-endian encoded, and `FEFF` to indicate big-endian encoding. There is
not much more to it than that.


[Unicode and ISO merged]: http://www.unicode.org/versions/Unicode1.0.0/V2ch01.pdf
[Byte Order Mark]: https://en.wikipedia.org/wiki/Byte_order_mark
[Encodings Part 1: Unicode, ASCII, UTF-8 and... Latin-1?]: {{< ref "encoding.md" >}}
[Encodings Part 2: The down and dirty of UTF-8]: {{< ref "encoding-utf-8.md" >}}
[Encodings Part 3: The down and dirty of UTF-16]: {{< ref "encoding-utf-16.md" >}}