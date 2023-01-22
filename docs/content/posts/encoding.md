---
date: 2021-11-03T16:36:48+01:00
draft: false
tags: ["encoding", "engineering", "computer-science"]
title: "Unicode, ASCII, UTF-8 and... Latin-1?"
---

What is Unicode, why is it used everywhere, and what are the options?

We, software developers need to use string data types pretty much daily and
yet, there is a lot under the surface that nowadays we don't even think about
anymore. This makes character encodings a basic thing, but is it simple?


## Encoding, you say?

So let's start from the beginning, what is "enconding", really?

To encode is to convert one type of data into another type. We could go as far
as saying that written text encodes spoken language, or that emotions are
encoded in our facial expressions or that the color of our eyes are encoded in
our DNAs. Converting a decimal number into its binary or hexadecimal
representation is also a type of encoding, e.g. 15 → 1111 → F.

One interesting encoding example is the Braille writing system for vizually
impaired people. It is represented by characters that can be printed onto
embossed paper.

A Braille character is represented by a "cell", which is 2 columns and 3 rows
of possible raised dots: the presence of a raised dot is a 1, and the abscense
is a 0. This 6-bit encoding allows for the existence of 64 different values,
which is plenty enough for the entire latin alphabet. The cool part is that in
spite of being binary in nature, it was created in 1824, way before the first
electronic digital calculators were brought to life during World War II.

For example:
- ⠁⠃⠉ → abc
- ⠅⠇⠍ → klm


## Character encoding in computer engineering

