## A simple build script to create the app and its dependencies.  You
## can compile and run it with:
##
## nim -c r build.nim
##
## I was originally going to it as a Nimble task but eh, whatever.

import std/[os, osproc]

proc main() =
  try:
    echo "-> Removing the bin dir (if it exists)"
    removeDir("./bin")
  except:
    echo "WARNING: Couldn't remove the bin directory"

  echo "-> Creating the bin directories"
  createDir("./bin/data")

  echo "-> Building the application"
  discard execCmd "nimble build -d:lto -d:strip -d:danger -y --silent"
  moveFile("./guessword.exe", "./bin/guessword.exe")

  echo "-> Copying data files"
  for file in walkFiles("./src/data/*.*"):
    copyFileToDir(file, "./bin/data")

  if not fileExists("./bin/data/words.txt"):
    echo "-> Generating the words.txt file"
    discard execCmd "nimble install puppy -n --silent"
    discard execCmd "nim c --hints:off ./src/download_words.nim"
    discard execCmd "./src/download_words.exe"
    moveFile("./words.txt", "./bin/data/words.txt")

when isMainModule:
  echo "Building the release"
  try:
    main()
  finally:
    echo "Done - check the bin directory"
