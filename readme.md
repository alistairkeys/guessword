# guessword

## What is this?
This is a simple game where you have to guess the English word in a
limited amount of attempts.  Colours are used to show which letters
are in the correct position, which are in the word but in a different
position, and which ones aren't in the word at all.

## How do I build it?
This is written in the [Nim](https://nim-lang.org) programming language
so you'll to install that first.

I've written a simple build script to build the app.  You can compile
it with:

    nim c -r build.nim

This involves running Nimble and/or the Nim compiler to build relevant
files, as well as copying/moving files.

If you have problems with the -d:lto (Link Time Optimisation) flag in
the build script, you might need to use another syntax talking about
passL and passC.  Search the Nim forums (I think it's a clang thing;
the syntax I used works with GCC).  Alternatively, you can just remove
it - the final executable will be a little larger/slower but it won't
matter.

If you want to compile the project manually, it has dependencies on
Treeform's great libraries that you'll need to install first.

## Any other notes?
The list of words used in this project ("words.txt") is generated from
a repo:

https://raw.githubusercontent.com/charlesreid1/five-letter-words/master/sgb-words.txt

I wrote a tool to extract the five letter words and shuffle them - see
download_words.nim.  This gets called by the build script if necessary.

I'd suggest some manual curation of the words if you can be bothered as
there are some uncommon ones that would be hard to guess.

The bg.png and font in the data dir are just copied verbatin from one of
Boxy's example. :)

## Licence
This project is licenced under the MIT licence.