Computers are here to serve us humans (not if you ask Mark Zuckerberg, but
that's another topic), and humans have extremely varied languages, and to
complicate things, we inveted written characters: several times.

We also reinvented encoding many times over: thousands of years ago the Chinese
had already encoded the words "war" and "peace" as "beacon fire ON" and "beacon
fire OFF" on the Great Wall of China; telegraph engineers had their own
character encoding called Baudot Code; Francis Bacon encoded hidden binary
messages in plain sight by writing a decoy text in two distinct fonts in 1605;
etc, etc, etc.

It then comes as no surprise that we, humans, wanted computers to speak our own
languages, and be able to understand our human characters. However, computers
only understand binary data, so we had to create binary encodings of our
(messy, countless, varied) human characters in order to store and process them
with a digital computer.


## ASCII

ASCII is not really the first, but the first relevant character encoding
system for us here, since it still lives on through UTF-8 (we will get to
UTF-8 soon).

What engineers did was to simply group all symbols that they needed a computer
to understand and assigned a number from 0 to 127 to them. (Note that it takes
7 bits to represent 127 characters, so the 8th bit will always be zero, which
makes ASCII self-synchronizing.)

This encoding includes all latin characters, both lower and upper case,
decimal numbers from 0 to 9, many desired symbols such as parenthesis,
brackets, punctuation, and even some control characters, like the "bell"
(character number 7, which would ring a physical bell on the machine) and the
"line feed".

In ASCII the character table and the encoding are one and the same, i.e. the
binary representation of the character number **is** the encoding.

ASCII, however, is a bit problematic. The root of the problem is that it was
developed by Americans, to work well in English. No need to say that speakers
of other languages had to figure out how to represent their own characters.
Swedes needed the leters ä, ö and å; Greeks needed the all letters of an entire
different alphabet (e.g. α, β, γ, ...).

<details><summary>ASCII table</summary>

  <pre>
Dec | Char
----|-----
  0 | NUL (null)
  1 | SOH (start of heading)
  2 | STX (start of text)
  3 | ETX (end of text)
  4 | EOT (end of transmission)
  5 | ENQ (enquiry)
  6 | ACK (acknowledge)
  7 | BEL (bell)
  8 | BS  (backspace)
  9 | TAB (horizontal tab)
 10 | LF  (NL line feed, new line)
 11 | VT  (vertical tab)
 12 | FF  (NP form feed, new page)
 13 | CR  (carriage return)
 14 | SO  (shift out)
 15 | SI  (shift in)
 16 | DLE (data link escape)
 17 | DC1 (device control 1)
 18 | DC2 (device control 2)
 19 | DC3 (device control 3)
 20 | DC4 (device control 4)
 21 | NAK (negative acknowledge)
 22 | SYN (synchronous idle)
 23 | ETB (end of trans. block)
 24 | CAN (cancel)
 25 | EM  (end of medium)
 26 | SUB (substitute)
 27 | ESC (escape)
 28 | FS  (file separator)
 29 | GS  (group separator)
 30 | RS  (record separator)
 31 | US  (unit separator)
 32 | SPACE
 33 | !
 34 | "
 35 | #
 36 | $
 37 | %
 38 | &
 39 | '
 40 | (
 41 | )
 42 | *
 43 | +
 44 | ,
 45 | -
 46 | .
 47 | /
 48 | 0
 49 | 1
 50 | 2
 51 | 3
 52 | 4
 53 | 5
 54 | 6
 55 | 7
 56 | 8
 57 | 9
 58 | :
 59 | ;
 60 | <
 61 | =
 62 | >
 63 | ?
 64 | @
 65 | A
 66 | B
 67 | C
 68 | D
 69 | E
 70 | F
 71 | G
 72 | H
 73 | I
 74 | J
 75 | K
 76 | L
 77 | M
 78 | N
 79 | O
 80 | P
 81 | Q
 82 | R
 83 | S
 84 | T
 85 | U
 86 | V
 87 | W
 88 | X
 89 | Y
 90 | Z
 91 | [
 92 | \
 93 | ]
 94 | ^
 95 | _
 96 | `
 97 | a
 98 | b
 99 | c
100 | d
101 | e
102 | f
103 | g
104 | h
105 | i
106 | j
107 | k
108 | l
109 | m
110 | n
111 | o
112 | p
113 | q
114 | r
115 | s
116 | t
117 | u
118 | v
119 | w
120 | x
121 | y
122 | z
123 | {
124 | |
125 | }
126 | ~
127 | DEL

  </pre>
</details>


## Latin1, half-fixing half of the problems

ASCII missed the mark by a tiny bit for many many languages. The Swedish
laguage, for example, only needed 3 extra characters (ä, ö and å), out of which
"ä" and "ö" would also be useful to German. Portuguese needed a "ç" which would
also be useful to French.

Speakers of such languages created a new encoding based on ASCII. The first 127
characters would be exactly the same, but from 128 to 255 they added whatever
they thought was necessary.

Note that this has 2 consequences:
1. The 8th bit which was always zero in ASCII, is now used for the actual
   encoding, and we lose self-synchronization.
2. Of course, not everyone managed to squeeze in their characters. One example
   was the French œ and Ÿ characters. Don't mess with the French.

And so was born Latin1, a.k.a. ISO 8850-1. And because some people were unhappy
with Latin1, other **slightly similar** encodings were created:

* ISO 8859-15 (a.k.a. Latin0, Latin9)
* Windows 1252
* MCS
* And many more (for e.g. Cyrilic and Greek alphabets).

All these enchodings strived to keep compatible with ASCII from 0 to 127.
However, from 128 to 255 one could only guess. Some favoured the mathematical
accuracy of "±", while others favoured non-printable control characters.

Long story short: Latin1 did not define characters for the range 128 to 159, so
Windows 1252 took advantage of that and introduced printable characters for
many of those. It included: the oh-so-important € sign; the Ÿ which allows
round-trip capitalization of French text without loss; the more finiky curly
quotes (“), which made encoding missmatches a big pain to read, because those
would be turned into question marks indicating an encoding error and would be
sprinkled all over curly-eager text. As a result, text editors started decoding
Latin1 text with Windows 1252 "just in case".

It does not stop there. There are also Windows Code Pages, which allows
representing characters from many other languages. Each code page is, in fact a
different encoding, but calling it "pages" makes the mess more tolerable.

In the pre-internet days the pain was not so obvious, but as soon as we started
sharing documentes over the web to and from anywhere, a better way became sorely
needed.


## Unicode

How about collecting, categorizing and indexing all characters from all human
languages so that only one encoding is needed? Screw this 256 limit and give
every human character a number, for example:

symbol  | decimal     | Hexadecimal code point
--------|-------------|-----------------------
...     | ...         | ...
a       |  97         | U+61
b       |  98         | U+62
A       |  41         | U+29
B       |  42         | U+2A
...     | ...         | ...
γ       |  947        | U+3B3
Γ       |  915        | U+393
...     | ...         | ...
爱      | 24859       | U+611b
...     | ...         | ...

and so on. Just list them all in this one huge table.

That is the challenge that a few individuals in the end of the 80s accepted
and called their character map Unicode. For the sake of computers though,
they promised to not assign more than 1 112 064 characters, as a hugely
overestimated upper limit (a little more than the previous 255.)

Unicode assigns a "code point" to each character in their "character
repertoir".  Unicode 14.0 includes 144 697 characters from pretty much any
languange we can think of. Best of all (but not controversy-free), the first
127 characters are exactly the same as defined by ASCII. Less impressively,
however, characters 128 through 255 are taken from Latin1 (this causes some
complications that we will talk about soon).

So! Problem solved, right? Just transform the Unicode code point into binary
and let's live on! Not so fast... ASCII was one byte long, but we need 3 bytes
for encoding the number 144 697, but only one byte to encode the letter "A"
(code point 65). If we need 3 bytes for all ASCII characters we would have a
torrent of zero bytes taking up space in our hard drives. Imagine trippling the
storage taken by all text in English when coverting from ASCII to Unicode? This
was a problem that has a brilliant solution called UTF-8.

We will describe UTF-8 in detail, but for now, let's put Unicode into scrutiny
with a magnifying glass 🔎. Or maybe 🕵🏽‍♂️, to keep things interesting
and cohesive with my Brazilian background.

### Unicode overview

This is where we go the extra mile for a bit of knowledge.

The entire Unicode character space is devided into planes. Each plane is a block
of contiguous 65536 code points (0xFFFF in hexadecimal, see?).

Plane 0 contains the vast majority of all characters that are used in human
writing, and it is called the BMP (Basic Multiligual Plane). It includes
the most common Chinese, Japanese and Korean characts in a group called CJK.
But it does not include all CJK characters. Those need entire planes, keep
reading.

Plane 1 is the SMP: Supplementary Multiligual Plane. It contains the oh so
loved emojis, some historic characters, mathematical and music symbols. You get
the point.

Planes 2 and 3 contain many of the Chinese, Japanese and Korean ideographic
characters. There is a bit of controversy in this subject because the Unicode
consortiumn is engaged in trying to categorize and maybe bunch together some
characters used in different languages in a process called Han unification.
Also, these characters are assigned high code-points which, in UTF-8 consume
more bytes, being less space-efficient. So now you know that all of this does
not come controversy-free.

Plane 14, to keep things spicy, has some has "variation selectors" that can
be used to differentiate characters in planes 2 and 3. I found quite hard to
find a practical example of this, so I'll stop spending time on it now and
hope someone reading this will send me a nifty example 😁. Moving on…


## UTF-32

Tired of clever encodings? Ready to waste a lot of space with zeroes?
Then UTF-32 is for you. Well, sort of.

In a lower level program written in C, when we convert an emoji character, for
example, back into its Unicode code point.