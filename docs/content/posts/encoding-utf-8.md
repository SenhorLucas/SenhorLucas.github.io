---
date: 2021-11-03T16:36:48+01:00
draft: false
tags: ["encoding", "engineering", "computer-science"]
title: "Encodings part 2: The down and dirty of UTF-8"
---

What the double UTF is UTF-8? Let's decode this, bit-by-bit.

This is part 2 of a series of posts on Unicode and encodings:

- [Encodings Part 1: Unicode, ASCII, UTF-8 and... Latin-1?]
- [Encodings Part 2: The down and dirty of UTF-8]
- [Encodings Part 3: The down and dirty of UTF-16]


Unicode and UTF-8
-----------------

In part 1, we dug a little deeper into the reasons to be for Unicode and found
out that Unicode is an immense character table containing all the characters in
the world. Or at least a valiant attempt at that. This table has 1 112 064 rows,
and each row is a **code point** (i.e., a number), but "only" 144 697 of the
code points have been assigned so far. Each code point [represents a
character/symbol](http://www.unexpected-vortices.com/misc-notes/text-unicode/terminology.html).

Now let's get the highest code point on this table and convert it to binary:

```text
1 112 064 → 0b10000 11111000 00000000
```

Well, there you go, that's how we can store code points in a computer, right?

Sure, congratulations, you've just invented UTF-32. Well, you've actually
invented UTF-24, but good luck finding a 24-bit data type with similar
performance 32-bit data types.

So the text "hello world!" in UTF-32 is:

| character | decimal         | UTF-32          |
| --------- | --------------- | --------------- |
| h         | 104             | `0x00 00 00 68` |
| e         | 101             | `0x00 00 00 65` |
| l         | 108             | `0x00 00 00 6c` |
| l         | 108             | `0x00 00 00 6c` |
| o         | 111             | `0x00 00 00 6f` |
|           | 032             | `0x00 00 00 20` |
| w         | 119             | `0x00 00 00 77` |
| o         | 111             | `0x00 00 00 6f` |
| r         | 114             | `0x00 00 00 72` |
| l         | 108             | `0x00 00 00 6c` |
| d         | 100             | `0x00 00 00 64` |
| !         | 033             | `0x00 00 00 21` |

It is pretty clear that "hello world!" encoded as UTF-32 consumes 44 bytes,
whereas ASCII would use only 11. That is 400% larger! Remember that we are
talking about the end of the 80s when hard drives were a lot more expensive.
If Unicode was to supplant ASCII, a storage-efficient encoding was needed.

UTF-8
-----

And with storage efficiency in mind, UTF-8 was born.

The stroke of genius was to separate the character table (Unicode) from the
encoding. The creators of UTF-8 zoomed into each bit of every byte and assigned
a specific function to them. This bit-by-bit control allowed for a variable
number of bytes for each character: any UTF-8 encoded character can have 1, 2,
3 or 4 bytes.

Here is how it works:

### Single-byte characters

From `0x0` to `0x7F` (i.e., from 0 to 127), do the simple thing: convert to
binary. This results in single-byte characters that have two unique properties:

- The most significant bit is always zero because 127 in binary is
  `0b0111 1111`.
- Are ASCII compatible!

So when a UTF-8 decoder sees a byte starting with `0`, it already knows that it
is a single-byte character: job done, next character.

### Multi-byte characters

If the most significant bit of a byte is `1`, we _certainly_ have a multi-byte
character in our hands.

Multi-byte characters have the first byte be with `110`, `1110`, or
`11110`, for two, three, or four-byte characters, respectively. Continuation
bytes always begin with `10`. All other available bits (marked with an `x`)
encode the code point value in binary.

(Oh boy, the images disappeared, soon to be fixed!)
![UTF-8 control bytes](/resources/UTF-8/UTF-8.png){:class="img-responsive"}

Examples:

The snowman character ☃ is code point U+2603. When encoded as UTF-8 it becomes
`0xE2 96 83`.

(Oh boy, the images disappeared, soon to be fixed!)
![UTF-8 Snowman](/resources/UTF-8/Snowman-UTF-8.png){:class="img-responsive"}

The peach character 🍑 is code point U+1F351. Its UTF-8 encoded representation
is `0xF0 9F 8D 91`:

(Oh boy, the images disappeared, soon to be fixed!)
![UTF-8 Peach](/resources/UTF-8/Peach-UTF-8.png){:class="img-responsive"}

Doing these conversions by hand makes it clear that the UTF-8 encoding results
in a hexadecimal number that is completely different from the hexadecimal value
of the code point: `U+2603` becomes `0xE2 0x96 0x83`.

So UTF-8 is "storage efficient" because it is clever about the number of bytes
it takes to store a character. However, it is not so "processing smart."
Calculating the length of a string requires completely traversing it, resulting
in a linear growth rate (O(n)).


BOM – Byte Order Mark
---------------------

UTF-8 does not need a BOM due to its variable character length. However,
Windows (ah, Windows) wants to add  `0xEF BB 0xBF` to the beginning of UTF-8
encoded files. Mac and Linux do not do that. So sending a file over to your
boss (why do bosses always use Windows?) and receiving it back in your Linux
computer will add some garbage to the beginning of your file. And that might
cause you problems if you are not aware. And if that garbage looks like ï»¿
you might want to read part 1 of this series.


[Encodings Part 1: Unicode, ASCII, UTF-8 and... Latin-1?]: {{< ref "encoding.md" >}}
[Encodings Part 2: The down and dirty of UTF-8]: {{< ref "encoding-utf-8.md" >}}
[Encodings Part 3: The down and dirty of UTF-16]: {{< ref "encoding-utf-16.md" >}}