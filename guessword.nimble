# Package

version       = "0.1.0"
author        = "Ali Keys"
description   = "A word guessing game"
license       = "MIT"
srcDir        = "src"
bin           = @["guessword"]


# Dependencies

requires "nim >= 1.6.0",
  "staticglfw >= 4.1.3",
  "boxy >= 0.4.0"

#https://github.com/treeform/slappy
#https://github.com/treeform/pixiebook