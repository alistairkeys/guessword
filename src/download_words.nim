# A utility to download five letter words and shuffle them
# This has a dependency on the Puppy library:
#
# https://github.com/treeform/puppy
#
# You can install it using the command "nimble install puppy".
#
# You can compile and run this file with the command:
# nim c -r download_words

import puppy
import std/[strutils, random, sugar]

const
  url = "https://raw.githubusercontent.com/charlesreid1/five-letter-words/master/sgb-words.txt"
  # another one: "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"

proc downloadWords() =
  var words = collect:
    for word in fetch(url).splitLines:
      if word.len == 5: word

  shuffle words

  var f = open("words.txt", fmWrite)
  try:
    for word in words:
      f.writeLine(word)
  finally:
    f.close()

when isMainModule:
  downloadWords()
